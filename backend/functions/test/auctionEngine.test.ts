import { describe, expect, it } from 'vitest';
import { placeBid } from '../src/domain/auctionEngine.js';
import { featureFlags } from '../src/config/policy.js';

describe('auction engine', () => {
  it('extends auction by 5 minutes near end, max 3', () => {
    const baseEnd = new Date(Date.now() + 4 * 60 * 1000);
    let auction: any = {
      id: 'a1',
      itemId: 'i1',
      sellerId: 's1',
      startPrice: 10000,
      currentPrice: 10000,
      status: 'LIVE',
      endAt: baseEnd,
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
    };

    for (let i = 0; i < 4; i += 1) {
      const result = placeBid({
        auction,
        bidderId: `u${i}`,
        amount: auction.currentPrice + 1000,
        now: new Date(),
      });
      auction = result.auction;
      auction.endAt = new Date(Date.now() + 4 * 60 * 1000);
    }

    expect(auction.extendedCount).toBe(3);
  });

  it('auto-bid competition rises and determines highest bidder', () => {
    featureFlags.autoBid = true;
    const auction: any = {
      id: 'a1',
      itemId: 'i1',
      sellerId: 's1',
      startPrice: 10000,
      currentPrice: 10000,
      status: 'LIVE',
      endAt: new Date(Date.now() + 60 * 60 * 1000),
      extendedCount: 0,
      bidCount: 0,
      bidderCount: 0,
    };

    const result = placeBid({
      auction,
      bidderId: 'manualUser',
      amount: 11000,
      now: new Date(),
      autoBids: [
        { uid: 'auto1', maxAmount: 14000, isEnabled: true },
        { uid: 'auto2', maxAmount: 16000, isEnabled: true },
      ],
    });

    expect(result.auction.currentPrice).toBeGreaterThan(11000);
    expect(result.auction.highestBidderId).toBe('auto2');
  });

  it('signals auto-bid ceiling reached when prior leader loses due to cap', () => {
    featureFlags.autoBid = true;
    const auction: any = {
      id: 'a1',
      itemId: 'i1',
      sellerId: 's1',
      startPrice: 10000,
      currentPrice: 12000,
      status: 'LIVE',
      endAt: new Date(Date.now() + 60 * 60 * 1000),
      extendedCount: 0,
      bidCount: 3,
      bidderCount: 2,
      highestBidderId: 'auto1',
    };

    const result = placeBid({
      auction,
      bidderId: 'manualUser',
      amount: 13000,
      now: new Date(),
      autoBids: [{ uid: 'auto1', maxAmount: 13000, isEnabled: true }],
    });

    expect(result.auction.highestBidderId).toBe('manualUser');
    expect(result.autoBidCeilingReachedUserId).toBe('auto1');
  });

  it('does not signal auto-bid ceiling when prior leader can still compete', () => {
    featureFlags.autoBid = true;
    const auction: any = {
      id: 'a1',
      itemId: 'i1',
      sellerId: 's1',
      startPrice: 10000,
      currentPrice: 12000,
      status: 'LIVE',
      endAt: new Date(Date.now() + 60 * 60 * 1000),
      extendedCount: 0,
      bidCount: 3,
      bidderCount: 2,
      highestBidderId: 'auto1',
    };

    const result = placeBid({
      auction,
      bidderId: 'manualUser',
      amount: 13000,
      now: new Date(),
      autoBids: [{ uid: 'auto1', maxAmount: 15000, isEnabled: true }],
    });

    expect(result.auction.highestBidderId).toBe('auto1');
    expect(result.autoBidCeilingReachedUserId).toBeUndefined();
  });
});
