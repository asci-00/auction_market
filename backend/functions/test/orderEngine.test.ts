import { describe, expect, it } from 'vitest';
import { applyUnpaidPenalty, expireUnpaidOrders } from '../src/domain/orderEngine.js';

describe('order engine', () => {
  it('expires overdue unpaid order and applies penalty', () => {
    const orders: any[] = [{
      id: 'o1', auctionId: 'a1', buyerId: 'b1', sellerId: 's1', finalPrice: 100000,
      paymentStatus: 'UNPAID', orderStatus: 'AWAITING_PAYMENT', paymentDueAt: new Date(Date.now() - 1000),
    }];
    const updated = expireUnpaidOrders(new Date(), orders);
    expect(updated[0].orderStatus).toBe('CANCELLED_UNPAID');

    const penalty = applyUnpaidPenalty({ unpaidCount: 0, depositForfeitedCount: 0, trustScore: 80 }, 100000);
    expect(penalty.unpaidCount).toBe(1);
    expect(penalty.depositForfeitedCount).toBe(1);
    expect(penalty.forfeited).toBeGreaterThan(0);
  });
});
