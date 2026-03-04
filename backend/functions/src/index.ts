import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { applyUnpaidPenalty, expireUnpaidOrders } from './domain/orderEngine.js';
import { placeBid as placeBidEngine } from './domain/auctionEngine.js';
import { featureFlags } from './config/policy.js';
import { finalizeAuction, shouldSettle, toAwaitingPaymentOrder } from './domain/schedulerEngine.js';

admin.initializeApp();
const db = admin.firestore();

async function createInboxNotification(uid: string, type: string, title: string, body: string, deeplink: string): Promise<void> {
  const ref = db.collection('notifications').doc(uid).collection('inbox').doc();
  await ref.set({ type, title, body, deeplink, isRead: false, createdAt: admin.firestore.FieldValue.serverTimestamp() });
}

export const createOrUpdateItem = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const payload = req.data as any;
  if (payload.categoryMain === 'GOODS' && (!payload.goodsAuthImages || payload.goodsAuthImages.length < 1)) {
    throw new HttpsError('invalid-argument', 'GOODS requires at least one auth image');
  }
  if ((payload.images?.length ?? 0) > 10) throw new HttpsError('invalid-argument', 'images max 10');

  const itemRef = payload.id ? db.collection('items').doc(payload.id) : db.collection('items').doc();
  const now = admin.firestore.FieldValue.serverTimestamp();
  await itemRef.set({ ...payload, sellerId: uid, updatedAt: now, createdAt: payload.createdAt ?? now }, { merge: true });
  return { itemId: itemRef.id };
});

export const createAuctionFromItem = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const data = req.data as any;
  const startAt = new Date(data.startAt ?? Date.now());
  const endAt = new Date(data.endAt);
  if (Number.isNaN(startAt.getTime()) || Number.isNaN(endAt.getTime()) || endAt <= startAt) {
    throw new HttpsError('invalid-argument', 'invalid schedule');
  }

  const auctionRef = db.collection('auctions').doc();
  await auctionRef.set({
    itemId: data.itemId,
    sellerId: uid,
    startPrice: data.startPrice,
    buyNowPrice: data.buyNowPrice ?? null,
    currentPrice: data.startPrice,
    status: startAt > new Date() ? 'DRAFT' : 'LIVE',
    startAt: admin.firestore.Timestamp.fromDate(startAt),
    endAt: admin.firestore.Timestamp.fromDate(endAt),
    extendedCount: 0,
    bidCount: 0,
    bidderCount: 0,
    highestBidderId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { auctionId: auctionRef.id };
});

export const placeBid = onCall(async (req) => {
  const bidderId = req.auth?.uid;
  if (!bidderId) throw new HttpsError('unauthenticated', 'Login required');
  const { auctionId, amount } = req.data;

  const auctionRef = db.collection('auctions').doc(auctionId);
  let outbidUserId: string | undefined;
  let finalPrice = amount;

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(auctionRef);
    if (!snap.exists) throw new HttpsError('not-found', 'Auction not found');
    const auctionData = snap.data()!;
    const autoBidDocs = featureFlags.autoBid
      ? await tx.get(auctionRef.collection('autoBids').where('isEnabled', '==', true))
      : ({ docs: [] } as FirebaseFirestore.QuerySnapshot);

    const result = placeBidEngine({
      auction: {
        id: auctionId,
        itemId: auctionData.itemId,
        sellerId: auctionData.sellerId,
        startPrice: auctionData.startPrice,
        buyNowPrice: auctionData.buyNowPrice,
        currentPrice: auctionData.currentPrice,
        status: auctionData.status,
        endAt: auctionData.endAt.toDate(),
        extendedCount: auctionData.extendedCount,
        bidCount: auctionData.bidCount,
        bidderCount: auctionData.bidderCount,
        highestBidderId: auctionData.highestBidderId,
      },
      bidderId,
      amount,
      now: new Date(),
      autoBids: autoBidDocs.docs.map((d) => ({ uid: d.id, ...(d.data() as any) })),
    });

    outbidUserId = result.outbidUserId;
    finalPrice = result.auction.currentPrice;

    tx.update(auctionRef, {
      currentPrice: result.auction.currentPrice,
      highestBidderId: result.auction.highestBidderId,
      bidCount: result.auction.bidCount,
      bidderCount: result.auction.bidderCount,
      endAt: admin.firestore.Timestamp.fromDate(result.auction.endAt),
      extendedCount: result.auction.extendedCount,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    for (const bid of result.bids) {
      tx.set(auctionRef.collection('bids').doc(), {
        bidderId: bid.bidderId,
        amount: bid.amount,
        kind: bid.kind,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });

  if (outbidUserId && outbidUserId !== bidderId) {
    await createInboxNotification(outbidUserId, 'OUTBID', '입찰가가 갱신되었습니다', `현재 최고가 ${finalPrice}원`, `app://auction/${auctionId}`);
  }

  return { ok: true };
});

export const setAutoBid = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const { auctionId, maxAmount, disable } = req.data;
  const ref = db.collection('auctions').doc(auctionId).collection('autoBids').doc(uid);
  await ref.set(
    {
      maxAmount: maxAmount ?? 0,
      isEnabled: !disable,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  return { ok: true };
});

export const buyNow = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const { auctionId } = req.data;
  const auctionRef = db.collection('auctions').doc(auctionId);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(auctionRef);
    const auction = snap.data();
    if (!auction?.buyNowPrice) throw new HttpsError('failed-precondition', 'buyNow not available');
    if (auction.status !== 'LIVE') throw new HttpsError('failed-precondition', 'auction not live');

    const orderRef = db.collection('orders').doc();
    tx.set(orderRef, {
      auctionId,
      itemId: auction.itemId,
      buyerId: uid,
      sellerId: auction.sellerId,
      finalPrice: auction.buyNowPrice,
      paymentStatus: 'UNPAID',
      escrowStatus: 'HOLD',
      orderStatus: 'AWAITING_PAYMENT',
      paymentDueAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 24 * 60 * 60 * 1000)),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.update(auctionRef, { status: 'ENDED', highestBidderId: uid, currentPrice: auction.buyNowPrice, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    return { orderId: orderRef.id };
  });
});

export const payOrder = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const { orderId, method, mockResult } = req.data;
  const orderRef = db.collection('orders').doc(orderId);
  const snap = await orderRef.get();
  const order = snap.data();
  if (!order || order.buyerId !== uid) throw new HttpsError('permission-denied', 'Only buyer');
  if (mockResult !== 'SUCCESS') {
    await orderRef.update({ paymentStatus: 'FAILED', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    return { ok: false };
  }
  await orderRef.update({
    paymentMethod: method,
    paymentStatus: 'PAID',
    orderStatus: 'PAID_ESCROW_HOLD',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await createInboxNotification(order.sellerId, 'SYSTEM', '결제 완료', '구매자 결제가 완료되었습니다.', `app://orders/${orderId}`);
  return { ok: true };
});

export const shipmentUpdate = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const { orderId, carrier, trackingNumber } = req.data;
  const ref = db.collection('orders').doc(orderId);
  const order = (await ref.get()).data();
  if (!order || order.sellerId !== uid) throw new HttpsError('permission-denied', 'Only seller');
  await ref.update({
    orderStatus: 'SHIPPED',
    shipping: { carrier, trackingNumber, shippedAt: admin.firestore.FieldValue.serverTimestamp() },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await createInboxNotification(order.buyerId, 'SHIPPED', '배송이 시작되었습니다', `${carrier} ${trackingNumber}`, `app://orders/${orderId}`);
  return { ok: true };
});

export const confirmReceipt = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const { orderId } = req.data;
  const ref = db.collection('orders').doc(orderId);
  const order = (await ref.get()).data();
  if (!order || order.buyerId !== uid) throw new HttpsError('permission-denied', 'Only buyer');
  const expectedAt = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000);
  await ref.update({
    orderStatus: 'CONFIRMED_RECEIPT',
    settlement: { expectedAt: admin.firestore.Timestamp.fromDate(expectedAt) },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { ok: true };
});

export const finalizeAuctionsScheduler = onSchedule('every 5 minutes', async () => {
  const now = new Date();
  const snap = await db.collection('auctions').where('status', '==', 'LIVE').where('endAt', '<=', admin.firestore.Timestamp.fromDate(now)).get();

  for (const doc of snap.docs) {
    const data = doc.data();
    const decision = finalizeAuction({
      id: doc.id,
      itemId: data.itemId,
      sellerId: data.sellerId,
      status: data.status,
      endAt: data.endAt.toDate(),
      currentPrice: data.currentPrice,
      highestBidderId: data.highestBidderId,
    }, now);
    if (!decision.shouldFinalize) continue;

    await doc.ref.update({ status: decision.nextStatus, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
    if (decision.nextStatus === 'ENDED' && data.highestBidderId) {
      const order = toAwaitingPaymentOrder({
        id: doc.id,
        itemId: data.itemId,
        sellerId: data.sellerId,
        status: data.status,
        endAt: data.endAt.toDate(),
        currentPrice: data.currentPrice,
        highestBidderId: data.highestBidderId,
      }, now);
      const orderRef = db.collection('orders').doc();
      await orderRef.set({
        ...order,
        escrowStatus: 'HOLD',
        fees: { feeRate: 0.05, feeAmount: Math.floor(order.finalPrice * 0.05) },
        settlement: { expectedAt: null, settledAt: null },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      await createInboxNotification(order.buyerId, 'WON', '낙찰되었습니다', `결제 기한 내 결제를 진행해주세요.`, `app://orders/${orderRef.id}`);
    }
  }
});

export const expireUnpaidOrdersScheduler = onSchedule('every 10 minutes', async () => {
  const now = new Date();
  const snap = await db.collection('orders').where('orderStatus', '==', 'AWAITING_PAYMENT').where('paymentDueAt', '<=', admin.firestore.Timestamp.fromDate(now)).get();

  for (const doc of snap.docs) {
    const o = doc.data();
    const updated = expireUnpaidOrders(now, [{
      id: doc.id,
      auctionId: o.auctionId,
      buyerId: o.buyerId,
      sellerId: o.sellerId,
      finalPrice: o.finalPrice,
      paymentStatus: o.paymentStatus,
      orderStatus: o.orderStatus,
      paymentDueAt: o.paymentDueAt.toDate(),
    }])[0];
    if (updated.orderStatus !== 'CANCELLED_UNPAID') continue;

    await doc.ref.update({ orderStatus: 'CANCELLED_UNPAID', paymentStatus: 'CANCELLED', updatedAt: admin.firestore.FieldValue.serverTimestamp() });

    const userRef = db.collection('users').doc(o.buyerId);
    const userSnap = await userRef.get();
    const penaltyStats = userSnap.data()?.penaltyStats ?? { unpaidCount: 0, depositForfeitedCount: 0, trustScore: 100 };
    const penalty = applyUnpaidPenalty(penaltyStats, o.finalPrice);
    await userRef.set({
      penaltyStats: {
        unpaidCount: penalty.unpaidCount,
        depositForfeitedCount: penalty.depositForfeitedCount,
        trustScore: penalty.trustScore,
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
});

export const settleScheduler = onSchedule('every 60 minutes', async () => {
  const now = new Date();
  const snap = await db.collection('orders').where('orderStatus', '==', 'CONFIRMED_RECEIPT').get();
  for (const doc of snap.docs) {
    const data = doc.data();
    const expectedAt = data.settlement?.expectedAt?.toDate?.();
    if (!expectedAt) continue;
    if (!shouldSettle(data.orderStatus, expectedAt, now)) continue;
    await doc.ref.update({
      orderStatus: 'SETTLED',
      escrowStatus: 'RELEASED',
      settlement: { ...data.settlement, settledAt: admin.firestore.Timestamp.fromDate(now) },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
});
