export type AuctionStatus = 'DRAFT' | 'LIVE' | 'ENDED' | 'UNSOLD' | 'CANCELLED';
export type BidKind = 'MANUAL' | 'AUTO';
export type PaymentStatus =
  | 'UNPAID'
  | 'PENDING'
  | 'PAID'
  | 'FAILED'
  | 'CANCELLED'
  | 'REFUNDED';
export type OrderStatus =
  | 'AWAITING_PAYMENT'
  | 'PAID_ESCROW_HOLD'
  | 'SHIPPED'
  | 'CONFIRMED_RECEIPT'
  | 'SETTLED'
  | 'CANCELLED_UNPAID'
  | 'CANCELLED';

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

export interface OrderPayment {
  provider: 'TOSS_PAYMENTS';
  paymentKey: string | null;
  method: string | null;
  approvedAt: Date | null;
  lastWebhookEventId: string | null;
}

export interface OrderShipping {
  carrierCode: string | null;
  carrierName: string | null;
  trackingNumber: string | null;
  trackingUrl: string | null;
  shippedAt: Date | null;
}

export interface OrderSettlement {
  expectedAt: Date | null;
  settledAt: Date | null;
  payoutBatchId: string | null;
}

export interface OrderFees {
  feeRate: number;
  feeAmount: number;
  sellerReceivable: number;
}

export interface Order {
  id: string;
  auctionId: string;
  itemId: string;
  buyerId: string;
  sellerId: string;
  finalPrice: number;
  paymentStatus: PaymentStatus;
  orderStatus: OrderStatus;
  paymentDueAt: Date;
  payment: OrderPayment;
  shipping: OrderShipping;
  settlement: OrderSettlement;
  fees: OrderFees;
}

export interface UserPenaltyStats {
  unpaidCount: number;
  depositForfeitedCount: number;
  trustScore: number;
}

export interface AuditEventRecord {
  entityType: 'AUCTION' | 'ORDER' | 'PAYMENT' | 'USER';
  entityId: string;
  eventType: string;
  actorId: string | null;
  payload: Record<string, unknown>;
}
