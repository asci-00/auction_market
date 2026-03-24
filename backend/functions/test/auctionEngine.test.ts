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
});
