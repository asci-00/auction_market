import { describe, expect, it } from 'vitest';
import {
  buildWebhookEventMarker,
  extractWebhookSecret,
  isDuplicatePaymentConfirmation,
  normalizeWebhookPayment,
  toCancelledPaymentOrder,
  toConfirmedPaymentOrder,
  withLastWebhookEventId,
} from '../src/domain/paymentEngine.js';
import { buildOrderFees } from '../src/domain/orderEngine.js';

const baseOrder = {
  id: 'order-1',
  auctionId: 'auction-1',
  itemId: 'item-1',
  buyerId: 'buyer-1',
  sellerId: 'seller-1',
  finalPrice: 18000,
  paymentStatus: 'UNPAID' as const,
  orderStatus: 'AWAITING_PAYMENT' as const,
  paymentDueAt: new Date('2026-03-17T00:00:00.000Z'),
  payment: {
    provider: 'TOSS_PAYMENTS' as const,
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
  fees: buildOrderFees(18000),
};

describe('payment engine', () => {
  it('marks confirmed payments as paid escrow hold', () => {
    const updated = toConfirmedPaymentOrder(
      baseOrder,
      {
        paymentKey: 'pay_1',
        method: 'CARD',
        approvedAt: new Date('2026-03-17T01:00:00.000Z'),
        totalAmount: 18000,
        status: 'DONE',
      },
      'event-1',
    );

    expect(updated.paymentStatus).toBe('PAID');
    expect(updated.orderStatus).toBe('PAID_ESCROW_HOLD');
    expect(updated.payment.paymentKey).toBe('pay_1');
    expect(updated.payment.lastWebhookEventId).toBe('event-1');
  });

  it('detects duplicate payment confirmation and normalizes webhook payload', () => {
    const paidOrder = toConfirmedPaymentOrder(
      baseOrder,
      {
        paymentKey: 'pay_1',
        method: 'CARD',
        approvedAt: new Date('2026-03-17T01:00:00.000Z'),
        totalAmount: 18000,
        status: 'DONE',
      },
      null,
    );

    expect(isDuplicatePaymentConfirmation(paidOrder, 'pay_1', 18000)).toBe(
      true,
    );

    const webhook = normalizeWebhookPayment({
      data: {
        orderId: 'order-1',
        paymentKey: 'pay_1',
        method: 'CARD',
        totalAmount: 18000,
        status: 'DONE',
        secret: 'whsec_test',
        approvedAt: '2026-03-17T01:00:00.000Z',
      },
    });

    expect(webhook?.orderId).toBe('order-1');
    expect(webhook?.status).toBe('DONE');
    expect(extractWebhookSecret({ data: { secret: 'whsec_test' } })).toBe(
      'whsec_test',
    );
    expect(
      buildWebhookEventMarker(
        'PAYMENT_STATUS_CHANGED',
        '2026-03-17T01:00:00Z',
        'pay_1',
        'DONE',
      ),
    ).toContain('PAYMENT_STATUS_CHANGED');
  });

  it('marks cancelled webhook payments as cancelled orders', () => {
    const cancelled = toCancelledPaymentOrder(baseOrder, 'event-cancelled');
    expect(cancelled.paymentStatus).toBe('CANCELLED');
    expect(cancelled.orderStatus).toBe('CANCELLED');
    expect(cancelled.payment.lastWebhookEventId).toBe('event-cancelled');
  });

  it('updates webhook marker without replaying payment state transitions', () => {
    const paidOrder = toConfirmedPaymentOrder(
      baseOrder,
      {
        paymentKey: 'pay_1',
        method: 'CARD',
        approvedAt: new Date('2026-03-17T01:00:00.000Z'),
        totalAmount: 18000,
        status: 'DONE',
      },
      'event-1',
    );

    const updated = withLastWebhookEventId(paidOrder, 'event-2');

    expect(updated.paymentStatus).toBe('PAID');
    expect(updated.orderStatus).toBe('PAID_ESCROW_HOLD');
    expect(updated.payment.paymentKey).toBe('pay_1');
    expect(updated.payment.lastWebhookEventId).toBe('event-2');
  });
});
