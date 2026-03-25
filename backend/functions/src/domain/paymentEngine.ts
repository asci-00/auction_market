import { HttpsError } from 'firebase-functions/v2/https';
import { Order } from './models.js';

export interface ConfirmedPayment {
  paymentKey: string;
  method: string | null;
  approvedAt: Date;
  totalAmount: number;
  status: string;
}

export interface TossWebhookPayment {
  orderId: string;
  paymentKey: string | null;
  method: string | null;
  totalAmount: number | null;
  status: string | null;
  secret: string | null;
  approvedAt: Date | null;
}

export interface PaymentSessionContract {
  mode: 'TOSS' | 'DEV_DUMMY';
  successUrl: string | null;
  failUrl: string | null;
  devPaymentKey: string | null;
}

export function isDevDummyPaymentEnabled(
  appEnv: 'dev' | 'staging' | 'prod',
  env: NodeJS.ProcessEnv = process.env,
): boolean {
  if (appEnv !== 'dev') {
    return false;
  }

  const firestoreHost = env.FIRESTORE_EMULATOR_HOST?.trim();
  return env.FUNCTIONS_EMULATOR === 'true' || Boolean(firestoreHost);
}

export function buildPaymentSessionContract({
  appEnv,
  appBaseUrl,
  orderId,
  allowDevDummyPayment,
  buildDevPaymentKey,
}: {
  appEnv: 'dev' | 'staging' | 'prod';
  appBaseUrl: string | null;
  orderId: string;
  allowDevDummyPayment: boolean;
  buildDevPaymentKey: (orderId: string) => string;
}): PaymentSessionContract {
  if (appEnv !== 'dev' && allowDevDummyPayment) {
    throw new HttpsError(
      'failed-precondition',
      'Dev dummy payment can only be enabled in dev.',
    );
  }
  if (appEnv !== 'dev' && !appBaseUrl) {
    throw new HttpsError(
      'failed-precondition',
      'APP_BASE_URL is required outside dev builds.',
    );
  }
  if (!allowDevDummyPayment && !appBaseUrl) {
    throw new HttpsError(
      'failed-precondition',
      'APP_BASE_URL is required when dev dummy payment is unavailable.',
    );
  }

  const normalizedBaseUrl = normalizeAppBaseUrl(appBaseUrl);
  const successUrl = normalizedBaseUrl
    ? `${normalizedBaseUrl}/payments/success?orderId=${orderId}`
    : null;
  const failUrl = normalizedBaseUrl
    ? `${normalizedBaseUrl}/payments/fail?orderId=${orderId}`
    : null;

  return {
    mode: allowDevDummyPayment ? 'DEV_DUMMY' : 'TOSS',
    successUrl,
    failUrl,
    devPaymentKey: allowDevDummyPayment ? buildDevPaymentKey(orderId) : null,
  };
}

export function isDuplicatePaymentConfirmation(
  order: Order,
  paymentKey: string,
  amount: number,
): boolean {
  return (
    order.paymentStatus === 'PAID' &&
    order.payment.paymentKey === paymentKey &&
    order.finalPrice === amount
  );
}

export function toConfirmedPaymentOrder(
  order: Order,
  payment: ConfirmedPayment,
  webhookEventId: string | null,
): Order {
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

export function withLastWebhookEventId(
  order: Order,
  webhookEventId: string | null,
): Order {
  return {
    ...order,
    payment: {
      ...order.payment,
      lastWebhookEventId: webhookEventId,
    },
  };
}

export function toFailedPaymentOrder(order: Order): Order {
  return {
    ...order,
    paymentStatus: 'FAILED',
  };
}

export function toCancelledPaymentOrder(
  order: Order,
  webhookEventId: string | null,
): Order {
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

export function buildWebhookEventMarker(
  eventType: string,
  createdAt: string | null | undefined,
  paymentKey: string | null,
  status: string | null,
): string {
  return [
    eventType,
    createdAt ?? 'unknown',
    paymentKey ?? 'no-key',
    status ?? 'unknown',
  ]
    .join(':')
    .replace(/\s+/g, '_');
}

export function extractWebhookSecret(
  payload: Record<string, unknown>,
): string | null {
  const rootSecret = typeof payload.secret === 'string' ? payload.secret : null;
  if (rootSecret) {
    return rootSecret;
  }

  const data = payload.data;
  if (data && typeof data === 'object') {
    const nestedSecret = (data as Record<string, unknown>).secret;
    if (typeof nestedSecret === 'string') {
      return nestedSecret;
    }
  }

  return null;
}

export function normalizeWebhookPayment(
  payload: Record<string, unknown>,
): TossWebhookPayment | null {
  const data = payload.data;
  if (!data || typeof data !== 'object') {
    return null;
  }

  const payment = data as Record<string, unknown>;
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

function normalizeAppBaseUrl(appBaseUrl: string | null): string | null {
  if (!appBaseUrl?.trim()) {
    return null;
  }

  let parsed: URL;
  try {
    parsed = new URL(appBaseUrl);
  } catch {
    throw new HttpsError(
      'failed-precondition',
      'APP_BASE_URL must be a valid http or https URL.',
    );
  }

  if (!['http:', 'https:'].includes(parsed.protocol)) {
    throw new HttpsError(
      'failed-precondition',
      'APP_BASE_URL must use http or https.',
    );
  }

  parsed.pathname = parsed.pathname.replace(/\/$/, '');
  parsed.search = '';
  parsed.hash = '';
  return parsed.toString().replace(/\/$/, '');
}
