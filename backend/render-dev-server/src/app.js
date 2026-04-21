import express from 'express';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

import { AppError, isAppError } from './errors.js';
import {
  buildNotificationCopy,
  normalizeNotificationLocale,
  resolveNotificationLocale,
} from './notificationCopy.js';

const featureFlags = {
  autoBid: true,
};

const bidIncrementTable = [
  { min: 0, max: 99999, step: 1000 },
  { min: 100000, max: 499999, step: 5000 },
  { min: 500000, max: 999999, step: 10000 },
  { min: 1000000, max: Number.MAX_SAFE_INTEGER, step: 50000 },
];

const antiSnipingPolicy = {
  triggerSecondsBeforeEnd: 300,
  extensionSeconds: 300,
  maxExtensions: 3,
};

const depositPolicy = {
  percent: 0.05,
};

function meaningfulString(value) {
  if (typeof value !== 'string') {
    return null;
  }

  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

function ensureObject(value, message) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new AppError('invalid-argument', message);
  }
  return value;
}

function ensureString(value, fieldName, options = {}) {
  if (typeof value !== 'string') {
    throw new AppError('invalid-argument', `${fieldName} must be a string`);
  }

  const trimmed = value.trim();
  if (!options.allowEmpty && trimmed.length === 0) {
    throw new AppError('invalid-argument', `${fieldName} is required`);
  }
  return trimmed;
}

function optionalString(value) {
  return typeof value === 'string' && value.trim() ? value.trim() : null;
}

function ensureEnumString(value, fieldName, allowed) {
  const normalized = ensureString(value, fieldName);
  if (!allowed.includes(normalized)) {
    throw new AppError(
      'invalid-argument',
      `${fieldName} must be one of ${allowed.join(', ')}`,
    );
  }
  return normalized;
}

function optionalPositiveNumber(value) {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return null;
  }
  return value > 0 ? value : null;
}

function optionalPositiveInteger(value) {
  if (typeof value !== 'number' || Number.isNaN(value)) {
    return null;
  }
  if (!Number.isInteger(value) || value <= 0) {
    return null;
  }
  return value;
}

function stringArray(value) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter((entry) => typeof entry === 'string');
}

function toDate(value, fieldName) {
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

  throw new AppError('invalid-argument', `${fieldName} must be a valid date`);
}

function toDateOrNull(value) {
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

function timestampOrNull(value) {
  return value ? Timestamp.fromDate(value) : null;
}

function buildDeepLink(target, id) {
  if (target === 'notifications') {
    return 'app://notifications';
  }
  return id ? `app://${target}/${id}` : `app://${target}`;
}

function buildDevPaymentKey(orderId) {
  return `dev_pay_${orderId}`;
}

function buildTossCustomerKey(uid) {
  return `buyer_${uid}`;
}

const notificationCategoryByType = {
  OUTBID: 'auctionActivity',
  AUTO_BID_CEILING_REACHED: 'auctionActivity',
  WON: 'orderPayment',
  BUY_NOW_COMPLETED: 'orderPayment',
  ORDER_AWAITING_PAYMENT: 'orderPayment',
  PAYMENT_COMPLETED: 'orderPayment',
  PAYMENT_DUE: 'orderPayment',
  PAYMENT_FAILED: 'orderPayment',
  SHIPMENT_REMINDER: 'shippingAndReceipt',
  SHIPPED: 'shippingAndReceipt',
  RECEIPT_REMINDER: 'shippingAndReceipt',
  RECEIPT_CONFIRMED: 'shippingAndReceipt',
  SETTLED: 'shippingAndReceipt',
  SYSTEM_TEST: 'system',
};

const defaultNotificationCategories = {
  auctionActivity: true,
  orderPayment: true,
  shippingAndReceipt: true,
  system: true,
};

function getNotificationCategoryForType(type) {
  const category = notificationCategoryByType[type];
  if (!category) {
    throw new AppError(
      'failed-precondition',
      `Unsupported notification type: ${type}`,
    );
  }
  return category;
}

function normalizeNotificationPreferences(userData) {
  const root = userData && typeof userData === 'object' ? userData : {};
  const preferences =
    root.preferences && typeof root.preferences === 'object'
      ? root.preferences
      : {};
  const notificationCategories =
    preferences.notificationCategories &&
    typeof preferences.notificationCategories === 'object'
      ? preferences.notificationCategories
      : {};

  return {
    pushEnabled:
      typeof preferences.pushEnabled === 'boolean'
        ? preferences.pushEnabled
        : true,
    notificationCategories: {
      auctionActivity:
        typeof notificationCategories.auctionActivity === 'boolean'
          ? notificationCategories.auctionActivity
          : defaultNotificationCategories.auctionActivity,
      orderPayment:
        typeof notificationCategories.orderPayment === 'boolean'
          ? notificationCategories.orderPayment
          : defaultNotificationCategories.orderPayment,
      shippingAndReceipt:
        typeof notificationCategories.shippingAndReceipt === 'boolean'
          ? notificationCategories.shippingAndReceipt
          : defaultNotificationCategories.shippingAndReceipt,
      system:
        typeof notificationCategories.system === 'boolean'
          ? notificationCategories.system
          : defaultNotificationCategories.system,
    },
  };
}

function isDeliverablePermissionStatus(status) {
  return status === 'AUTHORIZED' || status === 'PROVISIONAL';
}

function getDeliverableTokens(candidates) {
  const seen = new Set();
  const tokens = [];

  for (const candidate of candidates) {
    const token = meaningfulString(candidate.token);
    if (!token || seen.has(token)) {
      continue;
    }
    if (!candidate.isActive) {
      continue;
    }
    if (!isDeliverablePermissionStatus(candidate.permissionStatus)) {
      continue;
    }
    seen.add(token);
    tokens.push(token);
  }

  return tokens;
}

function getTimestampMillis(value) {
  if (value instanceof Timestamp) {
    return value.toMillis();
  }
  if (value instanceof Date) {
    return value.getTime();
  }
  if (value && typeof value.toMillis === 'function') {
    return value.toMillis();
  }
  return 0;
}

function timestampJsonValue(value) {
  if (value == null) {
    return null;
  }
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }
  if (value instanceof Date) {
    return value.toISOString();
  }
  if (value && typeof value.toDate === 'function') {
    return value.toDate().toISOString();
  }
  if (typeof value === 'string') {
    return value;
  }
  if (typeof value === 'number') {
    return new Date(value).toISOString();
  }
  return null;
}

function sortTokenCandidates(candidates) {
  return [...candidates].sort((left, right) => {
    const updatedAtDiff =
      getTimestampMillis(right.updatedAt) - getTimestampMillis(left.updatedAt);
    if (updatedAtDiff !== 0) {
      return updatedAtDiff;
    }
    const lastSeenAtDiff =
      getTimestampMillis(right.lastSeenAt) - getTimestampMillis(left.lastSeenAt);
    if (lastSeenAtDiff !== 0) {
      return lastSeenAtDiff;
    }
    const leftToken = meaningfulString(left.token) ?? '';
    const rightToken = meaningfulString(right.token) ?? '';
    return leftToken.localeCompare(rightToken);
  });
}

function parseTokenCandidate(data) {
  return {
    token: typeof data.token === 'string' ? data.token : null,
    isActive: data.isActive === true,
    permissionStatus:
      typeof data.permissionStatus === 'string' ? data.permissionStatus : null,
    locale: typeof data.locale === 'string' ? data.locale : null,
    updatedAt: data.updatedAt ?? null,
    lastSeenAt: data.lastSeenAt ?? null,
  };
}

function resolveUserNotificationLocale(userData, tokenCandidates) {
  const preferences =
    userData &&
    typeof userData === 'object' &&
    userData.preferences &&
    typeof userData.preferences === 'object'
      ? userData.preferences
      : {};
  const sortedCandidates = sortTokenCandidates(tokenCandidates);
  const tokenLocales = sortedCandidates
    .filter((candidate) => candidate.isActive)
    .map((candidate) => candidate.locale);
  const preferredLanguageCode = meaningfulString(preferences.languageCode);
  const hasExplicitLanguagePreference =
    preferences.hasExplicitLanguagePreference === true;
  const normalizedPreferredLanguageCode =
    normalizeNotificationLocale(preferredLanguageCode);
  const hasEnglishTokenLocale = tokenLocales.some(
    (locale) => normalizeNotificationLocale(locale) === 'en',
  );
  const userLanguageCode =
    !hasExplicitLanguagePreference &&
    normalizedPreferredLanguageCode === 'ko' &&
    hasEnglishTokenLocale
      ? null
      : preferredLanguageCode;
  return resolveNotificationLocale({
    userLanguageCode,
    tokenLocales,
  });
}

function shouldDispatchPush(preferences, category, tokenCount) {
  if (!preferences.pushEnabled) {
    return false;
  }
  if (!preferences.notificationCategories[category]) {
    return false;
  }
  return tokenCount > 0;
}

function buildPushDataPayload(input) {
  return {
    notificationId: input.notificationId,
    type: input.type,
    category: input.category,
    deeplink: input.deeplink,
    entityType: input.entityType,
    entityId: input.entityId,
    timestamp: input.timestamp,
  };
}

async function createInboxNotification(
  db,
  uid,
  type,
  deeplink,
  options = {},
) {
  const userRef = db.collection('users').doc(uid);
  const tokenCollectionRef = userRef.collection('deviceTokens');
  const [userSnap, tokenSnap] = await Promise.all([
    userRef.get(),
    tokenCollectionRef.get(),
  ]);
  const tokenCandidates = tokenSnap.docs.map((doc) => parseTokenCandidate(doc.data()));
  const locale = resolveUserNotificationLocale(userSnap.data(), tokenCandidates);
  const copy = buildNotificationCopy(type, locale, options.copyContext);
  if (!copy) {
    throw new AppError(
      'failed-precondition',
      `Unsupported notification type copy: ${type}`,
    );
  }
  const ref = db.collection('notifications').doc(uid).collection('inbox').doc();
  const category = getNotificationCategoryForType(type);
  const entityType = options.entityType ?? null;
  const entityId = options.entityId ?? null;
  await ref.set({
    type,
    category,
    title: copy.title,
    body: copy.body,
    deeplink,
    ...(entityType ? { entityType } : {}),
    ...(entityId ? { entityId } : {}),
    isRead: false,
    createdAt: FieldValue.serverTimestamp(),
  });

  return {
    notificationId: ref.id,
    type,
    category,
    title: copy.title,
    body: copy.body,
    deeplink,
    entityType,
    entityId,
    locale,
  };
}

async function dispatchPushForInboxNotification(services, input) {
  const userRef = services.db.collection('users').doc(input.uid);
  const tokenCollectionRef = userRef.collection('deviceTokens');
  const [userSnap, tokenSnap] = await Promise.all([
    userRef.get(),
    tokenCollectionRef.get(),
  ]);

  const preferences = normalizeNotificationPreferences(userSnap.data());
  const tokenCandidates = tokenSnap.docs.map((doc) => parseTokenCandidate(doc.data()));
  const tokens = getDeliverableTokens(tokenCandidates);

  if (!shouldDispatchPush(preferences, input.category, tokens.length)) {
    return {
      attempted: false,
      tokenCount: tokens.length,
    };
  }

  const messaging = services.messaging ?? getMessaging();
  await messaging.sendEachForMulticast({
    tokens,
    notification: {
      title: input.title,
      body: input.body,
    },
    data: buildPushDataPayload({
      notificationId: input.notificationId,
      type: input.type,
      category: input.category,
      deeplink: input.deeplink,
      entityType: input.entityType,
      entityId: input.entityId,
      timestamp: input.timestamp,
    }),
  });

  return {
    attempted: true,
    tokenCount: tokens.length,
  };
}

async function writeAuditEvent(db, event) {
  await db.collection('auditEvents').add({
    ...event,
    createdAt: FieldValue.serverTimestamp(),
  });
}

function queueAuditEvent(db, tx, event) {
  const ref = db.collection('auditEvents').doc();
  tx.set(ref, {
    ...event,
    createdAt: FieldValue.serverTimestamp(),
  });
}

function normalizedItemPayload(payload) {
  const categoryMain = ensureString(payload.categoryMain, 'categoryMain');
  if (categoryMain !== 'GOODS' && categoryMain !== 'PRECIOUS') {
    throw new AppError(
      'invalid-argument',
      'categoryMain must be GOODS or PRECIOUS',
    );
  }

  const status = optionalString(payload.status) ?? 'DRAFT';
  if (!['DRAFT', 'READY', 'ARCHIVED'].includes(status)) {
    throw new AppError('invalid-argument', 'invalid item status');
  }

  const imageUrls = stringArray(payload.imageUrls ?? payload.images);
  const authImageUrls = stringArray(
    payload.authImageUrls ?? payload.goodsAuthImages,
  );
  if (categoryMain === 'GOODS' && authImageUrls.length < 1) {
    throw new AppError(
      'invalid-argument',
      'GOODS requires at least one auth image',
    );
  }
  if (imageUrls.length > 10) {
    throw new AppError('invalid-argument', 'imageUrls max 10');
  }

  const appraisalPayload =
    payload.appraisal && typeof payload.appraisal === 'object'
      ? payload.appraisal
      : {};
  const appraisalStatus = optionalString(appraisalPayload.status) ?? 'NONE';
  if (
    !['NONE', 'REQUESTED', 'APPROVED', 'REJECTED'].includes(appraisalStatus)
  ) {
    throw new AppError('invalid-argument', 'invalid appraisal status');
  }

  const draftAuctionPayload =
    payload.draftAuction && typeof payload.draftAuction === 'object'
      ? payload.draftAuction
      : {};
  const startPrice = optionalPositiveNumber(draftAuctionPayload.startPrice);
  const buyNowPrice = optionalPositiveNumber(draftAuctionPayload.buyNowPrice);
  const durationDays = optionalPositiveInteger(
    draftAuctionPayload.durationDays,
  );
  if (startPrice != null && buyNowPrice != null && buyNowPrice <= startPrice) {
    throw new AppError(
      'invalid-argument',
      'draft buyNowPrice must be greater than startPrice',
    );
  }

  return {
    status,
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
      status: appraisalStatus,
      badgeLabel: optionalString(appraisalPayload.badgeLabel),
    },
  };
}

function serializeOrder(order) {
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

function deserializeOrder(id, data) {
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
    finalPrice: typeof data.finalPrice === 'number' ? data.finalPrice : 0,
    paymentStatus: ensureString(data.paymentStatus, 'paymentStatus'),
    orderStatus: ensureString(data.orderStatus, 'orderStatus'),
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

function buildOrderFees(finalPrice) {
  const feeAmount = Math.floor(finalPrice * depositPolicy.percent);
  return {
    feeRate: depositPolicy.percent,
    feeAmount,
    sellerReceivable: Math.max(0, finalPrice - feeAmount),
  };
}

function toAwaitingPaymentOrder(auction, now) {
  return {
    auctionId: auction.id,
    itemId: auction.itemId,
    buyerId: auction.highestBidderId,
    sellerId: auction.sellerId,
    finalPrice: auction.currentPrice,
    paymentStatus: 'UNPAID',
    orderStatus: 'AWAITING_PAYMENT',
    paymentDueAt: new Date(now.getTime() + 24 * 60 * 60 * 1000),
    payment: {
      provider: 'TOSS_PAYMENTS',
      paymentKey: null,
      method: null,
      approvedAt: null,
      lastWebhookEventId: null,
    },
    shipping: {
      carrierCode: null,
      carrierName: null,
      trackingNumber: null,
      trackingUrl: null,
      shippedAt: null,
    },
    settlement: {
      expectedAt: null,
      settledAt: null,
      payoutBatchId: null,
    },
    fees: buildOrderFees(auction.currentPrice),
  };
}

function minIncrementFor(price) {
  const band = bidIncrementTable.find(
    (row) => price >= row.min && price <= row.max,
  );
  return band?.step ?? 1000;
}

function validateBid(auction, amount, now) {
  if (auction.status !== 'LIVE') {
    throw new AppError('failed-precondition', 'Auction not live');
  }
  if (now >= auction.endAt) {
    throw new AppError('failed-precondition', 'Auction ended');
  }
  const increment = minIncrementFor(auction.currentPrice);
  const minAmount = auction.currentPrice + increment;
  if (amount < minAmount) {
    throw new AppError(
      'failed-precondition',
      `Bid too low. minimum=${minAmount}`,
    );
  }
}

function applyAntiSniping(auction, now) {
  const secondsLeft = Math.floor(
    (auction.endAt.getTime() - now.getTime()) / 1000,
  );
  if (
    secondsLeft <= antiSnipingPolicy.triggerSecondsBeforeEnd &&
    auction.extendedCount < antiSnipingPolicy.maxExtensions
  ) {
    return {
      ...auction,
      endAt: new Date(
        auction.endAt.getTime() + antiSnipingPolicy.extensionSeconds * 1000,
      ),
      extendedCount: auction.extendedCount + 1,
    };
  }
  return auction;
}

function resolveAutoBidCompetition(auction, leadingBidderId, autoBids, now) {
  const enabled = autoBids
    .filter((entry) => entry.isEnabled)
    .sort((left, right) => right.maxAmount - left.maxAmount);
  if (enabled.length < 1) {
    return { auction, bids: [] };
  }

  const bids = [];
  let current = { ...auction, highestBidderId: leadingBidderId };
  let guard = 0;

  while (guard < 20) {
    guard += 1;
    const challenger = enabled.find(
      (entry) =>
        entry.uid !== current.highestBidderId &&
        entry.maxAmount >=
          current.currentPrice + minIncrementFor(current.currentPrice),
    );
    if (!challenger) {
      break;
    }

    const nextPrice = current.currentPrice + minIncrementFor(current.currentPrice);
    if (nextPrice > challenger.maxAmount) {
      break;
    }

    bids.push({
      bidderId: challenger.uid,
      amount: nextPrice,
      kind: 'AUTO',
      createdAt: now,
    });
    current = {
      ...current,
      currentPrice: nextPrice,
      highestBidderId: challenger.uid,
      bidCount: current.bidCount + 1,
    };
  }

  return { auction: current, bids };
}

function placeBidEngine(input) {
  validateBid(input.auction, input.amount, input.now);

  const outbidUserId = input.auction.highestBidderId ?? undefined;
  let autoBidCeilingReachedUserId;
  let auction = {
    ...input.auction,
    currentPrice: input.amount,
    highestBidderId: input.bidderId,
    bidCount: input.auction.bidCount + 1,
    bidderCount:
      input.auction.highestBidderId === input.bidderId
        ? input.auction.bidderCount
        : input.auction.bidderCount + 1,
  };

  auction = applyAntiSniping(auction, input.now);

  const bids = [
    {
      bidderId: input.bidderId,
      amount: input.amount,
      kind: 'MANUAL',
      createdAt: input.now,
    },
  ];

  if (featureFlags.autoBid && input.autoBids?.length) {
    const auto = resolveAutoBidCompetition(
      auction,
      input.bidderId,
      input.autoBids,
      input.now,
    );
    auction = auto.auction;
    bids.push(...auto.bids);
    autoBidCeilingReachedUserId = resolveAutoBidCeilingReachedUserId({
      finalAuction: auction,
      outbidUserId,
      autoBids: input.autoBids,
    });
  }

  return { auction, bids, outbidUserId, autoBidCeilingReachedUserId };
}

function resolveAutoBidCeilingReachedUserId(input) {
  const outbidUserId = input.outbidUserId;
  if (!outbidUserId) {
    return undefined;
  }
  if (input.finalAuction.highestBidderId === outbidUserId) {
    return undefined;
  }

  const autoBid = input.autoBids.find(
    (entry) => entry.uid === outbidUserId && entry.isEnabled,
  );
  if (!autoBid) {
    return undefined;
  }

  const minimumNextBid =
    input.finalAuction.currentPrice +
    minIncrementFor(input.finalAuction.currentPrice);
  if (autoBid.maxAmount >= minimumNextBid) {
    return undefined;
  }

  return outbidUserId;
}

function normalizeAppBaseUrl(appBaseUrl) {
  if (!appBaseUrl?.trim()) {
    return null;
  }

  let parsed;
  try {
    parsed = new URL(appBaseUrl);
  } catch {
    throw new AppError(
      'failed-precondition',
      'APP_BASE_URL must be a valid http or https URL.',
    );
  }

  if (!['http:', 'https:'].includes(parsed.protocol)) {
    throw new AppError(
      'failed-precondition',
      'APP_BASE_URL must use http or https.',
    );
  }

  parsed.pathname = parsed.pathname.replace(/\/$/, '');
  parsed.search = '';
  parsed.hash = '';
  return parsed.toString().replace(/\/$/, '');
}

function isDevDummyPaymentEnabled(config) {
  if (config.enableTossSandbox) {
    return false;
  }
  return false;
}

function buildPaymentSessionContract({
  appEnv,
  appBaseUrl,
  orderId,
  allowDevDummyPayment,
  buildDevPaymentKey: buildKey,
}) {
  if (appEnv !== 'dev' && allowDevDummyPayment) {
    throw new AppError(
      'failed-precondition',
      'Dev dummy payment can only be enabled in dev.',
    );
  }

  if (allowDevDummyPayment) {
    return {
      mode: 'DEV_DUMMY',
      successUrl: null,
      failUrl: null,
      checkoutUrl: null,
      devPaymentKey: buildKey(orderId),
    };
  }

  if (appEnv !== 'dev' && !appBaseUrl) {
    throw new AppError(
      'failed-precondition',
      'APP_BASE_URL is required outside dev builds.',
    );
  }
  if (!appBaseUrl) {
    throw new AppError(
      'failed-precondition',
      'APP_BASE_URL is required when dev dummy payment is unavailable.',
    );
  }

  const normalizedBaseUrl = normalizeAppBaseUrl(appBaseUrl);
  const successUrl = normalizedBaseUrl
    ? `${normalizedBaseUrl}/payments/success`
    : null;
  const failUrl = normalizedBaseUrl ? `${normalizedBaseUrl}/payments/fail` : null;
  const checkoutUrl = normalizedBaseUrl
    ? `${normalizedBaseUrl}/payments/launch?orderId=${encodeURIComponent(orderId)}`
    : null;

  return {
    mode: 'TOSS',
    successUrl,
    failUrl,
    checkoutUrl,
    devPaymentKey: null,
  };
}

function isDuplicatePaymentConfirmation(order, paymentKey, amount) {
  return (
    order.paymentStatus === 'PAID' &&
    order.payment.paymentKey === paymentKey &&
    order.finalPrice === amount
  );
}

function toConfirmedPaymentOrder(order, payment, webhookEventId) {
  return {
    ...order,
    paymentStatus: 'PAID',
    orderStatus: 'PAID_ESCROW_HOLD',
    payment: {
      provider: 'TOSS_PAYMENTS',
      paymentKey: payment.paymentKey,
      method: payment.method,
      approvedAt: payment.approvedAt,
      lastWebhookEventId: webhookEventId,
    },
  };
}

function withLastWebhookEventId(order, webhookEventId) {
  return {
    ...order,
    payment: {
      ...order.payment,
      lastWebhookEventId: webhookEventId,
    },
  };
}

function toFailedPaymentOrder(order) {
  return {
    ...order,
    paymentStatus: 'FAILED',
  };
}

function toCancelledPaymentOrder(order, webhookEventId) {
  return {
    ...order,
    paymentStatus: 'CANCELLED',
    orderStatus: 'CANCELLED',
    payment: {
      ...order.payment,
      lastWebhookEventId: webhookEventId,
    },
  };
}

function shouldApplyWebhookCancellation(order) {
  return order.orderStatus === 'AWAITING_PAYMENT';
}

function buildWebhookEventMarker(eventType, createdAt, paymentKey, status) {
  return [eventType, createdAt ?? 'unknown', paymentKey ?? 'no-key', status ?? 'unknown']
    .join(':')
    .replace(/\s+/g, '_');
}

function extractWebhookSecret(payload) {
  const rootSecret = typeof payload.secret === 'string' ? payload.secret : null;
  if (rootSecret) {
    return rootSecret;
  }

  const data = payload.data;
  if (data && typeof data === 'object') {
    const nestedSecret = data.secret;
    if (typeof nestedSecret === 'string') {
      return nestedSecret;
    }
  }

  return null;
}

function normalizeWebhookPayment(payload) {
  const data = payload.data;
  if (!data || typeof data !== 'object') {
    return null;
  }

  const payment = data;
  const approvedAt =
    typeof payment.approvedAt === 'string' && payment.approvedAt
      ? new Date(payment.approvedAt)
      : null;

  return {
    orderId: typeof payment.orderId === 'string' ? payment.orderId : '',
    paymentKey:
      typeof payment.paymentKey === 'string' ? payment.paymentKey : null,
    method: typeof payment.method === 'string' ? payment.method : null,
    totalAmount:
      typeof payment.totalAmount === 'number' ? payment.totalAmount : null,
    status: typeof payment.status === 'string' ? payment.status : null,
    secret: typeof payment.secret === 'string' ? payment.secret : null,
    approvedAt:
      approvedAt && !Number.isNaN(approvedAt.getTime()) ? approvedAt : null,
  };
}

async function confirmTossPayment(config, input) {
  if (!config.tossSecretKey) {
    throw new AppError(
      'failed-precondition',
      'TOSS_SECRET_KEY is required to confirm payments.',
    );
  }

  const response = await fetch(`${config.tossApiBaseUrl}/v1/payments/confirm`, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${Buffer.from(`${config.tossSecretKey}:`).toString(
        'base64',
      )}`,
      'Content-Type': 'application/json',
      'Idempotency-Key': input.idempotencyKey,
    },
    body: JSON.stringify({
      paymentKey: input.paymentKey,
      orderId: input.orderId,
      amount: input.amount,
    }),
  });

  const body = await response.json();
  if (!response.ok) {
    throw new AppError(
      'failed-precondition',
      ensureString(body.message ?? 'Toss confirm failed', 'toss message', {
        allowEmpty: true,
      }),
    );
  }

  return {
    paymentKey: ensureString(body.paymentKey, 'paymentKey'),
    method: optionalString(body.method),
    approvedAt: toDate(body.approvedAt ?? new Date().toISOString(), 'approvedAt'),
    totalAmount:
      typeof body.totalAmount === 'number' ? body.totalAmount : input.amount,
    status: ensureString(body.status ?? 'DONE', 'status'),
  };
}

function buildOrderName(auctionId) {
  return `auction-${auctionId}`;
}

function readQueryString(value, fieldName, options = {}) {
  if (typeof value !== 'string') {
    throw new AppError(
      'invalid-argument',
      `${fieldName} query is required.`,
    );
  }

  const normalized = value.trim();
  if (!options.allowEmpty && normalized.length === 0) {
    throw new AppError(
      'invalid-argument',
      `${fieldName} query must not be empty.`,
    );
  }

  return normalized;
}

function readQueryAmount(value) {
  const amountText = readQueryString(value, 'amount');
  if (!/^[1-9]\d*$/.test(amountText)) {
    throw new AppError(
      'invalid-argument',
      'amount query must be a positive integer.',
    );
  }
  return Number(amountText);
}

function readOptionalQueryString(value) {
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

function escapeHtml(value) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function encodeJsString(value) {
  return JSON.stringify(value);
}

function buildAppReturnLink(status, params) {
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value) {
      query.set(key, value);
    }
  }
  const queryString = query.toString();
  return queryString.length > 0
    ? `app://payments/${status}?${queryString}`
    : `app://payments/${status}`;
}

function paymentBridgeHtml({ title, description, body }) {
  const safeTitle = escapeHtml(title);
  const safeDescription = escapeHtml(description);

  return `<!doctype html>
<html lang="ko">
  <head>
    <meta charset="utf-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1, viewport-fit=cover"
    />
    <title>${safeTitle}</title>
    <style>
      :root {
        color-scheme: light dark;
        --bg: #f4ede3;
        --surface: rgba(255, 248, 241, 0.92);
        --text: #1e1b19;
        --muted: #62584f;
        --accent: #d86d4e;
        --border: rgba(30, 27, 25, 0.12);
      }
      @media (prefers-color-scheme: dark) {
        :root {
          --bg: #14110f;
          --surface: rgba(28, 24, 22, 0.92);
          --text: #f3ede7;
          --muted: #d4c5ba;
          --border: rgba(255, 244, 236, 0.14);
        }
      }
      * { box-sizing: border-box; }
      body {
        margin: 0;
        min-height: 100vh;
        display: grid;
        place-items: center;
        padding: 24px;
        background:
          radial-gradient(circle at top, rgba(216, 109, 78, 0.16), transparent 32%),
          linear-gradient(180deg, var(--bg), color-mix(in srgb, var(--bg) 84%, #000 16%));
        color: var(--text);
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      }
      .panel {
        width: min(100%, 460px);
        border-radius: 28px;
        border: 1px solid var(--border);
        background: var(--surface);
        backdrop-filter: blur(18px);
        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.16);
        padding: 28px;
      }
      h1 { margin: 0 0 10px; font-size: 28px; line-height: 1.1; }
      p { margin: 0; color: var(--muted); line-height: 1.6; }
      .spacer { height: 20px; }
      .button {
        appearance: none;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        min-height: 52px;
        padding: 0 18px;
        border: none;
        border-radius: 999px;
        background: var(--accent);
        color: white;
        font-size: 16px;
        font-weight: 700;
        text-decoration: none;
        cursor: pointer;
      }
      .button.secondary {
        background: transparent;
        color: var(--text);
        border: 1px solid var(--border);
      }
      .stack { display: grid; gap: 12px; }
      .meta {
        margin-top: 16px;
        padding-top: 16px;
        border-top: 1px solid var(--border);
        font-size: 13px;
        color: var(--muted);
      }
      .notice {
        margin: 0 0 16px;
        padding: 14px 16px;
        border-radius: 18px;
        background: rgba(255, 255, 255, 0.78);
        border: 1px solid var(--border);
      }
      .notice strong {
        display: block;
        margin-bottom: 6px;
        color: var(--text);
        font-size: 14px;
      }
      .notice ul {
        margin: 0;
        padding-left: 18px;
        color: var(--muted);
        font-size: 13px;
        line-height: 1.6;
      }
    </style>
  </head>
  <body>
    <main class="panel">
      <h1>${safeTitle}</h1>
      <p>${safeDescription}</p>
      <div class="spacer"></div>
      ${body}
    </main>
  </body>
</html>`;
}

function buildPaymentLaunchHtml(input) {
  const values = {
    clientKey: encodeJsString(input.clientKey),
    customerKey: encodeJsString(input.customerKey),
    orderId: encodeJsString(input.orderId),
    amount: String(input.amount),
    orderName: encodeJsString(input.orderName),
    successUrl: encodeJsString(input.successUrl),
    failUrl: encodeJsString(input.failUrl),
    cardCompany: input.useDevCardOnlyWindow
      ? encodeJsString('11|21|31|33|41|51|61|71|91')
      : 'null',
  };

  return paymentBridgeHtml({
    title: '결제창을 준비하고 있습니다',
    description:
      'Toss 테스트 결제창을 여는 중입니다. 자동으로 진행되지 않으면 아래 버튼을 눌러 계속하세요.',
    body: `${
      input.useDevCardOnlyWindow
        ? `<section class="notice">
        <strong>개발 테스트 안내</strong>
        <ul>
          <li>이 화면은 카드 결제 확인용으로만 사용합니다.</li>
          <li>외부 앱이 필요한 간편결제나 앱카드는 테스트 대상이 아닙니다.</li>
          <li>통합 결제창이 열리면 일반 카드 입력 경로로만 진행해 주세요.</li>
        </ul>
      </section>`
        : ''
    }<div class="stack">
        <button id="launch" class="button" type="button">Toss 결제 계속</button>
        <button id="retry-app" class="button secondary" type="button" hidden>앱으로 돌아가기</button>
      </div>
      <div class="meta">테스트 결제이며 실제 청구는 발생하지 않습니다.</div>
      <script src="https://js.tosspayments.com/v2/standard"></script>
      <script>
        const launchButton = document.getElementById('launch');
        const retryAppButton = document.getElementById('retry-app');
        const failUrl = ${values.failUrl};
        const orderId = ${values.orderId};
        let isLaunching = false;

        function buildFailureUrl(error) {
          const fallback = '결제창을 열지 못했습니다. 다시 시도해 주세요.';
          let message = fallback;
          if (
            error &&
            typeof error === 'object' &&
            typeof error.message === 'string' &&
            error.message.length > 0
          ) {
            message = error.message;
          }
          const code =
            error &&
            typeof error === 'object' &&
            typeof error.code === 'string' &&
            error.code.length > 0
              ? error.code
              : 'LAUNCH_FAILED';

          const nextUrl = new URL(failUrl);
          nextUrl.searchParams.set('orderId', orderId);
          nextUrl.searchParams.set('code', code);
          nextUrl.searchParams.set('message', message);
          return nextUrl.toString();
        }

        function openFailPage(error) {
          window.location.href = buildFailureUrl(error);
        }

        async function startPayment() {
          if (isLaunching) return;
          isLaunching = true;
          launchButton.disabled = true;
          launchButton.textContent = '결제창 여는 중...';
          try {
            const tossPayments = TossPayments(${values.clientKey});
            const payment = tossPayments.payment({
              customerKey: ${values.customerKey},
            });
            await payment.requestPayment({
              method: 'CARD',
              amount: {
                currency: 'KRW',
                value: ${values.amount},
              },
              orderId: ${values.orderId},
              orderName: ${values.orderName},
              successUrl: ${values.successUrl},
              failUrl: ${values.failUrl},
              card: {
                flowMode: 'DEFAULT',
                cardCompany: ${values.cardCompany},
              },
              windowTarget: 'self',
            });
          } catch (error) {
            isLaunching = false;
            launchButton.disabled = false;
            launchButton.textContent = 'Toss 결제 계속';
            retryAppButton.hidden = false;
            openFailPage(error);
          }
        }

        launchButton.addEventListener('click', startPayment);
        retryAppButton.addEventListener('click', () => {
          openFailPage({ code: 'USER_RETRY', message: '사용자가 앱 복귀를 선택했습니다.' });
        });
        window.addEventListener('load', () => {
          setTimeout(startPayment, 80);
        });
      </script>`,
  });
}

function buildPaymentReturnHtml(input) {
  return paymentBridgeHtml({
    title: input.title,
    description: input.description,
    body: `<div class="stack">
        <a class="button" href="${escapeHtml(input.appReturnUrl)}">${escapeHtml(input.buttonLabel)}</a>
        <button id="retry" class="button secondary" type="button">앱이 열리지 않으면 다시 시도</button>
      </div>
      <script>
        const appReturnUrl = ${encodeJsString(input.appReturnUrl)};
        function openApp() {
          window.location.replace(appReturnUrl);
        }
        document.getElementById('retry').addEventListener('click', openApp);
        window.addEventListener('load', () => {
          setTimeout(openApp, 60);
        });
      </script>`,
  });
}

function buildDeviceTokenId(token) {
  return encodeURIComponent(token);
}

function buildRegisterDeviceTokenRecord(input, serverTimestamp, options) {
  return {
    token: input.token,
    platform: input.platform,
    appVersion: input.appVersion,
    locale: input.locale,
    timezone: input.timezone,
    permissionStatus: input.permissionStatus,
    isActive: true,
    lastSeenAt: serverTimestamp,
    updatedAt: serverTimestamp,
    ...(options.includeCreatedAt ? { createdAt: serverTimestamp } : {}),
  };
}

function buildDeactivateDeviceTokenRecord(permissionStatus, serverTimestamp) {
  return {
    isActive: false,
    permissionStatus,
    lastSeenAt: serverTimestamp,
    updatedAt: serverTimestamp,
  };
}

const debugPushProbeNotification = {
  type: 'SYSTEM_TEST',
  deeplink: 'app://notifications',
  entityType: 'ORDER',
  entityId: 'debug-push-probe',
};

function requireDevAppEnv(config, featureName) {
  if (config.appEnv !== 'dev') {
    throw new AppError(
      'failed-precondition',
      `${featureName} is available only when APP_ENV=dev.`,
    );
  }
}

async function authenticateRequest(req, auth) {
  const authHeader = req.headers.authorization;
  if (!authHeader || typeof authHeader !== 'string') {
    throw new AppError(
      'unauthenticated',
      'Authorization header is required.',
    );
  }

  const [scheme, token] = authHeader.split(' ');
  if (scheme !== 'Bearer' || !token) {
    throw new AppError(
      'unauthenticated',
      'Authorization header must use Bearer token.',
    );
  }

  const decodedToken = await auth.verifyIdToken(token);
  if (!decodedToken.uid) {
    throw new AppError('unauthenticated', 'Login required');
  }

  return {
    uid: decodedToken.uid,
    token: decodedToken,
  };
}

function sendJsonError(res, error) {
  if (isAppError(error)) {
    res.status(error.status).json({
      code: error.code,
      message: error.message,
      details: error.details,
    });
    return;
  }

  res.status(500).json({
    code: 'internal',
    message: error instanceof Error ? error.message : 'Internal server error',
    details: null,
  });
}

function asyncRoute(handler) {
  return async (req, res, next) => {
    try {
      await handler(req, res);
    } catch (error) {
      next(error);
    }
  };
}

function bindAuthenticated(handler, services) {
  return asyncRoute(async (req, res) => {
    const authContext = await authenticateRequest(req, services.auth);
    await handler(req, res, authContext, services);
  });
}

export function createApp(services) {
  const { config, db } = services;
  const app = express();

  app.disable('x-powered-by');
  app.use(express.json({ limit: '1mb' }));

  const sendHealth = (_req, res) => {
    res.json({
      ok: true,
      appEnv: config.appEnv,
      appBaseUrl: config.appBaseUrl,
      firebaseProjectId: config.firebaseProjectId ?? null,
    });
  };

  app.get('/health', sendHealth);
  app.get('/healthz', sendHealth);

  app.get(
    '/api/auctions/:auctionId/detail',
    asyncRoute(async (req, res) => {
      const auctionId = ensureString(req.params.auctionId, 'auctionId');
      const auctionRef = db.collection('auctions').doc(auctionId);
      const auctionSnap = await auctionRef.get();
      if (!auctionSnap.exists) {
        throw new AppError('not-found', 'Auction not found');
      }

      const auction = auctionSnap.data();
      const itemId = optionalString(auction.itemId);
      const [itemSnap, bidsSnap] = await Promise.all([
        itemId ? db.collection('items').doc(itemId).get() : Promise.resolve(null),
        auctionRef.collection('bids').orderBy('createdAt').limitToLast(6).get(),
      ]);
      const item = itemSnap?.exists ? itemSnap.data() : {};

      res.set('Cache-Control', 'no-store').json({
        detail: {
          id: auctionSnap.id,
          itemId: itemId ?? '',
          titleSnapshot: optionalString(auction.titleSnapshot) ?? '',
          heroImageUrl: optionalString(auction.heroImageUrl),
          imageUrls: stringArray(item.imageUrls),
          description: optionalString(item.description) ?? '',
          categorySub:
            optionalString(item.categorySub) ??
            optionalString(auction.categorySub) ??
            '',
          condition: optionalString(item.condition) ?? '',
          sellerId: optionalString(auction.sellerId),
          status: optionalString(auction.status) ?? 'DRAFT',
          currentPrice:
            typeof auction.currentPrice === 'number' ? auction.currentPrice : 0,
          buyNowPrice:
            typeof auction.buyNowPrice === 'number' ? auction.buyNowPrice : null,
          orderId: optionalString(auction.orderId),
          endAt: timestampJsonValue(auction.endAt),
        },
        bidHistory: bidsSnap.docs.map((doc) => {
          const bid = doc.data();
          return {
            amount: typeof bid.amount === 'number' ? bid.amount : 0,
            createdAt: timestampJsonValue(bid.createdAt),
          };
        }),
      });
    }),
  );

  app.get(
    '/payments/*',
    asyncRoute(async (req, res) => {
      const useDevCardOnlyWindow =
        config.appEnv === 'dev' && config.enableTossSandbox;
      const path = req.path.replace(/\/+$/, '') || '/';

      if (path === '/payments/launch') {
        const clientKey = readQueryString(req.query.clientKey, 'clientKey');
        const customerKey = readQueryString(req.query.customerKey, 'customerKey');
        const orderId = readQueryString(req.query.orderId, 'orderId');
        const amount = readQueryAmount(req.query.amount);
        const orderName = readQueryString(req.query.orderName, 'orderName');
        const successUrl = readQueryString(req.query.successUrl, 'successUrl');
        const failUrl = readQueryString(req.query.failUrl, 'failUrl');

        res
          .status(200)
          .set('Cache-Control', 'no-store')
          .set('Pragma', 'no-cache')
          .contentType('text/html; charset=utf-8')
          .send(
            buildPaymentLaunchHtml({
              clientKey,
              customerKey,
              orderId,
              amount,
              orderName,
              successUrl,
              failUrl,
              useDevCardOnlyWindow,
            }),
          );
        return;
      }

      if (path === '/payments/success') {
        const orderId = readQueryString(req.query.orderId, 'orderId');
        const paymentKey = readQueryString(req.query.paymentKey, 'paymentKey');
        const amount = readQueryString(req.query.amount, 'amount');
        const appReturnUrl = buildAppReturnLink('success', {
          orderId,
          paymentKey,
          amount,
        });

        res
          .status(200)
          .set('Cache-Control', 'no-store')
          .set('Pragma', 'no-cache')
          .contentType('text/html; charset=utf-8')
          .send(
            buildPaymentReturnHtml({
              status: 'success',
              title: '결제 정보를 앱으로 보내는 중입니다',
              description:
                '앱으로 돌아가 결제를 최종 확인합니다. 자동으로 열리지 않으면 아래 버튼을 눌러 계속하세요.',
              appReturnUrl,
              buttonLabel: '앱으로 돌아가기',
            }),
          );
        return;
      }

      if (path === '/payments/fail') {
        const orderId = readOptionalQueryString(req.query.orderId);
        const code = readOptionalQueryString(req.query.code);
        const message = readOptionalQueryString(req.query.message);
        const appReturnUrl = buildAppReturnLink('fail', {
          orderId,
          code,
          message,
        });

        res
          .status(200)
          .set('Cache-Control', 'no-store')
          .set('Pragma', 'no-cache')
          .contentType('text/html; charset=utf-8')
          .send(
            buildPaymentReturnHtml({
              status: 'fail',
              title: '결제가 완료되지 않았습니다',
              description:
                '앱으로 돌아가 결제 실패 상태를 확인합니다. 자동으로 열리지 않으면 아래 버튼을 눌러 계속하세요.',
              appReturnUrl,
              buttonLabel: '앱에서 실패 상태 보기',
            }),
          );
        return;
      }

      res.status(404).send('Not Found');
    }),
  );

  app.post(
    '/webhooks/toss',
    asyncRoute(async (req, res) => {
      if (config.tossWebhookSecret == null) {
        res.status(503).send('Webhook secret not configured');
        return;
      }

      const payload = ensureObject(req.body, 'webhook body is required');
      const eventType =
        optionalString(payload.eventType) ??
        optionalString(payload.type) ??
        'UNKNOWN';
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

      const order = deserializeOrder(orderSnap.id, orderSnap.data());
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
            db,
            order.sellerId,
            'PAYMENT_COMPLETED',
            buildDeepLink('orders', order.id),
          );
          await writeAuditEvent(db, {
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
        const nextOrder = shouldApplyWebhookCancellation(order)
          ? toCancelledPaymentOrder(order, eventMarker)
          : withLastWebhookEventId(order, eventMarker);
        await orderRef.update({
          ...serializeOrder(nextOrder),
          updatedAt: FieldValue.serverTimestamp(),
        });
        await writeAuditEvent(db, {
          entityType: 'PAYMENT',
          entityId: payment.paymentKey ?? order.id,
          eventType: 'PAYMENT_WEBHOOK_CANCELLED',
          actorId: null,
          payload: { orderId: order.id, status: payment.status, eventMarker },
        });
      }

      res.status(200).json({ ok: true });
    }),
  );

  app.post(
    '/api/items',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(req.body, 'item payload is required');
      const normalized = normalizedItemPayload(payload);
      const itemId = optionalString(payload.id);
      const itemRef = itemId
        ? db.collection('items').doc(itemId)
        : db.collection('items').doc();

      await db.runTransaction(async (tx) => {
        const snap = await tx.get(itemRef);
        if (snap.exists && snap.data()?.sellerId !== authContext.uid) {
          throw new AppError('permission-denied', 'Only owner can update item');
        }

        tx.set(
          itemRef,
          {
            sellerId: authContext.uid,
            ...normalized,
            createdAt: snap.data()?.createdAt ?? FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );

        queueAuditEvent(db, tx, {
          entityType: 'AUCTION',
          entityId: itemRef.id,
          eventType: snap.exists ? 'ITEM_UPDATED' : 'ITEM_CREATED',
          actorId: authContext.uid,
          payload: {
            categoryMain: normalized.categoryMain,
            status: normalized.status,
          },
        });
      });

      res.json({ itemId: itemRef.id });
    }, services),
  );

  app.post(
    '/api/auctions',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(req.body, 'auction payload is required');
      const itemId = ensureString(payload.itemId, 'itemId');
      const startAt = toDate(payload.startAt ?? Date.now(), 'startAt');
      const endAt = toDate(payload.endAt, 'endAt');
      const startPrice =
        typeof payload.startPrice === 'number' ? payload.startPrice : NaN;
      const buyNowPrice =
        typeof payload.buyNowPrice === 'number' ? payload.buyNowPrice : null;

      if (Number.isNaN(startPrice) || startPrice <= 0) {
        throw new AppError('invalid-argument', 'startPrice must be positive');
      }
      if (endAt <= startAt) {
        throw new AppError('invalid-argument', 'endAt must be after startAt');
      }
      if (buyNowPrice != null && buyNowPrice <= startPrice) {
        throw new AppError(
          'invalid-argument',
          'buyNowPrice must be greater than startPrice',
        );
      }

      const itemRef = db.collection('items').doc(itemId);
      const itemSnap = await itemRef.get();
      if (!itemSnap.exists) {
        throw new AppError('not-found', 'Item not found');
      }

      const item = itemSnap.data();
      if (item.sellerId !== authContext.uid) {
        throw new AppError(
          'permission-denied',
          'Only the seller can publish this item',
        );
      }

      const imageUrls = stringArray(item.imageUrls);
      const authImageUrls = stringArray(item.authImageUrls);
      if (!imageUrls.length) {
        throw new AppError(
          'failed-precondition',
          'At least one image is required',
        );
      }
      if (item.categoryMain === 'GOODS' && authImageUrls.length < 1) {
        throw new AppError(
          'failed-precondition',
          'GOODS items require at least one auth image',
        );
      }

      const auctionRef = db.collection('auctions').doc();
      await db.runTransaction(async (tx) => {
        tx.set(auctionRef, {
          itemId,
          sellerId: authContext.uid,
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
        queueAuditEvent(db, tx, {
          entityType: 'AUCTION',
          entityId: auctionRef.id,
          eventType: 'AUCTION_PUBLISHED',
          actorId: authContext.uid,
          payload: {
            itemId,
            startPrice,
            buyNowPrice,
          },
        });
      });

      res.json({ auctionId: auctionRef.id });
    }, services),
  );

  app.post(
    '/api/auctions/:auctionId/place-bid',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(req.body, 'bid payload is required');
      const auctionId = ensureString(req.params.auctionId, 'auctionId');
      const amount = typeof payload.amount === 'number' ? payload.amount : NaN;
      if (Number.isNaN(amount) || amount <= 0) {
        throw new AppError('invalid-argument', 'amount must be positive');
      }

      const auctionRef = db.collection('auctions').doc(auctionId);
      let outbidUserId;
      let autoBidCeilingReachedUserId;
      let finalPrice = amount;

      await db.runTransaction(async (tx) => {
        const snap = await tx.get(auctionRef);
        if (!snap.exists) {
          throw new AppError('not-found', 'Auction not found');
        }

        const auctionData = snap.data();
        if (auctionData.sellerId === authContext.uid) {
          throw new AppError(
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
              const configValue = doc.data();
              return {
                uid: doc.id,
                maxAmount:
                  typeof configValue.maxAmount === 'number'
                    ? configValue.maxAmount
                    : 0,
                isEnabled: configValue.isEnabled === true,
              };
            })
          : [];

        const result = placeBidEngine({
          auction: {
            id: auctionId,
            itemId: ensureString(auctionData.itemId, 'itemId'),
            sellerId: ensureString(auctionData.sellerId, 'sellerId'),
            startPrice: auctionData.startPrice,
            buyNowPrice:
              typeof auctionData.buyNowPrice === 'number'
                ? auctionData.buyNowPrice
                : null,
            currentPrice: auctionData.currentPrice,
            status: auctionData.status,
            endAt: toDate(auctionData.endAt, 'endAt'),
            extendedCount: auctionData.extendedCount,
            bidCount: auctionData.bidCount,
            bidderCount: auctionData.bidderCount,
            highestBidderId: optionalString(auctionData.highestBidderId),
          },
          bidderId: authContext.uid,
          amount,
          now: new Date(),
          autoBids: autoBidConfigs,
        });

        outbidUserId = result.outbidUserId;
        autoBidCeilingReachedUserId = result.autoBidCeilingReachedUserId;
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

        queueAuditEvent(db, tx, {
          entityType: 'AUCTION',
          entityId: auctionId,
          eventType: 'BID_PLACED',
          actorId: authContext.uid,
          payload: {
            amount: result.auction.currentPrice,
            bidCount: result.bids.length,
          },
        });
      });

      if (
        autoBidCeilingReachedUserId &&
        autoBidCeilingReachedUserId !== authContext.uid
      ) {
        await createInboxNotification(
          db,
          autoBidCeilingReachedUserId,
          'AUTO_BID_CEILING_REACHED',
          buildDeepLink('auction', auctionId),
          { copyContext: { finalPrice } },
        );
      }

      if (
        outbidUserId &&
        outbidUserId !== authContext.uid &&
        outbidUserId !== autoBidCeilingReachedUserId
      ) {
        await createInboxNotification(
          db,
          outbidUserId,
          'OUTBID',
          buildDeepLink('auction', auctionId),
          { copyContext: { finalPrice } },
        );
      }

      res.json({ ok: true, auctionId, currentPrice: finalPrice });
    }, services),
  );

  app.post(
    '/api/auctions/:auctionId/auto-bid',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(req.body, 'auto bid payload is required');
      const auctionId = ensureString(req.params.auctionId, 'auctionId');
      const disable = payload.disable === true;
      const maxAmount =
        typeof payload.maxAmount === 'number' ? payload.maxAmount : null;
      const auctionRef = db.collection('auctions').doc(auctionId);
      const autoBidRef = auctionRef.collection('autoBids').doc(authContext.uid);

      await db.runTransaction(async (tx) => {
        const auctionSnap = await tx.get(auctionRef);
        if (!auctionSnap.exists) {
          throw new AppError('not-found', 'Auction not found');
        }

        const auction = auctionSnap.data();
        if (auction.status !== 'LIVE') {
          throw new AppError('failed-precondition', 'auction is not live');
        }
        if (auction.sellerId === authContext.uid) {
          throw new AppError(
            'failed-precondition',
            'seller cannot set auto bid',
          );
        }
        if (!disable && (maxAmount == null || maxAmount <= 0)) {
          throw new AppError(
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

      res.json({ ok: true });
    }, services),
  );

  app.post(
    '/api/auctions/:auctionId/buy-now',
    bindAuthenticated(async (req, res, authContext) => {
      const auctionId = ensureString(req.params.auctionId, 'auctionId');
      const auctionRef = db.collection('auctions').doc(auctionId);

      const result = await db.runTransaction(async (tx) => {
        const snap = await tx.get(auctionRef);
        if (!snap.exists) {
          throw new AppError('not-found', 'Auction not found');
        }

        const auction = snap.data();
        if (auction.status !== 'LIVE') {
          throw new AppError('failed-precondition', 'auction not live');
        }
        if (!auction.buyNowPrice) {
          throw new AppError('failed-precondition', 'buyNow not available');
        }
        if (auction.sellerId === authContext.uid) {
          throw new AppError(
            'failed-precondition',
            'seller cannot buy own auction',
          );
        }
        if (auction.orderId) {
          throw new AppError(
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
              currentPrice: auction.buyNowPrice,
              highestBidderId: authContext.uid,
            },
            new Date(),
          ),
          finalPrice: auction.buyNowPrice,
          fees: buildOrderFees(auction.buyNowPrice),
        };

        tx.set(orderRef, {
          ...serializeOrder(order),
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        tx.update(auctionRef, {
          status: 'ENDED',
          highestBidderId: authContext.uid,
          currentPrice: auction.buyNowPrice,
          orderId: orderRef.id,
          updatedAt: FieldValue.serverTimestamp(),
        });
        queueAuditEvent(db, tx, {
          entityType: 'ORDER',
          entityId: orderRef.id,
          eventType: 'BUY_NOW_ORDER_CREATED',
          actorId: authContext.uid,
          payload: { auctionId, finalPrice: auction.buyNowPrice },
        });

        return { orderId: orderRef.id };
      });

      res.json(result);
    }, services),
  );

  app.post(
    '/api/orders/:orderId/payment-session',
    bindAuthenticated(async (req, res, authContext) => {
      const orderId = ensureString(req.params.orderId, 'orderId');
      const orderSnap = await db.collection('orders').doc(orderId).get();
      if (!orderSnap.exists) {
        throw new AppError('not-found', 'Order not found');
      }

      const order = deserializeOrder(orderSnap.id, orderSnap.data());
      if (order.buyerId !== authContext.uid) {
        throw new AppError(
          'permission-denied',
          'Only buyer can start payment',
        );
      }
      if (order.orderStatus !== 'AWAITING_PAYMENT') {
        throw new AppError(
          'failed-precondition',
          'Order is not awaiting payment',
        );
      }

      const paymentSession = buildPaymentSessionContract({
        appEnv: config.appEnv,
        appBaseUrl: config.appBaseUrl,
        orderId,
        allowDevDummyPayment: isDevDummyPaymentEnabled(config),
        buildDevPaymentKey,
      });

      res.json({
        provider: 'TOSS_PAYMENTS',
        mode: paymentSession.mode,
        orderId,
        amount: order.finalPrice,
        orderName: buildOrderName(order.auctionId),
        customerKey: buildTossCustomerKey(authContext.uid),
        customerName: optionalString(authContext.token.name) ?? null,
        customerEmail: optionalString(authContext.token.email) ?? null,
        successUrl: paymentSession.successUrl,
        failUrl: paymentSession.failUrl,
        checkoutUrl: paymentSession.checkoutUrl,
        devPaymentKey: paymentSession.devPaymentKey,
      });
    }, services),
  );

  app.post(
    '/api/orders/:orderId/confirm-payment',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(
        req.body,
        'payment confirmation payload is required',
      );
      const orderId = ensureString(req.params.orderId, 'orderId');
      const paymentKey = ensureString(payload.paymentKey, 'paymentKey');
      const amount = typeof payload.amount === 'number' ? payload.amount : NaN;
      if (Number.isNaN(amount) || amount <= 0) {
        throw new AppError('invalid-argument', 'amount must be positive');
      }

      const orderRef = db.collection('orders').doc(orderId);
      const orderSnap = await orderRef.get();
      if (!orderSnap.exists) {
        throw new AppError('not-found', 'Order not found');
      }

      const order = deserializeOrder(orderSnap.id, orderSnap.data());
      if (order.buyerId !== authContext.uid) {
        throw new AppError(
          'permission-denied',
          'Only buyer can confirm payment',
        );
      }
      if (order.finalPrice !== amount) {
        throw new AppError(
          'failed-precondition',
          'Confirmed amount does not match order finalPrice',
        );
      }
      if (isDuplicatePaymentConfirmation(order, paymentKey, amount)) {
        res.json({ ok: true, idempotent: true, orderId });
        return;
      }
      if (order.orderStatus !== 'AWAITING_PAYMENT') {
        throw new AppError(
          'failed-precondition',
          'Order is not awaiting payment',
        );
      }

      let payment;
      try {
        if (
          isDevDummyPaymentEnabled(config) &&
          paymentKey === buildDevPaymentKey(orderId)
        ) {
          payment = {
            paymentKey,
            method: 'DEV_DUMMY',
            approvedAt: new Date(),
            totalAmount: amount,
            status: 'DONE',
          };
        } else {
          payment = await confirmTossPayment(config, {
            paymentKey,
            orderId,
            amount,
            idempotencyKey: `order:${orderId}:confirm`,
          });
        }
      } catch (error) {
        let markedFailed = false;
        await db.runTransaction(async (tx) => {
          const latestSnap = await tx.get(orderRef);
          if (!latestSnap.exists) {
            return;
          }
          const latestOrder = deserializeOrder(latestSnap.id, latestSnap.data());
          if (latestOrder.orderStatus !== 'AWAITING_PAYMENT') {
            return;
          }
          const failedOrder = toFailedPaymentOrder(latestOrder);
          tx.update(orderRef, {
            paymentStatus: failedOrder.paymentStatus,
            updatedAt: FieldValue.serverTimestamp(),
          });
          markedFailed = true;
        });
        if (markedFailed) {
          await createInboxNotification(
            db,
            order.buyerId,
            'PAYMENT_FAILED',
            buildDeepLink('orders', orderId),
          );
        }
        await writeAuditEvent(db, {
          entityType: 'PAYMENT',
          entityId: paymentKey,
          eventType: 'PAYMENT_CONFIRM_FAILED',
          actorId: authContext.uid,
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
        db,
        order.sellerId,
        'PAYMENT_COMPLETED',
        buildDeepLink('orders', orderId),
      );
      await writeAuditEvent(db, {
        entityType: 'PAYMENT',
        entityId: paymentKey,
        eventType: 'PAYMENT_CONFIRMED',
        actorId: authContext.uid,
        payload: { orderId, amount, status: payment.status },
      });

      res.json({ ok: true, orderId });
    }, services),
  );

  app.post(
    '/api/orders/:orderId/shipment',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(req.body, 'shipment payload is required');
      const orderId = ensureString(req.params.orderId, 'orderId');
      const carrierCode = optionalString(payload.carrierCode) ?? 'CUSTOM';
      const carrierName = ensureString(
        payload.carrierName ?? payload.carrier ?? carrierCode,
        'carrierName',
      );
      const trackingNumber = ensureString(
        payload.trackingNumber,
        'trackingNumber',
      );
      const trackingUrl = optionalString(payload.trackingUrl);
      const ref = db.collection('orders').doc(orderId);
      const snap = await ref.get();
      if (!snap.exists) {
        throw new AppError('not-found', 'Order not found');
      }

      const order = deserializeOrder(snap.id, snap.data());
      if (order.sellerId !== authContext.uid) {
        throw new AppError(
          'permission-denied',
          'Only seller can update shipment',
        );
      }
      if (order.orderStatus !== 'PAID_ESCROW_HOLD') {
        throw new AppError(
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
        db,
        order.buyerId,
        'SHIPPED',
        buildDeepLink('orders', orderId),
        { copyContext: { carrierName, trackingNumber } },
      );
      await writeAuditEvent(db, {
        entityType: 'ORDER',
        entityId: orderId,
        eventType: 'ORDER_SHIPPED',
        actorId: authContext.uid,
        payload: { carrierCode, trackingNumber },
      });

      res.json({ ok: true });
    }, services),
  );

  app.post(
    '/api/orders/:orderId/confirm-receipt',
    bindAuthenticated(async (req, res, authContext) => {
      const orderId = ensureString(req.params.orderId, 'orderId');
      const ref = db.collection('orders').doc(orderId);
      const snap = await ref.get();
      if (!snap.exists) {
        throw new AppError('not-found', 'Order not found');
      }

      const order = deserializeOrder(snap.id, snap.data());
      if (order.buyerId !== authContext.uid) {
        throw new AppError(
          'permission-denied',
          'Only buyer can confirm receipt',
        );
      }
      if (order.orderStatus !== 'SHIPPED') {
        throw new AppError(
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
      await writeAuditEvent(db, {
        entityType: 'ORDER',
        entityId: orderId,
        eventType: 'ORDER_RECEIPT_CONFIRMED',
        actorId: authContext.uid,
        payload: { expectedAt: expectedAt.toISOString() },
      });

      res.json({ ok: true });
    }, services),
  );

  app.post(
    '/api/notifications/debug/push-probe',
    bindAuthenticated(async (_req, res, authContext) => {
      requireDevAppEnv(config, 'debug push probe');

      const created = await createInboxNotification(
        db,
        authContext.uid,
        debugPushProbeNotification.type,
        debugPushProbeNotification.deeplink,
        {
          entityType: debugPushProbeNotification.entityType,
          entityId: debugPushProbeNotification.entityId,
        },
      );
      const dispatchResult = await dispatchPushForInboxNotification(
        services,
        {
          uid: authContext.uid,
          notificationId: created.notificationId,
          type: created.type,
          category: created.category,
          title: created.title,
          body: created.body,
          deeplink: created.deeplink,
          entityType: created.entityType,
          entityId: created.entityId,
          timestamp: new Date().toISOString(),
        },
      );

      res.json({
        ok: true,
        notificationId: created.notificationId,
        type: created.type,
        category: created.category,
        entityType: created.entityType,
        entityId: created.entityId,
        deeplink: created.deeplink,
        pushAttempted: dispatchResult.attempted,
        tokenCount: dispatchResult.tokenCount,
      });
    }, services),
  );

  app.post(
    '/api/notifications/:notificationId/read',
    bindAuthenticated(async (req, res, authContext) => {
      const notificationId = ensureString(
        req.params.notificationId,
        'notificationId',
      );
      const notificationRef = db
        .collection('notifications')
        .doc(authContext.uid)
        .collection('inbox')
        .doc(notificationId);
      const snap = await notificationRef.get();
      if (!snap.exists) {
        throw new AppError('not-found', 'Notification not found');
      }

      await notificationRef.update({
        isRead: true,
      });

      res.json({ ok: true });
    }, services),
  );

  app.post(
    '/api/device-tokens/register',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(req.body, 'device token payload is required');
      const token = ensureString(payload.token, 'token');
      const platform = ensureEnumString(payload.platform, 'platform', [
        'ANDROID',
        'IOS',
      ]);
      const appVersion = ensureString(payload.appVersion, 'appVersion');
      const locale = ensureString(payload.locale, 'locale');
      const timezone = ensureString(payload.timezone, 'timezone');
      const permissionStatus = ensureEnumString(
        payload.permissionStatus,
        'permissionStatus',
        ['AUTHORIZED', 'DENIED', 'PROVISIONAL', 'NOT_DETERMINED'],
      );
      const tokenId = buildDeviceTokenId(token);
      const tokenRef = db
        .collection('users')
        .doc(authContext.uid)
        .collection('deviceTokens')
        .doc(tokenId);
      const snap = await tokenRef.get();

      await tokenRef.set(
        buildRegisterDeviceTokenRecord(
          {
            token,
            platform,
            appVersion,
            locale,
            timezone,
            permissionStatus,
          },
          FieldValue.serverTimestamp(),
          { includeCreatedAt: !snap.exists },
        ),
        { merge: true },
      );

      res.json({ ok: true, tokenId });
    }, services),
  );

  app.post(
    '/api/device-tokens/deactivate',
    bindAuthenticated(async (req, res, authContext) => {
      const payload = ensureObject(req.body, 'device token payload is required');
      const tokenId = ensureString(payload.tokenId, 'tokenId');
      const permissionStatus = ensureEnumString(
        payload.permissionStatus,
        'permissionStatus',
        ['AUTHORIZED', 'DENIED', 'PROVISIONAL', 'NOT_DETERMINED'],
      );
      const tokenRef = db
        .collection('users')
        .doc(authContext.uid)
        .collection('deviceTokens')
        .doc(tokenId);

      await tokenRef.set(
        buildDeactivateDeviceTokenRecord(
          permissionStatus,
          FieldValue.serverTimestamp(),
        ),
        { merge: true },
      );

      res.json({ ok: true });
    }, services),
  );

  app.use((error, _req, res, _next) => {
    sendJsonError(res, error);
  });

  return app;
}
