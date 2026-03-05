import { describe, expect, it } from 'vitest';
import { finalizeAuction, shouldSettle, toAwaitingPaymentOrder } from '../src/domain/schedulerEngine.js';

describe('scheduler engine', () => {
  it('finalizes live auction to ended if there is highest bidder', () => {
    const now = new Date();
    const result = finalizeAuction({
      id: 'a1', itemId: 'i1', sellerId: 's1', status: 'LIVE', endAt: new Date(now.getTime() - 1_000), currentPrice: 10000, highestBidderId: 'u1',
    }, now);
    expect(result.shouldFinalize).toBe(true);
    expect(result.nextStatus).toBe('ENDED');
  });

  it('builds order due time 24h after now', () => {
    const now = new Date();
    const order = toAwaitingPaymentOrder({
      id: 'a1', itemId: 'i1', sellerId: 's1', status: 'LIVE', endAt: new Date(now.getTime() - 1_000), currentPrice: 12000, highestBidderId: 'u2',
    }, now);
    expect(order.orderStatus).toBe('AWAITING_PAYMENT');
    expect(order.paymentDueAt.getTime()).toBeGreaterThan(now.getTime());
  });

  it('settles only when expectedAt passed', () => {
    const now = new Date();
    expect(shouldSettle('CONFIRMED_RECEIPT', new Date(now.getTime() - 1000), now)).toBe(true);
    expect(shouldSettle('CONFIRMED_RECEIPT', new Date(now.getTime() + 1000), now)).toBe(false);
  });
});
