import { Order } from './models.js';

export interface AuctionSnapshot {
  id: string;
  itemId: string;
  sellerId: string;
  status: 'LIVE' | 'ENDED' | 'UNSOLD' | 'CANCELLED' | 'DRAFT';
  endAt: Date;
  currentPrice: number;
  highestBidderId?: string | null;
}

export function finalizeAuction(auction: AuctionSnapshot, now: Date): { nextStatus: 'ENDED' | 'UNSOLD'; shouldFinalize: boolean } {
  if (auction.status !== 'LIVE' || auction.endAt > now) return { nextStatus: 'UNSOLD', shouldFinalize: false };
  if (auction.highestBidderId) return { nextStatus: 'ENDED', shouldFinalize: true };
  return { nextStatus: 'UNSOLD', shouldFinalize: true };
}

export function toAwaitingPaymentOrder(auction: AuctionSnapshot, now: Date): Omit<Order, 'id'> {
  return {
    auctionId: auction.id,
    itemId: auction.itemId,
    buyerId: auction.highestBidderId!,
    sellerId: auction.sellerId,
    finalPrice: auction.currentPrice,
    paymentStatus: 'UNPAID',
    orderStatus: 'AWAITING_PAYMENT',
    paymentDueAt: new Date(now.getTime() + 24 * 60 * 60 * 1000),
  };
}

export function shouldSettle(orderStatus: string, expectedAt: Date, now: Date): boolean {
  return orderStatus === 'CONFIRMED_RECEIPT' && expectedAt <= now;
}
