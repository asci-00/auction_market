import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { placeBid as placeBidEngine } from './domain/auctionEngine.js';
import { featureFlags } from './config/policy.js';

admin.initializeApp();
const db = admin.firestore();

export const createOrUpdateItem = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const payload = req.data as any;
  if (payload.categoryMain === 'GOODS' && (!payload.goodsAuthImages || payload.goodsAuthImages.length < 1)) {
    throw new HttpsError('invalid-argument', 'GOODS requires at least one auth image');
  }
  const itemRef = payload.id ? db.collection('items').doc(payload.id) : db.collection('items').doc();
  const now = admin.firestore.FieldValue.serverTimestamp();
  await itemRef.set({ ...payload, sellerId: uid, updatedAt: now, createdAt: payload.createdAt ?? now }, { merge: true });
  return { itemId: itemRef.id };
});

export const createAuctionFromItem = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const data = req.data as any;
  const auctionRef = db.collection('auctions').doc();
  await auctionRef.set({
    itemId: data.itemId,
    sellerId: uid,
    startPrice: data.startPrice,
    buyNowPrice: data.buyNowPrice ?? null,
    currentPrice: data.startPrice,
    status: 'LIVE',
    startAt: admin.firestore.Timestamp.fromDate(new Date(data.startAt ?? Date.now())),
    endAt: admin.firestore.Timestamp.fromDate(new Date(data.endAt)),
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
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(auctionRef);
    if (!snap.exists) throw new HttpsError('not-found', 'Auction not found');
    const auctionData = snap.data()!;
    const autoBidDocs = featureFlags.autoBid
      ? await tx.get(auctionRef.collection('autoBids').where('isEnabled', '==', true))
      : ({ docs: [] } as any);

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
      autoBids: autoBidDocs.docs.map((d: any) => ({ uid: d.id, ...d.data() })),
    });

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

export const finalizeAuctionsScheduler = onSchedule('every 5 minutes', async () => { return null; });
export const expireUnpaidOrdersScheduler = onSchedule('every 10 minutes', async () => { return null; });
export const settleScheduler = onSchedule('every 60 minutes', async () => { return null; });

export const buyNow = onCall(async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');
  const { auctionId } = req.data;
  const auctionRef = db.collection('auctions').doc(auctionId);
  const auction = (await auctionRef.get()).data();
  if (!auction?.buyNowPrice) throw new HttpsError('failed-precondition', 'buyNow not available');

  const orderRef = db.collection('orders').doc();
  await orderRef.set({
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
  return { orderId: orderRef.id };
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
  await db.collection('auctions').doc(order.auctionId).update({ status: 'ENDED', updatedAt: admin.firestore.FieldValue.serverTimestamp() });
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
