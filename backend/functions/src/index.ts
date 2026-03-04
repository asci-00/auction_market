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

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(itemRef);
    if (snap.exists && snap.data()?.sellerId !== uid) {
      throw new HttpsError('permission-denied', 'Only owner can update item');
    }

    const existingCreatedAt = snap.data()?.createdAt ?? admin.firestore.FieldValue.serverTimestamp();
    tx.set(
      itemRef,
      {
        ...payload,
        sellerId: uid,
        createdAt: existingCreatedAt,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });

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
  if (typeof data.startPrice !== 'number' || data.startPrice <= 0) {
    throw new HttpsError('invalid-argument', 'invalid startPrice');
  }
  if (data.buyNowPrice != null && (typeof data.buyNowPrice !== 'number' || data.buyNowPrice <= data.startPrice)) {
    throw new HttpsError('invalid-argument', 'buyNowPrice must be greater than startPrice');
  }

  const itemRef = db.collection('items').doc(data.itemId);
  const itemSnap = await itemRef.get();
  if (!itemSnap.exists) throw new HttpsError('not-found', 'Item not found');
  if (itemSnap.data()?.sellerId !== uid) throw new HttpsError('permission-denied', 'Only owner can create auction from item');

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
    orderId: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { auctionId: auctionRef.id };
});

export const placeBid = onCall(async (req) => {
  const bidderId = req.auth?.uid;
  if (!bidderId) throw new HttpsError('unauthenticated', 'Login required');

  const { auctionId, amount } = req.data;
  if (typeof amount !== 'number' || amount <= 0) throw new HttpsError('invalid-argument', 'invalid amount');

  const auctionRef = db.collection('auctions').doc(auctionId);
  let outbidUserId: string | undefined;
  let finalPrice = amount;

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(auctionRef);
    if (!snap.exists) throw new HttpsError('not-found', 'Auction not found');

    const auctionData = snap.data()!;
    if (auctionData.sellerId === bidderId) throw new HttpsError('failed-precondition', 'seller cannot bid own auction');

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
  const auctionRef = db.collection('auctions').doc(auctionId);
  const autoBidRef = auctionRef.collection('autoBids').doc(uid);

  await db.runTransaction(async (tx) => {
    const auctionSnap = await tx.get(auctionRef);
    if (!auctionSnap.exists) throw new HttpsError('not-found', 'Auction not found');

    const auction = auctionSnap.data()!;
    if (auction.status !== 'LIVE') throw new HttpsError('failed-precondition', 'auction is not live');
    if (auction.sellerId === uid) throw new HttpsError('failed-precondition', 'seller cannot set auto bid');

    const autoBidSnap = await tx.get(autoBidRef);
    if (!disable && (typeof maxAmount !== 'number' || maxAmount <= 0)) {
      throw new HttpsError('invalid-argument', 'maxAmount must be positive when enabling auto bid');
    }

    tx.set(
      autoBidRef,
      {
        maxAmount: disable ? 0 : maxAmount,
        isEnabled: !disable,
        createdAt: autoBidSnap.data()?.createdAt ?? admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });

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
    if (auction.sellerId === uid) throw new HttpsError('failed-precondition', 'seller cannot buy own auction');
    if (auction.orderId) throw new HttpsError('already-exists', 'order already exists for this auction');

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
    tx.update(auctionRef, {
      status: 'ENDED',
      highestBidderId: uid,
      currentPrice: auction.buyNowPrice,
      orderId: orderRef.id,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
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
  if (order.orderStatus !== 'AWAITING_PAYMENT') throw new HttpsError('failed-precondition', 'order not awaiting payment');

  if (mockResult === 'FAIL' || mockResult === 'FAILED') {
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
  if (order.orderStatus !== 'PAID_ESCROW_HOLD') throw new HttpsError('failed-precondition', 'order not payable/shippable state');

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
  if (order.orderStatus !== 'SHIPPED') throw new HttpsError('failed-precondition', 'order is not shipped');

  const expectedAt = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000);
  await ref.update({
    orderStatus: 'CONFIRMED_RECEIPT',
    settlement: { ...(order.settlement ?? {}), expectedAt: admin.firestore.Timestamp.fromDate(expectedAt) },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { ok: true };
});

export const activateDraftAuctionsScheduler = onSchedule('every 5 minutes', async () => {
  const now = admin.firestore.Timestamp.fromDate(new Date());
  const snap = await db.collection('auctions').where('status', '==', 'DRAFT').where('startAt', '<=', now).get();

  for (const doc of snap.docs) {
    await doc.ref.update({ status: 'LIVE', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
  }
});

export const finalizeAuctionsScheduler = onSchedule('every 5 minutes', async () => {
  const now = new Date();
  const snap = await db.collection('auctions').where('status', '==', 'LIVE').where('endAt', '<=', admin.firestore.Timestamp.fromDate(now)).get();

  for (const doc of snap.docs) {
    const notification = await db.runTransaction(async (tx) => {
      const freshAuctionSnap = await tx.get(doc.ref);
      if (!freshAuctionSnap.exists) return null;
      const data = freshAuctionSnap.data()!;

      const decision = finalizeAuction(
        {
          id: freshAuctionSnap.id,
          itemId: data.itemId,
          sellerId: data.sellerId,
          status: data.status,
          endAt: data.endAt.toDate(),
          currentPrice: data.currentPrice,
          highestBidderId: data.highestBidderId,
        },
        now,
      );

      if (!decision.shouldFinalize) return null;

      if (decision.nextStatus === 'ENDED' && data.highestBidderId) {
        if (data.orderId) {
          tx.update(doc.ref, { status: 'ENDED', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
          return null;
        }

        const order = toAwaitingPaymentOrder(
          {
            id: freshAuctionSnap.id,
            itemId: data.itemId,
            sellerId: data.sellerId,
            status: data.status,
            endAt: data.endAt.toDate(),
            currentPrice: data.currentPrice,
            highestBidderId: data.highestBidderId,
          },
          now,
        );

        const orderRef = db.collection('orders').doc();
        tx.set(orderRef, {
          ...order,
          escrowStatus: 'HOLD',
          fees: { feeRate: 0.05, feeAmount: Math.floor(order.finalPrice * 0.05) },
          settlement: { expectedAt: null, settledAt: null },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        tx.update(doc.ref, { status: 'ENDED', orderId: orderRef.id, updatedAt: admin.firestore.FieldValue.serverTimestamp() });

        return { buyerId: order.buyerId, orderId: orderRef.id };
      }

      tx.update(doc.ref, { status: decision.nextStatus, updatedAt: admin.firestore.FieldValue.serverTimestamp() });
      return null;
    });

    if (notification) {
      await createInboxNotification(notification.buyerId, 'WON', '낙찰되었습니다', '결제 기한 내 결제를 진행해주세요.', `app://orders/${notification.orderId}`);
    }
  }
});

export const expireUnpaidOrdersScheduler = onSchedule('every 10 minutes', async () => {
  const now = new Date();
  const snap = await db
    .collection('orders')
    .where('orderStatus', '==', 'AWAITING_PAYMENT')
    .where('paymentDueAt', '<=', admin.firestore.Timestamp.fromDate(now))
    .get();

  for (const doc of snap.docs) {
    const shouldNotify = await db.runTransaction(async (tx) => {
      const orderSnap = await tx.get(doc.ref);
      if (!orderSnap.exists) return false;
      const o = orderSnap.data()!;

      const updated = expireUnpaidOrders(now, [
        {
          id: orderSnap.id,
          auctionId: o.auctionId,
          buyerId: o.buyerId,
          sellerId: o.sellerId,
          finalPrice: o.finalPrice,
          paymentStatus: o.paymentStatus,
          orderStatus: o.orderStatus,
          paymentDueAt: o.paymentDueAt.toDate(),
        },
      ])[0];

      if (updated.orderStatus !== 'CANCELLED_UNPAID') return false;

      const userRef = db.collection('users').doc(o.buyerId);
      const userSnap = await tx.get(userRef);
      const penaltyStats = userSnap.data()?.penaltyStats ?? { unpaidCount: 0, depositForfeitedCount: 0, trustScore: 100 };
      const penalty = applyUnpaidPenalty(penaltyStats, o.finalPrice);

      tx.update(doc.ref, {
        orderStatus: 'CANCELLED_UNPAID',
        paymentStatus: 'CANCELLED',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      tx.set(
        userRef,
        {
          penaltyStats: {
            unpaidCount: penalty.unpaidCount,
            depositForfeitedCount: penalty.depositForfeitedCount,
            trustScore: penalty.trustScore,
          },
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return true;
    });

    if (shouldNotify) {
      await createInboxNotification(doc.data().buyerId, 'PAYMENT_DUE', '결제 기한이 만료되었습니다', '미결제로 주문이 취소되었고 패널티가 반영되었습니다.', `app://orders/${doc.id}`);
    }
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

    await createInboxNotification(data.sellerId, 'SYSTEM', '정산 완료', `주문 ${doc.id} 정산이 완료되었습니다.`, `app://orders/${doc.id}`);
  }
});
