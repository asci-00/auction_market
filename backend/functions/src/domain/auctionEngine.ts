import {
  antiSnipingPolicy,
  featureFlags,
  minIncrementFor,
} from '../config/policy.js';
import { Auction, AutoBidConfig, Bid } from './models.js';

export interface PlaceBidInput {
  auction: Auction;
  bidderId: string;
  amount: number;
  now: Date;
  autoBids?: AutoBidConfig[];
}

export interface PlaceBidResult {
  auction: Auction;
  bids: Bid[];
  outbidUserId?: string;
}

function validateBid(auction: Auction, amount: number, now: Date): void {
  if (auction.status !== 'LIVE') throw new Error('Auction not live');
  if (now >= auction.endAt) throw new Error('Auction ended');
  const increment = minIncrementFor(auction.currentPrice);
  const minAmount = auction.currentPrice + increment;
  if (amount < minAmount) throw new Error(`Bid too low. minimum=${minAmount}`);
}

function applyAntiSniping(auction: Auction, now: Date): Auction {
  const secondsLeft = Math.floor(
    (auction.endAt.getTime() - now.getTime()) / 1000,
  );
  if (
    secondsLeft <= antiSnipingPolicy.triggerSecondsBeforeEnd &&
    auction.extendedCount < antiSnipingPolicy.maxExtensions
  ) {
    return {
      ...auction,
      endAt: new Date(
        auction.endAt.getTime() + antiSnipingPolicy.extensionSeconds * 1000,
      ),
      extendedCount: auction.extendedCount + 1,
    };
  }
  return auction;
}

function resolveAutoBidCompetition(
  auction: Auction,
  leadingBidderId: string,
  autoBids: AutoBidConfig[],
  now: Date,
): { auction: Auction; bids: Bid[] } {
  const enabled = autoBids
    .filter((a) => a.isEnabled)
    .sort((a, b) => b.maxAmount - a.maxAmount);
  if (enabled.length < 1) return { auction, bids: [] };

  const bids: Bid[] = [];
  let current = { ...auction, highestBidderId: leadingBidderId };
  let guard = 0;

  while (guard < 20) {
    guard += 1;
    const challenger = enabled.find(
      (c) =>
        c.uid !== current.highestBidderId &&
        c.maxAmount >=
          current.currentPrice + minIncrementFor(current.currentPrice),
    );
    if (!challenger) break;

    const nextPrice =
      current.currentPrice + minIncrementFor(current.currentPrice);
    if (nextPrice > challenger.maxAmount) break;

    bids.push({
      bidderId: challenger.uid,
      amount: nextPrice,
      kind: 'AUTO',
      createdAt: now,
    });
    current = {
      ...current,
      currentPrice: nextPrice,
      highestBidderId: challenger.uid,
      bidCount: current.bidCount + 1,
    };
  }

  return { auction: current, bids };
}

export function placeBid(input: PlaceBidInput): PlaceBidResult {
  validateBid(input.auction, input.amount, input.now);

  const outbidUserId = input.auction.highestBidderId ?? undefined;
  let auction: Auction = {
    ...input.auction,
    currentPrice: input.amount,
    highestBidderId: input.bidderId,
    bidCount: input.auction.bidCount + 1,
    bidderCount:
      input.auction.highestBidderId === input.bidderId
        ? input.auction.bidderCount
        : input.auction.bidderCount + 1,
  };

  auction = applyAntiSniping(auction, input.now);

  const bids: Bid[] = [
    {
      bidderId: input.bidderId,
      amount: input.amount,
      kind: 'MANUAL',
      createdAt: input.now,
    },
  ];

  if (featureFlags.autoBid && input.autoBids?.length) {
    const auto = resolveAutoBidCompetition(
      auction,
      input.bidderId,
      input.autoBids,
      input.now,
    );
    auction = auto.auction;
    bids.push(...auto.bids);
  }

  return { auction, bids, outbidUserId };
}
