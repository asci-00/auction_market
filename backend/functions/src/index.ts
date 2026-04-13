import { initializeApp } from 'firebase-admin/app';
import {
  FieldValue,
  type DocumentReference,
  Timestamp,
  Transaction,
  getFirestore,
} from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
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
  buildPaymentSessionContract,
  buildWebhookEventMarker,
  extractWebhookSecret,
  isDevDummyPaymentEnabled,
  isDuplicatePaymentConfirmation,
  normalizeWebhookPayment,
  shouldApplyWebhookCancellation,
  toCancelledPaymentOrder,
  toConfirmedPaymentOrder,
  toFailedPaymentOrder,
  withLastWebhookEventId,
} from './domain/paymentEngine.js';
import {
  PAYMENT_DUE_REMINDER_LEAD_TIME_MS,
  RECEIPT_REMINDER_DELAY_MS,
  REMINDER_QUERY_LOOKBACK_MS,
  SHIPMENT_REMINDER_DELAY_MS,
  isPaymentDueReminderCandidate,
  isReceiptReminderCandidate,
  isShipmentReminderCandidate,
} from './domain/orderReminderEngine.js';
import {
  buildDeactivateDeviceTokenRecord,
  buildDeviceTokenId,
  buildRegisterDeviceTokenRecord,
} from './domain/deviceTokenEngine.js';
import {
  buildReminderInboxNotificationId,
  buildPushDataPayload,
  getDeliverableTokens,
  getNotificationCategoryForType,
  InboxNotificationType,
  ReminderNotificationType,
  normalizeNotificationPreferences,
  shouldDispatchPush,
} from './domain/notificationDispatchEngine.js';
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

interface PaymentSessionResponse {
  provider: 'TOSS_PAYMENTS';
  mode: 'TOSS' | 'DEV_DUMMY';
  orderId: string;
  amount: number;
  orderName: string;
  customerKey: string | null;
  customerName: string | null;
  customerEmail: string | null;
  successUrl: string | null;
  failUrl: string | null;
  checkoutUrl: string | null;
  devPaymentKey: string | null;
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

function ensureEnumString<T extends readonly string[]>(
  value: unknown,
  fieldName: string,
  allowed: T,
): T[number] {
  const normalized = ensureString(value, fieldName);
  if (!allowed.includes(normalized)) {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} must be one of ${allowed.join(', ')}`,
    );
  }
  return normalized as T[number];
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

function buildDeepLink(
  target: `auction` | `orders` | `notifications`,
  id?: string,
) {
  if (target === 'notifications') {
    return 'app://notifications';
  }
  return id ? `app://${target}/${id}` : `app://${target}`;
}

function buildDevPaymentKey(orderId: string): string {
  return `dev_pay_${orderId}`;
}

function buildTossCustomerKey(uid: string): string {
  return `buyer_${uid}`;
}

async function createInboxNotification(
  uid: string,
  type: InboxNotificationType,
  title: string,
  body: string,
  deeplink: string,
  entityType: 'AUCTION' | 'ORDER',
  entityId: string,
  options?: {
    deterministicNotificationId?: string;
    precondition?: {
      ref: DocumentReference;
      isSatisfied: (docId: string, data: AnyRecord) => boolean;
    };
  },
): Promise<void> {
  const inboxCollectionRef = db
    .collection('notifications')
    .doc(uid)
    .collection('inbox');
  const ref = options?.deterministicNotificationId
    ? inboxCollectionRef.doc(options.deterministicNotificationId)
    : inboxCollectionRef.doc();
  const category = getNotificationCategoryForType(type);
  const timestamp = new Date().toISOString();

  const payload = {
    type,
    category,
    title,
    body,
    deeplink,
    entityType,
    entityId,
    isRead: false,
    createdAt: FieldValue.serverTimestamp(),
  };

  const created = options?.deterministicNotificationId
    ? await db.runTransaction(async (tx) => {
        if (options.precondition) {
          const conditionSnap = await tx.get(options.precondition.ref);
          if (!conditionSnap.exists) {
            return false;
          }
          const conditionData = conditionSnap.data();
          if (
            !conditionData ||
            !options.precondition.isSatisfied(
              conditionSnap.id,
              conditionData as AnyRecord,
            )
          ) {
            return false;
          }
        }
        const existing = await tx.get(ref);
        if (existing.exists) {
          return false;
        }
        tx.set(ref, payload);
        return true;
      })
    : true;
  if (!options?.deterministicNotificationId) {
    await ref.set(payload);
  }
  if (!created) {
    logger.info('createInboxNotification deduplicated', {
      uid,
      type,
      category,
      entityType,
      entityId,
      notificationId: ref.id,
    });
    return;
  }

  try {
    await dispatchPushForInboxNotification({
      uid,
      notificationId: ref.id,
      type,
      category,
      title,
      body,
      deeplink,
      entityType,
      entityId,
      timestamp,
    });
  } catch (error) {
    logger.error('dispatchPushForInboxNotification failed', {
      uid,
      notificationId: ref.id,
      type,
      category,
      entityType,
      entityId,
      message: error instanceof Error ? error.message : String(error),
    });
  }
}

async function dispatchPushForInboxNotification(input: {
  uid: string;
  notificationId: string;
  type: InboxNotificationType;
  category: ReturnType<typeof getNotificationCategoryForType>;
  title: string;
  body: string;
  deeplink: string;
  entityType: 'AUCTION' | 'ORDER';
  entityId: string;
  timestamp: string;
}): Promise<void> {
  const userRef = db.collection('users').doc(input.uid);
  const tokenCollectionRef = userRef.collection('deviceTokens');
  const [userSnap, tokenSnap] = await Promise.all([
    userRef.get(),
    tokenCollectionRef.get(),
  ]);

  const preferences = normalizeNotificationPreferences(userSnap.data());
  const tokens = getDeliverableTokens(
    tokenSnap.docs.map((doc) => {
      const data = doc.data();
      return {
        token: typeof data.token === 'string' ? data.token : null,
        isActive: data.isActive === true,
        permissionStatus:
          typeof data.permissionStatus === 'string'
            ? data.permissionStatus
            : null,
      };
    }),
  );

  if (!shouldDispatchPush(preferences, input.category, tokens.length)) {
    logger.info('dispatchPushForInboxNotification skipped', {
      uid: input.uid,
      notificationId: input.notificationId,
      type: input.type,
      category: input.category,
      pushEnabled: preferences.pushEnabled,
      categoryEnabled: preferences.notificationCategories[input.category],
      tokenCount: tokens.length,
    });
    return;
  }

  const response = await getMessaging().sendEachForMulticast({
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

  const failedCodes = response.responses
    .filter((entry) => !entry.success)
    .map((entry) => entry.error?.code)
    .filter((code): code is string => typeof code === 'string');

  logger.info('dispatchPushForInboxNotification sent', {
    uid: input.uid,
    notificationId: input.notificationId,
    type: input.type,
    category: input.category,
    tokenCount: tokens.length,
    successCount: response.successCount,
    failureCount: response.failureCount,
    failedCodes,
  });
}

async function writeAuditEvent(event: AuditEventRecord): Promise<void> {
  await db.collection('auditEvents').add({
    ...event,
    createdAt: FieldValue.serverTimestamp(),
  });
}

function queueAuditEvent(tx: Transaction, event: AuditEventRecord): void {
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
  appraisal: {
    status: 'NONE' | 'REQUESTED' | 'APPROVED' | 'REJECTED';
    badgeLabel: string | null;
  };
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
  if (
    !['NONE', 'REQUESTED', 'APPROVED', 'REJECTED'].includes(appraisalStatus)
  ) {
    throw new HttpsError('invalid-argument', 'invalid appraisal status');
  }

  const draftAuctionPayload =
    payload.draftAuction && typeof payload.draftAuction === 'object'
      ? (payload.draftAuction as AnyRecord)
      : {};
  const startPrice = optionalPositiveNumber(draftAuctionPayload.startPrice);
  const buyNowPrice = optionalPositiveNumber(draftAuctionPayload.buyNowPrice);
  const durationDays = optionalPositiveInteger(
    draftAuctionPayload.durationDays,
  );
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
      status: appraisalStatus as 'NONE' | 'REQUESTED' | 'APPROVED' | 'REJECTED',
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
    finalPrice: typeof data.finalPrice === 'number' ? data.finalPrice : 0,
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

function isReminderCandidateFromDocument(
  type: ReminderNotificationType,
  orderId: string,
  data: AnyRecord,
  now: Date,
): boolean {
  try {
    const order = deserializeOrder(orderId, data);
    switch (type) {
      case 'PAYMENT_DUE':
        return isPaymentDueReminderCandidate(order, now);
      case 'SHIPMENT_REMINDER':
        return isShipmentReminderCandidate(order, now);
      case 'RECEIPT_REMINDER':
        return isReceiptReminderCandidate(order, now);
    }
  } catch (error) {
    logger.warn('order reminder precondition parse failed', {
      orderId,
      type,
      message: error instanceof Error ? error.message : String(error),
    });
    return false;
  }
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

function readQueryString(
  value: unknown,
  fieldName: string,
  options: { allowEmpty?: boolean } = {},
): string {
  if (typeof value !== 'string') {
    throw new HttpsError('invalid-argument', `${fieldName} query is required.`);
  }

  const normalized = value.trim();
  if (!options.allowEmpty && normalized.length === 0) {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} query must not be empty.`,
    );
  }

  return normalized;
}

function readQueryAmount(value: unknown): number {
  const amountText = readQueryString(value, 'amount');
  if (!/^[1-9]\d*$/.test(amountText)) {
    throw new HttpsError(
      'invalid-argument',
      'amount query must be a positive integer.',
    );
  }
  return Number(amountText);
}

function readOptionalQueryString(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null;
  }
  const normalized = value.trim();
  return normalized.length > 0 ? normalized : null;
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function encodeJsString(value: string): string {
  return JSON.stringify(value);
}

function buildAppReturnLink(
  status: 'success' | 'fail',
  params: Record<string, string | null>,
): string {
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

function paymentBridgeHtml({
  title,
  description,
  body,
}: {
  title: string;
  description: string;
  body: string;
}): string {
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

function buildPaymentLaunchHtml(input: {
  clientKey: string;
  customerKey: string;
  orderId: string;
  amount: number;
  orderName: string;
  successUrl: string;
  failUrl: string;
  useDevCardOnlyWindow: boolean;
}): string {
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

function buildPaymentReturnHtml(input: {
  status: 'success' | 'fail';
  title: string;
  description: string;
  appReturnUrl: string;
  buttonLabel: string;
}): string {
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
        photoUrl:
          optionalString(existing?.photoUrl) ?? optionalString(token.picture),
        email: optionalString(token.email) ?? optionalString(existing?.email),
        phoneNumber:
          optionalString(token.phone_number) ??
          optionalString(existing?.phoneNumber),
        authProviders,
        bio: optionalString(existing?.bio),
        preferences: {
          languageCode:
            optionalString(
              (existing?.preferences as AnyRecord | undefined)?.languageCode,
            ) ?? 'ko',
          pushEnabled:
            typeof (existing?.preferences as AnyRecord | undefined)
              ?.pushEnabled === 'boolean'
              ? ((existing?.preferences as AnyRecord).pushEnabled as boolean)
              : true,
        },
        verification: {
          phone:
            optionalString(
              (existing?.verification as AnyRecord | undefined)?.phone,
            ) ?? 'UNVERIFIED',
          id:
            optionalString(
              (existing?.verification as AnyRecord | undefined)?.id,
            ) ?? 'UNVERIFIED',
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
            typeof (existing?.sellerStats as AnyRecord | undefined)
              ?.reviewAvg === 'number'
              ? ((existing?.sellerStats as AnyRecord).reviewAvg as number)
              : 0,
          gradeScore:
            typeof (existing?.sellerStats as AnyRecord | undefined)
              ?.gradeScore === 'number'
              ? ((existing?.sellerStats as AnyRecord).gradeScore as number)
              : 0,
        },
        penaltyStats: {
          unpaidCount:
            typeof (existing?.penaltyStats as AnyRecord | undefined)
              ?.unpaidCount === 'number'
              ? ((existing?.penaltyStats as AnyRecord).unpaidCount as number)
              : 0,
          depositForfeitedCount:
            typeof (existing?.penaltyStats as AnyRecord | undefined)
              ?.depositForfeitedCount === 'number'
              ? ((existing?.penaltyStats as AnyRecord)
                  .depositForfeitedCount as number)
              : 0,
          trustScore:
            typeof (existing?.penaltyStats as AnyRecord | undefined)
              ?.trustScore === 'number'
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
      eventType: snap.exists
        ? 'USER_PROFILE_SYNCED'
        : 'USER_PROFILE_BOOTSTRAPPED',
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
    throw new HttpsError(
      'failed-precondition',
      'At least one image is required',
    );
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
      throw new HttpsError(
        'permission-denied',
        'Only seller can cancel auction',
      );
    }
    if (!['DRAFT', 'LIVE'].includes(auction.status)) {
      throw new HttpsError(
        'failed-precondition',
        'Auction cannot be cancelled',
      );
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
      throw new HttpsError(
        'permission-denied',
        'Only seller can relist auction',
      );
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
  let autoBidCeilingReachedUserId: string | undefined;
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

    queueAuditEvent(tx, {
      entityType: 'AUCTION',
      entityId: auctionId,
      eventType: 'BID_PLACED',
      actorId: bidderId,
      payload: {
        amount: result.auction.currentPrice,
        bidCount: result.bids.length,
      },
    });
  });

  if (autoBidCeilingReachedUserId && autoBidCeilingReachedUserId !== bidderId) {
    await createInboxNotification(
      autoBidCeilingReachedUserId,
      'AUTO_BID_CEILING_REACHED',
      '자동입찰 한도에 도달했습니다',
      `현재 최고가 ${finalPrice}원으로 자동입찰 상한을 넘었습니다.`,
      buildDeepLink('auction', auctionId),
      'AUCTION',
      auctionId,
    );
  }

  if (
    outbidUserId &&
    outbidUserId !== bidderId &&
    outbidUserId !== autoBidCeilingReachedUserId
  ) {
    await createInboxNotification(
      outbidUserId,
      'OUTBID',
      '입찰가가 갱신되었습니다',
      `현재 최고가 ${finalPrice}원`,
      buildDeepLink('auction', auctionId),
      'AUCTION',
      auctionId,
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
      throw new HttpsError('failed-precondition', 'seller cannot set auto bid');
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

  const result = await db.runTransaction(async (tx) => {
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

    return {
      orderId: orderRef.id,
      buyerId: uid,
      sellerId: ensureString(auction.sellerId, 'sellerId'),
    };
  });

  await createInboxNotification(
    result.buyerId,
    'BUY_NOW_COMPLETED',
    '즉시 구매가 완료되었습니다',
    '결제 기한 내 결제를 진행해주세요.',
    buildDeepLink('orders', result.orderId),
    'ORDER',
    result.orderId,
  );
  await createInboxNotification(
    result.sellerId,
    'ORDER_AWAITING_PAYMENT',
    '새 주문이 결제 대기 중입니다',
    '구매자 결제 완료 후 배송 정보를 등록해주세요.',
    buildDeepLink('orders', result.orderId),
    'ORDER',
    result.orderId,
  );

  return { orderId: result.orderId };
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
  const allowDevDummyPayment = isDevDummyPaymentEnabled(config.appEnv);
  const paymentSession = buildPaymentSessionContract({
    appEnv: config.appEnv,
    appBaseUrl: config.appBaseUrl,
    orderId,
    allowDevDummyPayment,
    buildDevPaymentKey,
  });

  const response: PaymentSessionResponse = {
    provider: 'TOSS_PAYMENTS',
    mode: paymentSession.mode,
    orderId,
    amount: order.finalPrice,
    orderName: buildOrderName(order.auctionId),
    customerKey: buildTossCustomerKey(uid),
    customerName: optionalString(req.auth?.token?.name) ?? null,
    customerEmail: optionalString(req.auth?.token?.email) ?? null,
    successUrl: paymentSession.successUrl,
    failUrl: paymentSession.failUrl,
    checkoutUrl: paymentSession.checkoutUrl,
    devPaymentKey: paymentSession.devPaymentKey,
  };

  return response;
});

export const confirmOrderPayment = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(
    req.data,
    'payment confirmation payload is required',
  );
  const orderId = ensureString(payload.orderId, 'orderId');
  const paymentKey = ensureString(payload.paymentKey, 'paymentKey');
  const amount = typeof payload.amount === 'number' ? payload.amount : NaN;
  if (Number.isNaN(amount) || amount <= 0) {
    throw new HttpsError('invalid-argument', 'amount must be positive');
  }

  const config = getRuntimeConfig();
  const allowDevDummyPayment = isDevDummyPaymentEnabled(config.appEnv);
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
    if (allowDevDummyPayment && paymentKey === buildDevPaymentKey(orderId)) {
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
    const failedOrder = toFailedPaymentOrder(order);
    await orderRef.update({
      paymentStatus: failedOrder.paymentStatus,
      updatedAt: FieldValue.serverTimestamp(),
    });
    await createInboxNotification(
      order.buyerId,
      'PAYMENT_FAILED',
      '결제가 완료되지 않았습니다',
      '결제 정보를 확인한 뒤 다시 시도해주세요.',
      buildDeepLink('orders', orderId),
      'ORDER',
      orderId,
    );
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
    'ORDER',
    orderId,
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

export const tossPaymentBridge = onRequest(async (req, res) => {
  try {
    if (req.method !== 'GET') {
      res.set('Allow', 'GET');
      res.status(405).send('Method Not Allowed');
      return;
    }

    const runtime = getRuntimeConfig();
    const useDevCardOnlyWindow =
      runtime.appEnv === 'dev' &&
      process.env.ENABLE_TOSS_SANDBOX?.trim().toLowerCase() === 'true';
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
  } catch (error) {
    logger.error('tossPaymentBridge', error);
    const message =
      error instanceof HttpsError
        ? error.message
        : 'Invalid Toss payment bridge request.';
    res.status(400).send(message);
  }
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
        'ORDER',
        order.id,
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
    if (shouldApplyWebhookCancellation(order)) {
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
        payload: {
          orderId: order.id,
          status: payment.status,
          eventMarker,
          applied: true,
        },
      });
      await createInboxNotification(
        order.buyerId,
        'PAYMENT_FAILED',
        payment.status === 'EXPIRED'
          ? '결제 기한이 만료되었습니다'
          : '결제가 취소되었습니다',
        payment.status === 'EXPIRED'
          ? '미결제로 주문이 취소되었습니다.'
          : '결제가 완료되지 않아 주문이 취소되었습니다.',
        buildDeepLink('orders', order.id),
        'ORDER',
        order.id,
      );
    } else {
      const markedOrder = withLastWebhookEventId(order, eventMarker);
      await orderRef.update({
        ...serializeOrder(markedOrder),
        updatedAt: FieldValue.serverTimestamp(),
      });
      await writeAuditEvent({
        entityType: 'PAYMENT',
        entityId: payment.paymentKey ?? order.id,
        eventType: 'PAYMENT_WEBHOOK_CANCELLED',
        actorId: null,
        payload: {
          orderId: order.id,
          status: payment.status,
          eventMarker,
          applied: false,
        },
      });
    }
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
    throw new HttpsError(
      'permission-denied',
      'Only seller can update shipment',
    );
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
    'ORDER',
    orderId,
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
  await createInboxNotification(
    order.sellerId,
    'RECEIPT_CONFIRMED',
    '구매자가 수령을 확인했습니다',
    '정산 예정 일정을 확인해주세요.',
    buildDeepLink('orders', orderId),
    'ORDER',
    orderId,
  );

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

export const registerDeviceToken = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'device token payload is required');
  const token = ensureString(payload.token, 'token');
  const platform = ensureEnumString(payload.platform, 'platform', [
    'ANDROID',
    'IOS',
  ] as const);
  const appVersion = ensureString(payload.appVersion, 'appVersion');
  const locale = ensureString(payload.locale, 'locale');
  const timezone = ensureString(payload.timezone, 'timezone');
  const permissionStatus = ensureEnumString(
    payload.permissionStatus,
    'permissionStatus',
    ['AUTHORIZED', 'DENIED', 'PROVISIONAL', 'NOT_DETERMINED'] as const,
  );
  const tokenId = buildDeviceTokenId(token);
  logger.info('registerDeviceToken', {
    uid,
    platform,
    appVersion,
    permissionStatus,
  });
  const tokenRef = db
    .collection('users')
    .doc(uid)
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

  return { ok: true, tokenId };
});

export const deactivateDeviceToken = onCall(async (req) => {
  const uid = requireAuthUid(req.auth?.uid);
  const payload = ensureObject(req.data, 'device token payload is required');
  const tokenId = ensureString(payload.tokenId, 'tokenId');
  const permissionStatus = ensureEnumString(
    payload.permissionStatus,
    'permissionStatus',
    ['AUTHORIZED', 'DENIED', 'PROVISIONAL', 'NOT_DETERMINED'] as const,
  );
  logger.info('deactivateDeviceToken', {
    uid,
    permissionStatus,
  });
  const tokenRef = db
    .collection('users')
    .doc(uid)
    .collection('deviceTokens')
    .doc(tokenId);

  await tokenRef.set(
    buildDeactivateDeviceTokenRecord(
      permissionStatus,
      FieldValue.serverTimestamp(),
    ),
    { merge: true },
  );

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
              highestBidderId: ensureString(
                data.highestBidderId,
                'highestBidderId',
              ),
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

          return {
            buyerId: order.buyerId,
            sellerId: order.sellerId,
            orderId: orderRef.id,
          };
        }

        tx.update(doc.ref, {
          status: decision.nextStatus,
          updatedAt: FieldValue.serverTimestamp(),
        });
        queueAuditEvent(tx, {
          entityType: 'AUCTION',
          entityId: freshAuctionSnap.id,
          eventType:
            decision.nextStatus === 'UNSOLD'
              ? 'AUCTION_UNSOLD'
              : 'AUCTION_ENDED',
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
          'ORDER',
          notification.orderId,
        );
        await createInboxNotification(
          notification.sellerId,
          'ORDER_AWAITING_PAYMENT',
          '새 주문이 결제 대기 중입니다',
          '구매자 결제 완료 후 배송 정보를 등록해주세요.',
          buildDeepLink('orders', notification.orderId),
          'ORDER',
          notification.orderId,
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
          'PAYMENT_FAILED',
          '결제 기한이 만료되었습니다',
          '미결제로 주문이 취소되었고 패널티가 반영되었습니다.',
          buildDeepLink('orders', doc.id),
          'ORDER',
          doc.id,
        );
      }
    }
  },
);

export const orderReminderNotificationsScheduler = onSchedule(
  'every 30 minutes',
  async () => {
    const now = new Date();
    const nowTimestamp = Timestamp.fromDate(now);
    const paymentDueReminderCutoff = Timestamp.fromDate(
      new Date(now.getTime() + PAYMENT_DUE_REMINDER_LEAD_TIME_MS),
    );
    const shipmentReminderCutoff = Timestamp.fromDate(
      new Date(now.getTime() - SHIPMENT_REMINDER_DELAY_MS),
    );
    const receiptReminderCutoff = Timestamp.fromDate(
      new Date(now.getTime() - RECEIPT_REMINDER_DELAY_MS),
    );
    const shipmentReminderLookbackStart = Timestamp.fromDate(
      new Date(
        now.getTime() - SHIPMENT_REMINDER_DELAY_MS - REMINDER_QUERY_LOOKBACK_MS,
      ),
    );
    const receiptReminderLookbackStart = Timestamp.fromDate(
      new Date(
        now.getTime() - RECEIPT_REMINDER_DELAY_MS - REMINDER_QUERY_LOOKBACK_MS,
      ),
    );

    const [paymentDueSnap, shipmentReminderSnap, receiptReminderSnap] =
      await Promise.all([
        db
          .collection('orders')
          .where('orderStatus', '==', 'AWAITING_PAYMENT')
          .where('paymentDueAt', '>', nowTimestamp)
          .where('paymentDueAt', '<=', paymentDueReminderCutoff)
          .get(),
        db
          .collection('orders')
          .where('orderStatus', '==', 'PAID_ESCROW_HOLD')
          .where('payment.approvedAt', '>', shipmentReminderLookbackStart)
          .where('payment.approvedAt', '<=', shipmentReminderCutoff)
          .get(),
        db
          .collection('orders')
          .where('orderStatus', '==', 'SHIPPED')
          .where('shipping.shippedAt', '>', receiptReminderLookbackStart)
          .where('shipping.shippedAt', '<=', receiptReminderCutoff)
          .get(),
      ]);

    for (const doc of paymentDueSnap.docs) {
      const order = deserializeOrder(doc.id, doc.data() as AnyRecord);
      await createInboxNotification(
        order.buyerId,
        'PAYMENT_DUE',
        '결제 기한이 곧 만료됩니다',
        '결제 기한 전에 결제를 완료해주세요.',
        buildDeepLink('orders', order.id),
        'ORDER',
        order.id,
        {
          deterministicNotificationId: buildReminderInboxNotificationId({
            type: 'PAYMENT_DUE',
            orderId: order.id,
          }),
          precondition: {
            ref: doc.ref,
            isSatisfied: (freshOrderId, freshData) =>
              isReminderCandidateFromDocument(
                'PAYMENT_DUE',
                freshOrderId,
                freshData,
                now,
              ),
          },
        },
      );
    }

    for (const doc of shipmentReminderSnap.docs) {
      const order = deserializeOrder(doc.id, doc.data() as AnyRecord);
      await createInboxNotification(
        order.sellerId,
        'SHIPMENT_REMINDER',
        '배송 등록이 필요합니다',
        '결제 완료 주문의 배송 정보를 등록해주세요.',
        buildDeepLink('orders', order.id),
        'ORDER',
        order.id,
        {
          deterministicNotificationId: buildReminderInboxNotificationId({
            type: 'SHIPMENT_REMINDER',
            orderId: order.id,
          }),
          precondition: {
            ref: doc.ref,
            isSatisfied: (freshOrderId, freshData) =>
              isReminderCandidateFromDocument(
                'SHIPMENT_REMINDER',
                freshOrderId,
                freshData,
                now,
              ),
          },
        },
      );
    }

    for (const doc of receiptReminderSnap.docs) {
      const order = deserializeOrder(doc.id, doc.data() as AnyRecord);
      await createInboxNotification(
        order.buyerId,
        'RECEIPT_REMINDER',
        '수령 확인이 필요합니다',
        '배송 완료 주문의 수령 확인을 진행해주세요.',
        buildDeepLink('orders', order.id),
        'ORDER',
        order.id,
        {
          deterministicNotificationId: buildReminderInboxNotificationId({
            type: 'RECEIPT_REMINDER',
            orderId: order.id,
          }),
          precondition: {
            ref: doc.ref,
            isSatisfied: (freshOrderId, freshData) =>
              isReminderCandidateFromDocument(
                'RECEIPT_REMINDER',
                freshOrderId,
                freshData,
                now,
              ),
          },
        },
      );
    }

    logger.info('orderReminderNotificationsScheduler', {
      paymentDueCandidateCount: paymentDueSnap.size,
      shipmentReminderCandidateCount: shipmentReminderSnap.size,
      receiptReminderCandidateCount: receiptReminderSnap.size,
    });
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
      'ORDER',
      doc.id,
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
