import { describe, expect, it } from 'vitest';
import {
  applyUnpaidPenalty,
  buildOrderFees,
  expireUnpaidOrders,
} from '../src/domain/orderEngine.js';

describe('order engine', () => {
  it('expires overdue unpaid order and applies penalty', () => {
    const orders = [
      {
        id: 'o1',
        auctionId: 'a1',
        itemId: 'i1',
        buyerId: 'b1',
        sellerId: 's1',
        finalPrice: 100000,
        paymentStatus: 'UNPAID' as const,
        orderStatus: 'AWAITING_PAYMENT' as const,
        paymentDueAt: new Date(Date.now() - 1000),
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
        fees: buildOrderFees(100000),
      },
    ];

    const updated = expireUnpaidOrders(new Date(), orders);
    expect(updated[0].orderStatus).toBe('CANCELLED_UNPAID');
    expect(updated[0].paymentStatus).toBe('CANCELLED');

    const penalty = applyUnpaidPenalty(
      { unpaidCount: 0, depositForfeitedCount: 0, trustScore: 80 },
      100000,
    );
    expect(penalty.unpaidCount).toBe(1);
    expect(penalty.depositForfeitedCount).toBe(1);
    expect(penalty.forfeited).toBeGreaterThan(0);
  });

  it('builds fee summary with seller receivable', () => {
    const fees = buildOrderFees(200000);
    expect(fees.feeRate).toBe(0.05);
    expect(fees.feeAmount).toBe(10000);
    expect(fees.sellerReceivable).toBe(190000);
  });
});
