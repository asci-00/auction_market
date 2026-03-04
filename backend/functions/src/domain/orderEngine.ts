import { calcDepositForfeit, depositPolicy } from '../config/policy.js';
import { Order, UserPenaltyStats } from './models.js';

export function expireUnpaidOrders(now: Date, orders: Order[]): Order[] {
  return orders.map((order) => {
    if (order.orderStatus === 'AWAITING_PAYMENT' && order.paymentDueAt <= now) {
      return {
        ...order,
        orderStatus: 'CANCELLED_UNPAID',
        paymentStatus: 'CANCELLED',
      };
    }
    return order;
  });
}

export function applyUnpaidPenalty(stats: UserPenaltyStats, finalPrice: number): UserPenaltyStats & { forfeited: number } {
  const forfeited = calcDepositForfeit(finalPrice);
  return {
    ...stats,
    unpaidCount: stats.unpaidCount + 1,
    depositForfeitedCount: stats.depositForfeitedCount + 1,
    trustScore: Math.max(0, stats.trustScore - depositPolicy.trustScorePenalty),
    forfeited,
  };
}
