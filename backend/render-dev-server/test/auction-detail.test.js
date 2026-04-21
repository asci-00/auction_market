import assert from 'node:assert/strict';
import { once } from 'node:events';
import test from 'node:test';

import { Timestamp } from 'firebase-admin/firestore';

import { createApp } from '../src/app.js';

test('auction detail API returns merged auction, item, and bid history data', async () => {
  const app = createApp({
    config: {
      appEnv: 'dev',
      appBaseUrl: 'https://auction-market-dev-api.onrender.com',
      firebaseProjectId: 'auction-market-dev',
      tossApiBaseUrl: 'https://api.tosspayments.com',
      enableTossSandbox: false,
    },
    auth: {},
    db: createFakeDb(),
  });

  const server = app.listen(0);
  await once(server, 'listening');

  try {
    const address = server.address();
    assert.ok(address && typeof address === 'object');

    const response = await fetch(
      `http://127.0.0.1:${address.port}/api/auctions/auction-live/detail`,
    );
    assert.equal(response.status, 200);
    assert.equal(response.headers.get('cache-control'), 'no-store');

    const body = await response.json();
    assert.deepEqual(body, {
      detail: {
        id: 'auction-live',
        itemId: 'item-live',
        titleSnapshot: 'Signed Album',
        heroImageUrl: 'https://example.com/hero.jpg',
        imageUrls: ['https://example.com/detail.jpg'],
        description: 'Factory-sealed with hologram proof.',
        categorySub: 'IDOL_MD',
        condition: 'LIKE_NEW',
        sellerId: 'seller1',
        status: 'LIVE',
        currentPrice: 13200,
        buyNowPrice: 18000,
        orderId: null,
        endAt: '2026-04-01T18:00:00.000Z',
      },
      bidHistory: [
        {
          amount: 13200,
          createdAt: '2026-04-01T17:00:00.000Z',
        },
      ],
    });
  } finally {
    await new Promise((resolve, reject) => {
      server.close((error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      });
    });
  }
});

function createFakeDb() {
  const auctionRef = {
    async get() {
      return new FakeDocSnapshot('auction-live', {
        itemId: 'item-live',
        titleSnapshot: 'Signed Album',
        heroImageUrl: 'https://example.com/hero.jpg',
        categorySub: 'IDOL_MD',
        sellerId: 'seller1',
        status: 'LIVE',
        currentPrice: 13200,
        buyNowPrice: 18000,
        orderId: null,
        endAt: Timestamp.fromDate(new Date('2026-04-01T18:00:00.000Z')),
      });
    },
    collection(name) {
      assert.equal(name, 'bids');
      return {
        orderBy(field) {
          assert.equal(field, 'createdAt');
          return {
            limitToLast(limit) {
              assert.equal(limit, 6);
              return {
                async get() {
                  return {
                    docs: [
                      new FakeDocSnapshot('bid-1', {
                        amount: 13200,
                        createdAt: Timestamp.fromDate(
                          new Date('2026-04-01T17:00:00.000Z'),
                        ),
                      }),
                    ],
                  };
                },
              };
            },
          };
        },
      };
    },
  };

  return {
    collection(name) {
      if (name === 'auctions') {
        return {
          doc(id) {
            assert.equal(id, 'auction-live');
            return auctionRef;
          },
        };
      }
      if (name === 'items') {
        return {
          doc(id) {
            assert.equal(id, 'item-live');
            return {
              async get() {
                return new FakeDocSnapshot('item-live', {
                  imageUrls: ['https://example.com/detail.jpg'],
                  description: 'Factory-sealed with hologram proof.',
                  categorySub: 'IDOL_MD',
                  condition: 'LIKE_NEW',
                });
              },
            };
          },
        };
      }
      throw new Error(`Unexpected collection: ${name}`);
    },
  };
}

class FakeDocSnapshot {
  constructor(id, data) {
    this.id = id;
    this.exists = data != null;
    this._data = data;
  }

  data() {
    return this._data;
  }
}
