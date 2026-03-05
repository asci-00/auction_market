export type AuctionStatus = 'DRAFT' | 'LIVE' | 'ENDED' | 'UNSOLD' | 'CANCELLED';
export type BidKind = 'MANUAL' | 'AUTO';

export interface Auction {
  id: string;
  itemId: string;
  sellerId: string;
  startPrice: number;
  buyNowPrice?: number | null;
  currentPrice: number;
  status: AuctionStatus;
  endAt: Date;
  extendedCount: number;
  bidCount: number;
  bidderCount: number;
  highestBidderId?: string | null;
}

export interface Bid {
  bidderId: string;
  amount: number;
  kind: BidKind;
  createdAt: Date;
}

export interface AutoBidConfig {
  uid: string;
  maxAmount: number;
  isEnabled: boolean;
}

export interface Order {
  id: string;
  auctionId: string;
  buyerId: string;
  sellerId: string;
  finalPrice: number;
  paymentStatus: 'UNPAID' | 'PAID' | 'FAILED' | 'CANCELLED';
  orderStatus:
    | 'AWAITING_PAYMENT'
    | 'PAID_ESCROW_HOLD'
    | 'SHIPPED'
    | 'DELIVERED'
    | 'CONFIRMED_RECEIPT'
    | 'SETTLED'
    | 'CANCELLED_UNPAID';
  paymentDueAt: Date;
}

export interface UserPenaltyStats {
  unpaidCount: number;
  depositForfeitedCount: number;
  trustScore: number;
}
