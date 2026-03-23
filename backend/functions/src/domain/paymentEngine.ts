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
