import { initializeApp } from 'firebase-admin/app';
import {
  FieldValue,
  Timestamp,
  Transaction,
  getFirestore,
} from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';
import { HttpsError, onCall, onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { featureFlags } from './config/policy.js';
import { placeBid as placeBidEngine } from './domain/auctionEngine.js';
import {
  applyUnpaidPenalty,
  buildOrderFees,
  expireUnpaidOrders,
} from './domain/orderEngine.js';
import {
  buildWebhookEventMarker,
  extractWebhookSecret,
  isDuplicatePaymentConfirmation,
  normalizeWebhookPayment,
  toCancelledPaymentOrder,
  toConfirmedPaymentOrder,
  toFailedPaymentOrder,
  withLastWebhookEventId,
} from './domain/paymentEngine.js';
import { AuditEventRecord, Order } from './domain/models.js';
import {
  finalizeAuction,
  shouldSettle,
  toAwaitingPaymentOrder,
} from './domain/schedulerEngine.js';

initializeApp();
const db = getFirestore();

type AnyRecord = Record<string, unknown>;

interface RuntimeConfig {
  appEnv: 'dev' | 'staging' | 'prod';
  tossSecretKey: string | null;
  tossWebhookSecret: string | null;
  tossApiBaseUrl: string;
  appBaseUrl: string | null;
}

interface ConfirmTossPaymentResponse {
  paymentKey: string;
  method: string | null;
  approvedAt: Date;
  totalAmount: number;
  status: string;
}

function meaningfulString(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null;
  }

  const normalized = value.trim();
  if (
    !normalized ||
    normalized.startsWith('TODO_') ||
    normalized.startsWith('TODO_FROM_')
  ) {
    return null;
  }

  return normalized;
}

function getRuntimeConfig(): RuntimeConfig {
  const appEnv = meaningfulString(process.env.APP_ENV) ?? 'dev';
  if (!['dev', 'staging', 'prod'].includes(appEnv)) {
    throw new HttpsError(
      'failed-precondition',
      'APP_ENV must be dev, staging, or prod.',
    );
  }

  return {
    appEnv: appEnv as RuntimeConfig['appEnv'],
    tossSecretKey: meaningfulString(process.env.TOSS_SECRET_KEY),
    tossWebhookSecret: meaningfulString(process.env.TOSS_WEBHOOK_SECRET),
    tossApiBaseUrl:
      meaningfulString(process.env.TOSS_API_BASE_URL) ??
      'https://api.tosspayments.com',
    appBaseUrl: meaningfulString(process.env.APP_BASE_URL),
  };
}

function requireAuthUid(uid: string | undefined): string {
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Login required');
  }
  return uid;
}

function ensureObject(value: unknown, message: string): AnyRecord {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new HttpsError('invalid-argument', message);
  }
  return value as AnyRecord;
}

function ensureString(
  value: unknown,
  fieldName: string,
  options?: { allowEmpty?: boolean },
): string {
  if (typeof value !== 'string') {
    throw new HttpsError('invalid-argument', `${fieldName} must be a string`);
  }
  const trimmed = value.trim();
  if (!options?.allowEmpty && !trimmed) {
    throw new HttpsError('invalid-argument', `${fieldName} is required`);
  }
  return trimmed;
}

function optionalString(value: unknown): string | null {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function optionalPositiveNumber(value: unknown): number | null {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return null;
  }
  return value > 0 ? value : null;
}

function optionalPositiveInteger(value: unknown): number | null {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return null;
  }
  if (!Number.isInteger(value) || value <= 0) {
    return null;
  }
  return value;
}

function stringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter((entry): entry is string => typeof entry === 'string');
}

function toDate(value: unknown, fieldName: string): Date {
  if (value instanceof Timestamp) {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  if (typeof value === 'string' || typeof value === 'number') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return parsed;
    }
  }
  throw new HttpsError('invalid-argument', `${fieldName} must be a valid date`);
}

function toDateOrNull(value: unknown): Date | null {
  if (value == null) {
    return null;
  }
  if (value instanceof Timestamp) {
    return value.toDate();
  }
  if (value instanceof Date) {
    return value;
  }
  if (typeof value === 'string' || typeof value === 'number') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

function timestampOrNull(value: Date | null): Timestamp | null {
  return value ? Timestamp.fromDate(value) : null;
}

function buildDeepLink(target: `auction` | `orders` | `notifications`, id?: string) {
  if (target === 'notifications') {
    return 'app://notifications';
  }
  return id ? `app://${target}/${id}` : `app://${target}`;
}

async function createInboxNotification(
  uid: string,
  type: string,
  title: string,
  body: string,
  deeplink: string,
): Promise<void> {
  const ref = db.collection('notifications').doc(uid).collection('inbox').doc();
  await ref.set({
    type,
    title,
    body,
    deeplink,
    isRead: false,
    createdAt: FieldValue.serverTimestamp(),
  });
}

async function writeAuditEvent(event: AuditEventRecord): Promise<void> {
  await db.collection('auditEvents').add({
    ...event,
    createdAt: FieldValue.serverTimestamp(),
  });
}

function queueAuditEvent(
  tx: Transaction,
  event: AuditEventRecord,
): void {
  const ref = db.collection('auditEvents').doc();
  tx.set(ref, {
    ...event,
    createdAt: FieldValue.serverTimestamp(),
  });
}

function normalizedItemPayload(payload: AnyRecord): {
  status: 'DRAFT' | 'READY' | 'ARCHIVED';
  categoryMain: 'GOODS' | 'PRECIOUS';
  categorySub: string;
  title: string;
  description: string;
  condition: string;
  tags: string[];
  imageUrls: string[];
  authImageUrls: string[];
  isOfficialMd: boolean | null;
  draftAuction: {
    startPrice: number | null;
    buyNowPrice: number | null;
    durationDays: number | null;
  };
  appraisal: { status: 'NONE' | 'REQUESTED' | 'APPROVED' | 'REJECTED'; badgeLabel: string | null };
} {
  const categoryMain = ensureString(payload.categoryMain, 'categoryMain');
  if (categoryMain !== 'GOODS' && categoryMain !== 'PRECIOUS') {
    throw new HttpsError(
      'invalid-argument',
      'categoryMain must be GOODS or PRECIOUS',
    );
  }

  const status = optionalString(payload.status) ?? 'DRAFT';
  if (!['DRAFT', 'READY', 'ARCHIVED'].includes(status)) {
    throw new HttpsError('invalid-argument', 'invalid item status');
  }

  const imageUrls = stringArray(payload.imageUrls ?? payload.images);
  const authImageUrls = stringArray(
    payload.authImageUrls ?? payload.goodsAuthImages,
  );
  if (categoryMain === 'GOODS' && authImageUrls.length < 1) {
    throw new HttpsError(
      'invalid-argument',
      'GOODS requires at least one auth image',
    );
  }
  if (imageUrls.length > 10) {
    throw new HttpsError('invalid-argument', 'imageUrls max 10');
  }

  const appraisalPayload =
    payload.appraisal && typeof payload.appraisal === 'object'
      ? (payload.appraisal as AnyRecord)
      : {};
  const appraisalStatus = optionalString(appraisalPayload.status) ?? 'NONE';
  if (!['NONE', 'REQUESTED', 'APPROVED', 'REJECTED'].includes(appraisalStatus)) {
    throw new HttpsError('invalid-argument', 'invalid appraisal status');
  }

  const draftAuctionPayload =
    payload.draftAuction && typeof payload.draftAuction === 'object'
      ? (payload.draftAuction as AnyRecord)
      : {};
  const startPrice = optionalPositiveNumber(draftAuctionPayload.startPrice);
  const buyNowPrice = optionalPositiveNumber(draftAuctionPayload.buyNowPrice);
  const durationDays = optionalPositiveInteger(draftAuctionPayload.durationDays);
  if (startPrice != null && buyNowPrice != null && buyNowPrice <= startPrice) {
    throw new HttpsError(
      'invalid-argument',
      'draft buyNowPrice must be greater than startPrice',
    );
  }

  return {
    status: status as 'DRAFT' | 'READY' | 'ARCHIVED',
    categoryMain,
    categorySub: ensureString(payload.categorySub, 'categorySub'),
    title: ensureString(payload.title, 'title'),
    description: ensureString(payload.description, 'description'),
    condition: ensureString(payload.condition, 'condition'),
    tags: stringArray(payload.tags),
    imageUrls,
    authImageUrls,
    isOfficialMd:
      typeof payload.isOfficialMd === 'boolean' ? payload.isOfficialMd : null,
    draftAuction: {
      startPrice,
      buyNowPrice,
      durationDays,
    },
    appraisal: {
      status: appraisalStatus as
        | 'NONE'
        | 'REQUESTED'
        | 'APPROVED'
        | 'REJECTED',
      badgeLabel: optionalString(appraisalPayload.badgeLabel),
    },
  };
}

function serializeOrder(order: Omit<Order, 'id'> | Order): AnyRecord {
  return {
    auctionId: order.auctionId,
    itemId: order.itemId,
    buyerId: order.buyerId,
    sellerId: order.sellerId,
    finalPrice: order.finalPrice,
    paymentStatus: order.paymentStatus,
    orderStatus: order.orderStatus,
    paymentDueAt: Timestamp.fromDate(order.paymentDueAt),
    payment: {
      provider: order.payment.provider,
      paymentKey: order.payment.paymentKey,
      method: order.payment.method,
      approvedAt: timestampOrNull(order.payment.approvedAt),
      lastWebhookEventId: order.payment.lastWebhookEventId,
    },
    shipping: {
      carrierCode: order.shipping.carrierCode,
      carrierName: order.shipping.carrierName,
      trackingNumber: order.shipping.trackingNumber,
      trackingUrl: order.shipping.trackingUrl,
      shippedAt: timestampOrNull(order.shipping.shippedAt),
    },
    settlement: {
      expectedAt: timestampOrNull(order.settlement.expectedAt),
      settledAt: timestampOrNull(order.settlement.settledAt),
      payoutBatchId: order.settlement.payoutBatchId,
    },
    fees: order.fees,
  };
}

function deserializeOrder(id: string, data: AnyRecord): Order {
  const payment = ensureObject(data.payment ?? {}, 'payment is required');
  const shipping = ensureObject(data.shipping ?? {}, 'shipping is required');
  const settlement = ensureObject(
    data.settlement ?? {},
    'settlement is required',
  );
  const fees = ensureObject(data.fees ?? {}, 'fees is required');

  return {
    id,
    auctionId: ensureString(data.auctionId, 'auctionId'),
    itemId: ensureString(data.itemId, 'itemId'),
    buyerId: ensureString(data.buyerId, 'buyerId'),
    sellerId: ensureString(data.sellerId, 'sellerId'),
    finalPrice:
      typeof data.finalPrice === 'number' ? data.finalPrice : 0,
    paymentStatus: ensureString(
      data.paymentStatus,
      'paymentStatus',
    ) as Order['paymentStatus'],
    orderStatus: ensureString(
      data.orderStatus,
      'orderStatus',
    ) as Order['orderStatus'],
    paymentDueAt: toDate(data.paymentDueAt, 'paymentDueAt'),
    payment: {
      provider: 'TOSS_PAYMENTS',
      paymentKey: optionalString(payment.paymentKey),
      method: optionalString(payment.method),
      approvedAt: toDateOrNull(payment.approvedAt),
      lastWebhookEventId: optionalString(payment.lastWebhookEventId),
    },
    shipping: {
      carrierCode: optionalString(shipping.carrierCode),
      carrierName: optionalString(shipping.carrierName),
      trackingNumber: optionalString(shipping.trackingNumber),
      trackingUrl: optionalString(shipping.trackingUrl),
      shippedAt: toDateOrNull(shipping.shippedAt),
    },
    settlement: {
      expectedAt: toDateOrNull(settlement.expectedAt),
      settledAt: toDateOrNull(settlement.settledAt),
      payoutBatchId: optionalString(settlement.payoutBatchId),
    },
    fees: {
      feeRate: typeof fees.feeRate === 'number' ? fees.feeRate : 0,
      feeAmount: typeof fees.feeAmount === 'number' ? fees.feeAmount : 0,
      sellerReceivable:
        typeof fees.sellerReceivable === 'number' ? fees.sellerReceivable : 0,
    },
  };
}

async function confirmTossPayment(
  config: RuntimeConfig,
  input: {
    paymentKey: string;
    orderId: string;
    amount: number;
    idempotencyKey: string;
  },
): Promise<ConfirmTossPaymentResponse> {
  if (!config.tossSecretKey) {
    throw new HttpsError(
      'failed-precondition',
      'TOSS_SECRET_KEY is required to confirm payments.',
    );
  }

  const response = await fetch(`${config.tossApiBaseUrl}/v1/payments/confirm`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${Buffer.from(
        `${config.tossSecretKey}:`,
      ).toString('base64')}`,
      'Content-Type': 'application/json',
      'Idempotency-Key': input.idempotencyKey,
    },
    body: JSON.stringify({
      paymentKey: input.paymentKey,
      orderId: input.orderId,
      amount: input.amount,
    }),
  });

  const body = (await response.json()) as AnyRecord;
  if (!response.ok) {
    throw new HttpsError(
      'failed-precondition',
      ensureString(body.message ?? 'Toss confirm failed', 'toss message', {
        allowEmpty: true,
      }),
    );
  }

  const approvedAt = toDate(
    body.approvedAt ?? new Date().toISOString(),
    'approvedAt',
  );
  return {
    paymentKey: ensureString(body.paymentKey, 'paymentKey'),
    method: optionalString(body.method),
    approvedAt,
    totalAmount:
      typeof body.totalAmount === 'number' ? body.totalAmount : input.amount,
    status: ensureString(body.status ?? 'DONE', 'status'),
  };
}

function buildOrderName(auctionId: string): string {
  return `auction-${auctionId}`;
}

function providerListFromAuthToken(token: AnyRecord | undefined): string[] {
  const signInProvider =
    token &&
    token.firebase &&
    typeof (token.firebase as AnyRecord).sign_in_provider === 'string'
      ? ((token.firebase as AnyRecord).sign_in_provider as string)
      : null;
  return signInProvider ? [signInProvider] : [];
}

export const bootstrapUserProfile = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const token = (req.auth?.token ?? {}) as AnyRecord;
  const userRef = db.collection('users').doc(uid);

  const result = await db.runTransaction(async (tx) => {
    const snap = await tx.get(userRef);
    const existing = snap.data() as AnyRecord | undefined;
    const authProviders = Array.from(
      new Set([
        ...stringArray(existing?.authProviders),
        ...providerListFromAuthToken(token),
      ]),
    );

    tx.set(
      userRef,
      {
        displayName:
          optionalString(existing?.displayName) ??
          optionalString(token.name) ??
          optionalString(token.email?.toString().split('@')[0]) ??
          '회원',
        photoUrl: optionalString(existing?.photoUrl) ?? optionalString(token.picture),
        email: optionalString(token.email) ?? optionalString(existing?.email),
        phoneNumber:
          optionalString(token.phone_number) ?? optionalString(existing?.phoneNumber),
        authProviders,
        bio: optionalString(existing?.bio),
        preferences: {
          languageCode:
            optionalString(
              (existing?.preferences as AnyRecord | undefined)?.languageCode,
            ) ?? 'ko',
          pushEnabled:
            typeof (existing?.preferences as AnyRecord | undefined)?.pushEnabled ===
            'boolean'
              ? ((existing?.preferences as AnyRecord).pushEnabled as boolean)
              : true,
        },
        verification: {
          phone:
            optionalString((existing?.verification as AnyRecord | undefined)?.phone) ??
            'UNVERIFIED',
          id: optionalString((existing?.verification as AnyRecord | undefined)?.id) ??
            'UNVERIFIED',
          preciousSeller:
            optionalString(
              (existing?.verification as AnyRecord | undefined)?.preciousSeller,
            ) ?? 'UNVERIFIED',
        },
        sellerStats: {
          completedSales:
            typeof (existing?.sellerStats as AnyRecord | undefined)
              ?.completedSales === 'number'
              ? ((existing?.sellerStats as AnyRecord).completedSales as number)
              : 0,
          totalAuctions:
            typeof (existing?.sellerStats as AnyRecord | undefined)
              ?.totalAuctions === 'number'
              ? ((existing?.sellerStats as AnyRecord).totalAuctions as number)
              : 0,
          successRate:
            typeof (existing?.sellerStats as AnyRecord | undefined)
              ?.successRate === 'number'
              ? ((existing?.sellerStats as AnyRecord).successRate as number)
              : 0,
          reviewAvg:
            typeof (existing?.sellerStats as AnyRecord | undefined)?.reviewAvg ===
            'number'
              ? ((existing?.sellerStats as AnyRecord).reviewAvg as number)
              : 0,
          gradeScore:
            typeof (existing?.sellerStats as AnyRecord | undefined)?.gradeScore ===
            'number'
              ? ((existing?.sellerStats as AnyRecord).gradeScore as number)
              : 0,
        },
        penaltyStats: {
          unpaidCount:
            typeof (existing?.penaltyStats as AnyRecord | undefined)?.unpaidCount ===
            'number'
              ? ((existing?.penaltyStats as AnyRecord).unpaidCount as number)
              : 0,
          depositForfeitedCount:
            typeof (existing?.penaltyStats as AnyRecord | undefined)
              ?.depositForfeitedCount === 'number'
              ? ((existing?.penaltyStats as AnyRecord)
                  .depositForfeitedCount as number)
              : 0,
          trustScore:
            typeof (existing?.penaltyStats as AnyRecord | undefined)?.trustScore ===
            'number'
              ? ((existing?.penaltyStats as AnyRecord).trustScore as number)
              : 100,
        },
        ops: {
          roles: stringArray((existing?.ops as AnyRecord | undefined)?.roles),
          disabledAt:
            (existing?.ops as AnyRecord | undefined)?.disabledAt ?? null,
        },
        createdAt: existing?.createdAt ?? FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    queueAuditEvent(tx, {
      entityType: 'USER',
      entityId: uid,
      eventType: snap.exists ? 'USER_PROFILE_SYNCED' : 'USER_PROFILE_BOOTSTRAPPED',
      actorId: uid,
      payload: { authProviders },
    });

    return { created: !snap.exists };
  });

  logger.info('bootstrapUserProfile', { uid, created: result.created });
  return { uid, created: result.created };
});

export const createOrUpdateItem = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'item payload is required');
  const normalized = normalizedItemPayload(payload);
  const itemId = optionalString(payload.id);
  const itemRef = itemId
    ? db.collection('items').doc(itemId)
    : db.collection('items').doc();

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(itemRef);
    if (snap.exists && snap.data()?.sellerId !== uid) {
      throw new HttpsError('permission-denied', 'Only owner can update item');
    }

    tx.set(
      itemRef,
      {
        sellerId: uid,
        ...normalized,
        createdAt: snap.data()?.createdAt ?? FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    queueAuditEvent(tx, {
      entityType: 'AUCTION',
      entityId: itemRef.id,
      eventType: snap.exists ? 'ITEM_UPDATED' : 'ITEM_CREATED',
      actorId: uid,
      payload: {
        categoryMain: normalized.categoryMain,
        status: normalized.status,
      },
    });
  });

  return { itemId: itemRef.id };
});

export const createAuctionFromItem = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'auction payload is required');
  const itemId = ensureString(payload.itemId, 'itemId');
  const startAt = toDate(payload.startAt ?? Date.now(), 'startAt');
  const endAt = toDate(payload.endAt, 'endAt');
  const startPrice =
    typeof payload.startPrice === 'number' ? payload.startPrice : NaN;
  const buyNowPrice =
    typeof payload.buyNowPrice === 'number' ? payload.buyNowPrice : null;

  if (Number.isNaN(startPrice) || startPrice <= 0) {
    throw new HttpsError('invalid-argument', 'startPrice must be positive');
  }
  if (endAt <= startAt) {
    throw new HttpsError('invalid-argument', 'endAt must be after startAt');
  }
  if (buyNowPrice != null && buyNowPrice <= startPrice) {
    throw new HttpsError(
      'invalid-argument',
      'buyNowPrice must be greater than startPrice',
    );
  }

  const itemRef = db.collection('items').doc(itemId);
  const itemSnap = await itemRef.get();
  if (!itemSnap.exists) {
    throw new HttpsError('not-found', 'Item not found');
  }

  const item = itemSnap.data() as AnyRecord;
  if (item.sellerId !== uid) {
    throw new HttpsError(
      'permission-denied',
      'Only the seller can publish this item',
    );
  }

  const imageUrls = stringArray(item.imageUrls);
  const authImageUrls = stringArray(item.authImageUrls);
  if (!imageUrls.length) {
    throw new HttpsError('failed-precondition', 'At least one image is required');
  }
  if (item.categoryMain === 'GOODS' && authImageUrls.length < 1) {
    throw new HttpsError(
      'failed-precondition',
      'GOODS items require at least one auth image',
    );
  }

  const auctionRef = db.collection('auctions').doc();
  await db.runTransaction(async (tx) => {
    tx.set(auctionRef, {
      itemId,
      sellerId: uid,
      titleSnapshot: item.title,
      heroImageUrl: imageUrls[0],
      categoryMain: item.categoryMain,
      categorySub: item.categorySub,
      startPrice,
      buyNowPrice,
      currentPrice: startPrice,
      status: startAt > new Date() ? 'DRAFT' : 'LIVE',
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
      highestBidderId: null,
      orderId: null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.set(
      itemRef,
      {
        status: 'READY',
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    queueAuditEvent(tx, {
      entityType: 'AUCTION',
      entityId: auctionRef.id,
      eventType: 'AUCTION_PUBLISHED',
      actorId: uid,
      payload: {
        itemId,
        startPrice,
        buyNowPrice,
      },
    });
  });

  return { auctionId: auctionRef.id };
});

export const cancelAuction = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'cancel payload is required');
  const auctionId = ensureString(payload.auctionId, 'auctionId');
  const auctionRef = db.collection('auctions').doc(auctionId);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(auctionRef);
    if (!snap.exists) {
      throw new HttpsError('not-found', 'Auction not found');
    }
    const auction = snap.data()!;
    if (auction.sellerId !== uid) {
      throw new HttpsError('permission-denied', 'Only seller can cancel auction');
    }
    if (!['DRAFT', 'LIVE'].includes(auction.status)) {
      throw new HttpsError('failed-precondition', 'Auction cannot be cancelled');
    }
    if (auction.orderId) {
      throw new HttpsError(
        'failed-precondition',
        'Auction already has an order and cannot be cancelled',
      );
    }

    tx.update(auctionRef, {
      status: 'CANCELLED',
      updatedAt: FieldValue.serverTimestamp(),
    });
    queueAuditEvent(tx, {
      entityType: 'AUCTION',
      entityId: auctionId,
      eventType: 'AUCTION_CANCELLED',
      actorId: uid,
      payload: {},
    });
  });

  return { auctionId, status: 'CANCELLED' };
});

export const relistAuction = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'relist payload is required');
  const auctionId = ensureString(payload.auctionId, 'auctionId');
  const sourceRef = db.collection('auctions').doc(auctionId);
  const relistedRef = db.collection('auctions').doc();
  const startAt = toDate(payload.startAt ?? Date.now(), 'startAt');
  const endAt = toDate(
    payload.endAt ?? new Date(startAt.getTime() + 24 * 60 * 60 * 1000),
    'endAt',
  );

  await db.runTransaction(async (tx) => {
    const sourceSnap = await tx.get(sourceRef);
    if (!sourceSnap.exists) {
      throw new HttpsError('not-found', 'Auction not found');
    }

    const auction = sourceSnap.data()!;
    if (auction.sellerId !== uid) {
      throw new HttpsError('permission-denied', 'Only seller can relist auction');
    }
    if (!['UNSOLD', 'CANCELLED'].includes(auction.status)) {
      throw new HttpsError(
        'failed-precondition',
        'Only unsold or cancelled auctions can be relisted',
      );
    }

    tx.set(relistedRef, {
      itemId: auction.itemId,
      sellerId: uid,
      titleSnapshot: auction.titleSnapshot,
      heroImageUrl: auction.heroImageUrl,
      categoryMain: auction.categoryMain,
      categorySub: auction.categorySub,
      startPrice: auction.startPrice,
      buyNowPrice: auction.buyNowPrice ?? null,
      currentPrice: auction.startPrice,
      status: 'DRAFT',
      startAt: Timestamp.fromDate(startAt),
      endAt: Timestamp.fromDate(endAt),
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
      highestBidderId: null,
      orderId: null,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    queueAuditEvent(tx, {
      entityType: 'AUCTION',
      entityId: relistedRef.id,
      eventType: 'AUCTION_RELISTED',
      actorId: uid,
      payload: { sourceAuctionId: auctionId },
    });
  });

  return { auctionId: relistedRef.id };
});

export const placeBid = onCall(async (req) => {
  const bidderId = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'bid payload is required');
  const auctionId = ensureString(payload.auctionId, 'auctionId');
  const amount = typeof payload.amount === 'number' ? payload.amount : NaN;
  if (Number.isNaN(amount) || amount <= 0) {
    throw new HttpsError('invalid-argument', 'amount must be positive');
  }

  const auctionRef = db.collection('auctions').doc(auctionId);
  let outbidUserId: string | undefined;
  let finalPrice = amount;

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(auctionRef);
    if (!snap.exists) {
      throw new HttpsError('not-found', 'Auction not found');
    }

    const auctionData = snap.data()!;
    if (auctionData.sellerId === bidderId) {
      throw new HttpsError(
        'failed-precondition',
        'seller cannot bid own auction',
      );
    }

    const autoBidConfigs = featureFlags.autoBid
      ? (
          await tx.get(
            auctionRef.collection('autoBids').where('isEnabled', '==', true),
          )
        ).docs.map((doc) => {
          const config = doc.data() as AnyRecord;
          return {
            uid: doc.id,
            maxAmount:
              typeof config.maxAmount === 'number' ? config.maxAmount : 0,
            isEnabled: config.isEnabled === true,
          };
        })
      : [];

    const result = placeBidEngine({
      auction: {
        id: auctionId,
        itemId: ensureString(auctionData.itemId, 'itemId'),
        sellerId: ensureString(auctionData.sellerId, 'sellerId'),
        startPrice: auctionData.startPrice as number,
        buyNowPrice:
          typeof auctionData.buyNowPrice === 'number'
            ? (auctionData.buyNowPrice as number)
            : null,
        currentPrice: auctionData.currentPrice as number,
        status: auctionData.status,
        endAt: toDate(auctionData.endAt, 'endAt'),
        extendedCount: auctionData.extendedCount as number,
        bidCount: auctionData.bidCount as number,
        bidderCount: auctionData.bidderCount as number,
        highestBidderId: optionalString(auctionData.highestBidderId),
      },
      bidderId,
      amount,
      now: new Date(),
      autoBids: autoBidConfigs.map((config) => ({
        uid: config.uid,
        maxAmount: config.maxAmount,
        isEnabled: config.isEnabled,
      })),
    });

    outbidUserId = result.outbidUserId;
    finalPrice = result.auction.currentPrice;

    tx.update(auctionRef, {
      currentPrice: result.auction.currentPrice,
      highestBidderId: result.auction.highestBidderId,
      bidCount: result.auction.bidCount,
      bidderCount: result.auction.bidderCount,
      endAt: Timestamp.fromDate(result.auction.endAt),
      extendedCount: result.auction.extendedCount,
      updatedAt: FieldValue.serverTimestamp(),
    });

    for (const bid of result.bids) {
      tx.set(auctionRef.collection('bids').doc(), {
        bidderId: bid.bidderId,
        amount: bid.amount,
        kind: bid.kind,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    queueAuditEvent(tx, {
      entityType: 'AUCTION',
      entityId: auctionId,
      eventType: 'BID_PLACED',
      actorId: bidderId,
      payload: { amount: result.auction.currentPrice, bidCount: result.bids.length },
    });
  });

  if (outbidUserId && outbidUserId !== bidderId) {
    await createInboxNotification(
      outbidUserId,
      'OUTBID',
      '입찰가가 갱신되었습니다',
      `현재 최고가 ${finalPrice}원`,
      buildDeepLink('auction', auctionId),
    );
  }

  return { ok: true, auctionId, currentPrice: finalPrice };
});

export const setAutoBid = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'auto bid payload is required');
  const auctionId = ensureString(payload.auctionId, 'auctionId');
  const disable = payload.disable === true;
  const maxAmount =
    typeof payload.maxAmount === 'number' ? payload.maxAmount : null;
  const auctionRef = db.collection('auctions').doc(auctionId);
  const autoBidRef = auctionRef.collection('autoBids').doc(uid);

  await db.runTransaction(async (tx) => {
    const auctionSnap = await tx.get(auctionRef);
    if (!auctionSnap.exists) {
      throw new HttpsError('not-found', 'Auction not found');
    }

    const auction = auctionSnap.data()!;
    if (auction.status !== 'LIVE') {
      throw new HttpsError('failed-precondition', 'auction is not live');
    }
    if (auction.sellerId === uid) {
      throw new HttpsError(
        'failed-precondition',
        'seller cannot set auto bid',
      );
    }
    if (!disable && (maxAmount == null || maxAmount <= 0)) {
      throw new HttpsError(
        'invalid-argument',
        'maxAmount must be positive when enabling auto bid',
      );
    }

    const existing = await tx.get(autoBidRef);
    tx.set(
      autoBidRef,
      {
        maxAmount: disable ? 0 : maxAmount,
        isEnabled: !disable,
        createdAt: existing.data()?.createdAt ?? FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });

  return { ok: true };
});

export const buyNow = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'buyNow payload is required');
  const auctionId = ensureString(payload.auctionId, 'auctionId');
  const auctionRef = db.collection('auctions').doc(auctionId);

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(auctionRef);
    if (!snap.exists) {
      throw new HttpsError('not-found', 'Auction not found');
    }

    const auction = snap.data()!;
    if (auction.status !== 'LIVE') {
      throw new HttpsError('failed-precondition', 'auction not live');
    }
    if (!auction.buyNowPrice) {
      throw new HttpsError('failed-precondition', 'buyNow not available');
    }
    if (auction.sellerId === uid) {
      throw new HttpsError(
        'failed-precondition',
        'seller cannot buy own auction',
      );
    }
    if (auction.orderId) {
      throw new HttpsError(
        'already-exists',
        'order already exists for this auction',
      );
    }

    const orderRef = db.collection('orders').doc();
    const order = {
      ...toAwaitingPaymentOrder(
        {
          id: auctionId,
          itemId: ensureString(auction.itemId, 'itemId'),
          sellerId: ensureString(auction.sellerId, 'sellerId'),
          status: auction.status,
          endAt: toDate(auction.endAt, 'endAt'),
          currentPrice: auction.buyNowPrice as number,
          highestBidderId: uid,
        },
        new Date(),
      ),
      finalPrice: auction.buyNowPrice as number,
      fees: buildOrderFees(auction.buyNowPrice as number),
    };

    tx.set(orderRef, {
      ...serializeOrder(order),
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.update(auctionRef, {
      status: 'ENDED',
      highestBidderId: uid,
      currentPrice: auction.buyNowPrice,
      orderId: orderRef.id,
      updatedAt: FieldValue.serverTimestamp(),
    });
    queueAuditEvent(tx, {
      entityType: 'ORDER',
      entityId: orderRef.id,
      eventType: 'BUY_NOW_ORDER_CREATED',
      actorId: uid,
      payload: { auctionId, finalPrice: auction.buyNowPrice },
    });

    return { orderId: orderRef.id };
  });
});

export const createPaymentSession = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'payment session payload is required');
  const orderId = ensureString(payload.orderId, 'orderId');
  const config = getRuntimeConfig();
  const orderSnap = await db.collection('orders').doc(orderId).get();
  if (!orderSnap.exists) {
    throw new HttpsError('not-found', 'Order not found');
  }

  const order = deserializeOrder(orderSnap.id, orderSnap.data() as AnyRecord);
  if (order.buyerId !== uid) {
    throw new HttpsError('permission-denied', 'Only buyer can start payment');
  }
  if (order.orderStatus !== 'AWAITING_PAYMENT') {
    throw new HttpsError(
      'failed-precondition',
      'Order is not awaiting payment',
    );
  }
  if (config.appEnv !== 'dev' && !config.appBaseUrl) {
    throw new HttpsError(
      'failed-precondition',
      'APP_BASE_URL is required outside dev builds.',
    );
  }

  const successUrl = config.appBaseUrl
    ? `${config.appBaseUrl.replace(/\/$/, '')}/payments/success?orderId=${orderId}`
    : null;
  const failUrl = config.appBaseUrl
    ? `${config.appBaseUrl.replace(/\/$/, '')}/payments/fail?orderId=${orderId}`
    : null;

  return {
    provider: 'TOSS_PAYMENTS',
    orderId,
    amount: order.finalPrice,
    orderName: buildOrderName(order.auctionId),
    customerName: optionalString(req.auth?.token?.name) ?? null,
    customerEmail: optionalString(req.auth?.token?.email) ?? null,
    successUrl,
    failUrl,
  };
});

export const confirmOrderPayment = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'payment confirmation payload is required');
  const orderId = ensureString(payload.orderId, 'orderId');
  const paymentKey = ensureString(payload.paymentKey, 'paymentKey');
  const amount = typeof payload.amount === 'number' ? payload.amount : NaN;
  if (Number.isNaN(amount) || amount <= 0) {
    throw new HttpsError('invalid-argument', 'amount must be positive');
  }

  const config = getRuntimeConfig();
  const orderRef = db.collection('orders').doc(orderId);
  const orderSnap = await orderRef.get();
  if (!orderSnap.exists) {
    throw new HttpsError('not-found', 'Order not found');
  }

  const order = deserializeOrder(orderSnap.id, orderSnap.data() as AnyRecord);
  if (order.buyerId !== uid) {
    throw new HttpsError('permission-denied', 'Only buyer can confirm payment');
  }
  if (order.finalPrice !== amount) {
    throw new HttpsError(
      'failed-precondition',
      'Confirmed amount does not match order finalPrice',
    );
  }
  if (isDuplicatePaymentConfirmation(order, paymentKey, amount)) {
    return { ok: true, idempotent: true, orderId };
  }
  if (order.orderStatus !== 'AWAITING_PAYMENT') {
    throw new HttpsError(
      'failed-precondition',
      'Order is not awaiting payment',
    );
  }

  let payment: ConfirmTossPaymentResponse;
  try {
    payment = await confirmTossPayment(config, {
      paymentKey,
      orderId,
      amount,
      idempotencyKey: `order:${orderId}:confirm`,
    });
  } catch (error) {
    const failedOrder = toFailedPaymentOrder(order);
    await orderRef.update({
      paymentStatus: failedOrder.paymentStatus,
      updatedAt: FieldValue.serverTimestamp(),
    });
    await writeAuditEvent({
      entityType: 'PAYMENT',
      entityId: paymentKey,
      eventType: 'PAYMENT_CONFIRM_FAILED',
      actorId: uid,
      payload: { orderId, amount, message: String(error) },
    });
    throw error;
  }

  const nextOrder = toConfirmedPaymentOrder(order, payment, null);
  await orderRef.update({
    ...serializeOrder(nextOrder),
    updatedAt: FieldValue.serverTimestamp(),
  });

  await createInboxNotification(
    order.sellerId,
    'PAYMENT_COMPLETED',
    '결제 완료',
    '구매자 결제가 완료되었습니다.',
    buildDeepLink('orders', orderId),
  );
  await writeAuditEvent({
    entityType: 'PAYMENT',
    entityId: paymentKey,
    eventType: 'PAYMENT_CONFIRMED',
    actorId: uid,
    payload: { orderId, amount, status: payment.status },
  });
  logger.info('confirmOrderPayment', { orderId, paymentKey, uid });
  return { ok: true, orderId };
});

export const tossPaymentWebhook = onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  const config = getRuntimeConfig();
  if (!config.tossWebhookSecret) {
    res.status(503).send('Webhook secret not configured');
    return;
  }

  const payload = ensureObject(req.body, 'webhook body is required');
  const eventType =
    optionalString(payload.eventType) ?? optionalString(payload.type) ?? 'UNKNOWN';
  const payment = normalizeWebhookPayment(payload);
  if (!payment || !payment.orderId) {
    res.status(200).json({ ok: true, ignored: true });
    return;
  }

  const webhookSecret = extractWebhookSecret(payload) ?? payment.secret;
  if (webhookSecret !== config.tossWebhookSecret) {
    res.status(401).json({ ok: false, reason: 'invalid webhook secret' });
    return;
  }

  const eventMarker = buildWebhookEventMarker(
    eventType,
    optionalString(payload.createdAt),
    payment.paymentKey,
    payment.status,
  );
  const orderRef = db.collection('orders').doc(payment.orderId);
  const orderSnap = await orderRef.get();
  if (!orderSnap.exists) {
    res.status(200).json({ ok: true, ignored: true });
    return;
  }

  const order = deserializeOrder(orderSnap.id, orderSnap.data() as AnyRecord);
  if (order.payment.lastWebhookEventId === eventMarker) {
    res.status(200).json({ ok: true, duplicate: true });
    return;
  }

  if (
    payment.status === 'DONE' &&
    payment.paymentKey &&
    payment.totalAmount != null &&
    payment.approvedAt
  ) {
    const isDuplicateDone = isDuplicatePaymentConfirmation(
      order,
      payment.paymentKey,
      payment.totalAmount,
    );
    const nextOrder = isDuplicateDone
      ? withLastWebhookEventId(order, eventMarker)
      : toConfirmedPaymentOrder(
          order,
          {
            paymentKey: payment.paymentKey,
            method: payment.method,
            approvedAt: payment.approvedAt,
            totalAmount: payment.totalAmount,
            status: payment.status,
          },
          eventMarker,
        );
    await orderRef.update({
      ...serializeOrder(nextOrder),
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (!isDuplicateDone) {
      await createInboxNotification(
        order.sellerId,
        'PAYMENT_COMPLETED',
        '결제 완료',
        '구매자 결제가 완료되었습니다.',
        buildDeepLink('orders', order.id),
      );
      await writeAuditEvent({
        entityType: 'PAYMENT',
        entityId: payment.paymentKey,
        eventType: 'PAYMENT_WEBHOOK_DONE',
        actorId: null,
        payload: { orderId: order.id, eventMarker },
      });
    }
  } else if (
    payment.status &&
    ['CANCELED', 'ABORTED', 'EXPIRED'].includes(payment.status)
  ) {
    const cancelledOrder = toCancelledPaymentOrder(order, eventMarker);
    await orderRef.update({
      ...serializeOrder(cancelledOrder),
      updatedAt: FieldValue.serverTimestamp(),
    });
    await writeAuditEvent({
      entityType: 'PAYMENT',
      entityId: payment.paymentKey ?? order.id,
      eventType: 'PAYMENT_WEBHOOK_CANCELLED',
      actorId: null,
      payload: { orderId: order.id, status: payment.status, eventMarker },
    });
  }

  logger.info('tossPaymentWebhook', {
    orderId: order.id,
    eventType,
    status: payment.status,
  });
  res.status(200).json({ ok: true });
});

export const shipmentUpdate = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'shipment payload is required');
  const orderId = ensureString(payload.orderId, 'orderId');
  const carrierCode = optionalString(payload.carrierCode) ?? 'CUSTOM';
  const carrierName = ensureString(
    payload.carrierName ?? payload.carrier ?? carrierCode,
    'carrierName',
  );
  const trackingNumber = ensureString(payload.trackingNumber, 'trackingNumber');
  const trackingUrl = optionalString(payload.trackingUrl);
  const ref = db.collection('orders').doc(orderId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Order not found');
  }

  const order = deserializeOrder(snap.id, snap.data() as AnyRecord);
  if (order.sellerId !== uid) {
    throw new HttpsError('permission-denied', 'Only seller can update shipment');
  }
  if (order.orderStatus !== 'PAID_ESCROW_HOLD') {
    throw new HttpsError(
      'failed-precondition',
      'Order is not in a shippable state',
    );
  }

  await ref.update({
    orderStatus: 'SHIPPED',
    shipping: {
      carrierCode,
      carrierName,
      trackingNumber,
      trackingUrl,
      shippedAt: FieldValue.serverTimestamp(),
    },
    updatedAt: FieldValue.serverTimestamp(),
  });
  await createInboxNotification(
    order.buyerId,
    'SHIPPED',
    '배송이 시작되었습니다',
    `${carrierName} ${trackingNumber}`,
    buildDeepLink('orders', orderId),
  );
  await writeAuditEvent({
    entityType: 'ORDER',
    entityId: orderId,
    eventType: 'ORDER_SHIPPED',
    actorId: uid,
    payload: { carrierCode, trackingNumber },
  });

  return { ok: true };
});

export const confirmReceipt = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'receipt payload is required');
  const orderId = ensureString(payload.orderId, 'orderId');
  const ref = db.collection('orders').doc(orderId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Order not found');
  }

  const order = deserializeOrder(snap.id, snap.data() as AnyRecord);
  if (order.buyerId !== uid) {
    throw new HttpsError('permission-denied', 'Only buyer can confirm receipt');
  }
  if (order.orderStatus !== 'SHIPPED') {
    throw new HttpsError(
      'failed-precondition',
      'Order is not in a shipped state',
    );
  }

  const expectedAt = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000);
  await ref.update({
    orderStatus: 'CONFIRMED_RECEIPT',
    settlement: {
      ...order.settlement,
      expectedAt: Timestamp.fromDate(expectedAt),
      settledAt: null,
      payoutBatchId: null,
    },
    updatedAt: FieldValue.serverTimestamp(),
  });
  await writeAuditEvent({
    entityType: 'ORDER',
    entityId: orderId,
    eventType: 'ORDER_RECEIPT_CONFIRMED',
    actorId: uid,
    payload: { expectedAt: expectedAt.toISOString() },
  });

  return { ok: true };
});

export const markNotificationRead = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'notification payload is required');
  const notificationId = ensureString(payload.notificationId, 'notificationId');
  const notificationRef = db
    .collection('notifications')
    .doc(uid)
    .collection('inbox')
    .doc(notificationId);
  const snap = await notificationRef.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Notification not found');
  }
  await notificationRef.update({
    isRead: true,
  });
  return { ok: true };
});

export const activateDraftAuctionsScheduler = onSchedule(
  'every 5 minutes',
  async () => {
    const now = Timestamp.fromDate(new Date());
    const snap = await db
      .collection('auctions')
      .where('status', '==', 'DRAFT')
      .where('startAt', '<=', now)
      .get();

    for (const doc of snap.docs) {
      await doc.ref.update({
        status: 'LIVE',
        updatedAt: FieldValue.serverTimestamp(),
      });
      await writeAuditEvent({
        entityType: 'AUCTION',
        entityId: doc.id,
        eventType: 'AUCTION_ACTIVATED',
        actorId: null,
        payload: {},
      });
    }
  },
);

export const finalizeAuctionsScheduler = onSchedule(
  'every 5 minutes',
  async () => {
    const now = new Date();
    const snap = await db
      .collection('auctions')
      .where('status', '==', 'LIVE')
      .where('endAt', '<=', Timestamp.fromDate(now))
      .get();

    for (const doc of snap.docs) {
      const notification = await db.runTransaction(async (tx) => {
        const freshAuctionSnap = await tx.get(doc.ref);
        if (!freshAuctionSnap.exists) {
          return null;
        }
        const data = freshAuctionSnap.data()!;
        const decision = finalizeAuction(
          {
            id: freshAuctionSnap.id,
            itemId: ensureString(data.itemId, 'itemId'),
            sellerId: ensureString(data.sellerId, 'sellerId'),
            status: data.status,
            endAt: toDate(data.endAt, 'endAt'),
            currentPrice: data.currentPrice as number,
            highestBidderId: optionalString(data.highestBidderId),
          },
          now,
        );

        if (!decision.shouldFinalize) {
          return null;
        }

        if (decision.nextStatus === 'ENDED' && data.highestBidderId) {
          if (data.orderId) {
            tx.update(doc.ref, {
              status: 'ENDED',
              updatedAt: FieldValue.serverTimestamp(),
            });
            return null;
          }

          const order = toAwaitingPaymentOrder(
            {
              id: freshAuctionSnap.id,
              itemId: ensureString(data.itemId, 'itemId'),
              sellerId: ensureString(data.sellerId, 'sellerId'),
              status: data.status,
              endAt: toDate(data.endAt, 'endAt'),
              currentPrice: data.currentPrice as number,
              highestBidderId: ensureString(data.highestBidderId, 'highestBidderId'),
            },
            now,
          );
          const orderRef = db.collection('orders').doc();

          tx.set(orderRef, {
            ...serializeOrder(order),
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          });
          tx.update(doc.ref, {
            status: 'ENDED',
            orderId: orderRef.id,
            updatedAt: FieldValue.serverTimestamp(),
          });
          queueAuditEvent(tx, {
            entityType: 'ORDER',
            entityId: orderRef.id,
            eventType: 'ORDER_CREATED_FROM_AUCTION_FINALIZE',
            actorId: null,
            payload: { auctionId: freshAuctionSnap.id },
          });

          return { buyerId: order.buyerId, orderId: orderRef.id };
        }

        tx.update(doc.ref, {
          status: decision.nextStatus,
          updatedAt: FieldValue.serverTimestamp(),
        });
        queueAuditEvent(tx, {
          entityType: 'AUCTION',
          entityId: freshAuctionSnap.id,
          eventType:
            decision.nextStatus === 'UNSOLD' ? 'AUCTION_UNSOLD' : 'AUCTION_ENDED',
          actorId: null,
          payload: {},
        });
        return null;
      });

      if (notification) {
        await createInboxNotification(
          notification.buyerId,
          'WON',
          '낙찰되었습니다',
          '결제 기한 내 결제를 진행해주세요.',
          buildDeepLink('orders', notification.orderId),
        );
      }
    }
  },
);

export const expireUnpaidOrdersScheduler = onSchedule(
  'every 10 minutes',
  async () => {
    const now = new Date();
    const snap = await db
      .collection('orders')
      .where('orderStatus', '==', 'AWAITING_PAYMENT')
      .where('paymentDueAt', '<=', Timestamp.fromDate(now))
      .get();

    for (const doc of snap.docs) {
      const shouldNotify = await db.runTransaction(async (tx) => {
        const orderSnap = await tx.get(doc.ref);
        if (!orderSnap.exists) {
          return false;
        }
        const order = deserializeOrder(
          orderSnap.id,
          orderSnap.data() as AnyRecord,
        );
        const updatedOrder = expireUnpaidOrders(now, [order])[0];
        if (updatedOrder.orderStatus !== 'CANCELLED_UNPAID') {
          return false;
        }

        const userRef = db.collection('users').doc(order.buyerId);
        const userSnap = await tx.get(userRef);
        const userPenaltyStats = ensureObject(
          userSnap.data()?.penaltyStats ?? {},
          'penaltyStats',
        );
        const penalty = applyUnpaidPenalty(
          {
            unpaidCount:
              typeof userPenaltyStats.unpaidCount === 'number'
                ? (userPenaltyStats.unpaidCount as number)
                : 0,
            depositForfeitedCount:
              typeof userPenaltyStats.depositForfeitedCount === 'number'
                ? (userPenaltyStats.depositForfeitedCount as number)
                : 0,
            trustScore:
              typeof userPenaltyStats.trustScore === 'number'
                ? (userPenaltyStats.trustScore as number)
                : 100,
          },
          order.finalPrice,
        );

        tx.update(doc.ref, {
          paymentStatus: updatedOrder.paymentStatus,
          orderStatus: updatedOrder.orderStatus,
          updatedAt: FieldValue.serverTimestamp(),
        });
        tx.set(
          userRef,
          {
            penaltyStats: {
              unpaidCount: penalty.unpaidCount,
              depositForfeitedCount: penalty.depositForfeitedCount,
              trustScore: penalty.trustScore,
            },
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
        queueAuditEvent(tx, {
          entityType: 'ORDER',
          entityId: doc.id,
          eventType: 'ORDER_EXPIRED_UNPAID',
          actorId: null,
          payload: { forfeited: penalty.forfeited },
        });
        return true;
      });

      if (shouldNotify) {
        await createInboxNotification(
          doc.data().buyerId,
          'PAYMENT_DUE',
          '결제 기한이 만료되었습니다',
          '미결제로 주문이 취소되었고 패널티가 반영되었습니다.',
          buildDeepLink('orders', doc.id),
        );
      }
    }
  },
);

export const settleScheduler = onSchedule('every 60 minutes', async () => {
  const now = new Date();
  const snap = await db
    .collection('orders')
    .where('orderStatus', '==', 'CONFIRMED_RECEIPT')
    .get();

  for (const doc of snap.docs) {
    const order = deserializeOrder(doc.id, doc.data() as AnyRecord);
    const expectedAt = order.settlement.expectedAt;
    if (!expectedAt || !shouldSettle(order.orderStatus, expectedAt, now)) {
      continue;
    }

    await doc.ref.update({
      orderStatus: 'SETTLED',
      settlement: {
        ...order.settlement,
        expectedAt: timestampOrNull(expectedAt),
        settledAt: Timestamp.fromDate(now),
      },
      updatedAt: FieldValue.serverTimestamp(),
    });
    await createInboxNotification(
      order.sellerId,
      'SETTLED',
      '정산 완료',
      `주문 ${doc.id} 정산이 완료되었습니다.`,
      buildDeepLink('orders', doc.id),
    );
    await writeAuditEvent({
      entityType: 'ORDER',
      entityId: doc.id,
      eventType: 'ORDER_SETTLED',
      actorId: null,
      payload: {},
    });
  }
});
