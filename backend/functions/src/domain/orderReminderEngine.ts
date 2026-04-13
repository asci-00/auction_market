import { Order } from './models.js';

export const PAYMENT_DUE_REMINDER_LEAD_TIME_MS = 60 * 60 * 1000;
export const SHIPMENT_REMINDER_DELAY_MS = 24 * 60 * 60 * 1000;
export const RECEIPT_REMINDER_DELAY_MS = 24 * 60 * 60 * 1000;
export const REMINDER_QUERY_LOOKBACK_MS = 72 * 60 * 60 * 1000;

export function isPaymentDueReminderCandidate(
  order: Order,
  now: Date,
): boolean {
  if (order.orderStatus !== 'AWAITING_PAYMENT') {
    return false;
  }
  const dueAt = order.paymentDueAt.getTime();
  const nowMs = now.getTime();
  return dueAt > nowMs && dueAt <= nowMs + PAYMENT_DUE_REMINDER_LEAD_TIME_MS;
}

export function isShipmentReminderCandidate(order: Order, now: Date): boolean {
  if (order.orderStatus !== 'PAID_ESCROW_HOLD') {
    return false;
  }
  const approvedAt = order.payment.approvedAt;
  if (!approvedAt) {
    return false;
  }

  const nowMs = now.getTime();
  const approvedAtMs = approvedAt.getTime();
  const reminderEligibleAt = nowMs - SHIPMENT_REMINDER_DELAY_MS;
  const lookbackStartAt = reminderEligibleAt - REMINDER_QUERY_LOOKBACK_MS;

  return approvedAtMs <= reminderEligibleAt && approvedAtMs > lookbackStartAt;
}

export function isReceiptReminderCandidate(order: Order, now: Date): boolean {
  if (order.orderStatus !== 'SHIPPED') {
    return false;
  }
  const shippedAt = order.shipping.shippedAt;
  if (!shippedAt) {
    return false;
  }

  const nowMs = now.getTime();
  const shippedAtMs = shippedAt.getTime();
  const reminderEligibleAt = nowMs - RECEIPT_REMINDER_DELAY_MS;
  const lookbackStartAt = reminderEligibleAt - REMINDER_QUERY_LOOKBACK_MS;

  return shippedAtMs <= reminderEligibleAt && shippedAtMs > lookbackStartAt;
}
