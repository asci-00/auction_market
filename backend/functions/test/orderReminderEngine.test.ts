import { describe, expect, it } from 'vitest';
import { Order } from '../src/domain/models.js';
import {
  isPaymentDueReminderCandidate,
  isReceiptReminderCandidate,
  isShipmentReminderCandidate,
  PAYMENT_DUE_REMINDER_LEAD_TIME_MS,
  RECEIPT_REMINDER_DELAY_MS,
  REMINDER_QUERY_LOOKBACK_MS,
  SHIPMENT_REMINDER_DELAY_MS,
} from '../src/domain/orderReminderEngine.js';

function createOrder(overrides: Partial<Order>): Order {
  return {
    id: 'order-1',
    auctionId: 'auction-1',
    itemId: 'item-1',
    buyerId: 'buyer-1',
    sellerId: 'seller-1',
    finalPrice: 10000,
    paymentStatus: 'UNPAID',
    orderStatus: 'AWAITING_PAYMENT',
    paymentDueAt: new Date('2026-04-13T02:00:00.000Z'),
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
    fees: {
      feeRate: 0.1,
      feeAmount: 1000,
      sellerReceivable: 9000,
    },
    ...overrides,
  };
}

describe('orderReminderEngine', () => {
  it('detects payment due reminders inside the lead-time window only', () => {
    const now = new Date('2026-04-13T01:30:00.000Z');
    const order = createOrder({
      orderStatus: 'AWAITING_PAYMENT',
      paymentDueAt: new Date('2026-04-13T01:59:00.000Z'),
    });
    expect(isPaymentDueReminderCandidate(order, now)).toBe(true);

    const alreadyPaid = createOrder({
      orderStatus: 'PAID_ESCROW_HOLD',
      paymentDueAt: new Date('2026-04-13T01:59:00.000Z'),
    });
    expect(isPaymentDueReminderCandidate(alreadyPaid, now)).toBe(false);

    const outOfWindow = createOrder({
      orderStatus: 'AWAITING_PAYMENT',
      paymentDueAt: new Date('2026-04-13T03:00:00.000Z'),
    });
    expect(isPaymentDueReminderCandidate(outOfWindow, now)).toBe(false);

    const dueNowBoundary = createOrder({
      orderStatus: 'AWAITING_PAYMENT',
      paymentDueAt: new Date(now.getTime()),
    });
    expect(isPaymentDueReminderCandidate(dueNowBoundary, now)).toBe(false);

    const dueAtLeadTimeBoundary = createOrder({
      orderStatus: 'AWAITING_PAYMENT',
      paymentDueAt: new Date(now.getTime() + PAYMENT_DUE_REMINDER_LEAD_TIME_MS),
    });
    expect(isPaymentDueReminderCandidate(dueAtLeadTimeBoundary, now)).toBe(
      true,
    );
  });

  it('detects shipment reminders only for pending shipment orders in lookback', () => {
    const now = new Date('2026-04-13T12:00:00.000Z');
    const eligibleOrder = createOrder({
      orderStatus: 'PAID_ESCROW_HOLD',
      paymentStatus: 'PAID',
      payment: {
        provider: 'TOSS_PAYMENTS',
        paymentKey: 'pay-key',
        method: 'CARD',
        approvedAt: new Date('2026-04-12T10:00:00.000Z'),
        lastWebhookEventId: null,
      },
    });
    expect(isShipmentReminderCandidate(eligibleOrder, now)).toBe(true);

    const shippedOrder = createOrder({
      orderStatus: 'SHIPPED',
      paymentStatus: 'PAID',
      payment: {
        provider: 'TOSS_PAYMENTS',
        paymentKey: 'pay-key',
        method: 'CARD',
        approvedAt: new Date('2026-04-12T10:00:00.000Z'),
        lastWebhookEventId: null,
      },
    });
    expect(isShipmentReminderCandidate(shippedOrder, now)).toBe(false);

    const noApprovedAt = createOrder({
      orderStatus: 'PAID_ESCROW_HOLD',
      paymentStatus: 'PAID',
      payment: {
        provider: 'TOSS_PAYMENTS',
        paymentKey: 'pay-key',
        method: 'CARD',
        approvedAt: null,
        lastWebhookEventId: null,
      },
    });
    expect(isShipmentReminderCandidate(noApprovedAt, now)).toBe(false);

    const boundaryApprovedAt = new Date(
      now.getTime() - SHIPMENT_REMINDER_DELAY_MS - REMINDER_QUERY_LOOKBACK_MS,
    );
    const boundaryOrder = createOrder({
      orderStatus: 'PAID_ESCROW_HOLD',
      paymentStatus: 'PAID',
      payment: {
        provider: 'TOSS_PAYMENTS',
        paymentKey: 'pay-key',
        method: 'CARD',
        approvedAt: boundaryApprovedAt,
        lastWebhookEventId: null,
      },
    });
    expect(isShipmentReminderCandidate(boundaryOrder, now)).toBe(true);
  });

  it('detects receipt reminders only for shipped orders in lookback', () => {
    const now = new Date('2026-04-13T12:00:00.000Z');
    const eligibleOrder = createOrder({
      orderStatus: 'SHIPPED',
      paymentStatus: 'PAID',
      shipping: {
        carrierCode: 'CJ',
        carrierName: 'CJ',
        trackingNumber: '123',
        trackingUrl: null,
        shippedAt: new Date('2026-04-12T08:00:00.000Z'),
      },
    });
    expect(isReceiptReminderCandidate(eligibleOrder, now)).toBe(true);

    const confirmedOrder = createOrder({
      orderStatus: 'CONFIRMED_RECEIPT',
      paymentStatus: 'PAID',
      shipping: {
        carrierCode: 'CJ',
        carrierName: 'CJ',
        trackingNumber: '123',
        trackingUrl: null,
        shippedAt: new Date('2026-04-12T08:00:00.000Z'),
      },
    });
    expect(isReceiptReminderCandidate(confirmedOrder, now)).toBe(false);

    const noShippedAt = createOrder({
      orderStatus: 'SHIPPED',
      paymentStatus: 'PAID',
      shipping: {
        carrierCode: 'CJ',
        carrierName: 'CJ',
        trackingNumber: '123',
        trackingUrl: null,
        shippedAt: null,
      },
    });
    expect(isReceiptReminderCandidate(noShippedAt, now)).toBe(false);

    const boundaryShippedAt = new Date(
      now.getTime() - RECEIPT_REMINDER_DELAY_MS - REMINDER_QUERY_LOOKBACK_MS,
    );
    const boundaryOrder = createOrder({
      orderStatus: 'SHIPPED',
      paymentStatus: 'PAID',
      shipping: {
        carrierCode: 'CJ',
        carrierName: 'CJ',
        trackingNumber: '123',
        trackingUrl: null,
        shippedAt: boundaryShippedAt,
      },
    });
    expect(isReceiptReminderCandidate(boundaryOrder, now)).toBe(true);
  });
});
