import assert from 'node:assert/strict';
import { once } from 'node:events';
import test from 'node:test';

import { createApp } from '../src/app.js';

function createMockServices(options = {}) {
  const notificationWrites = [];
  const multicastCalls = [];
  let notificationCounter = 0;

  const tokenDocs = options.deviceTokens ?? [
    {
      token: 'token-a',
      isActive: true,
      permissionStatus: 'AUTHORIZED',
    },
  ];

  const userPreferences = {
    pushEnabled: options.pushEnabled ?? true,
    notificationCategories: {
      auctionActivity: true,
      orderPayment: true,
      shippingAndReceipt: true,
      system: options.systemCategoryEnabled ?? true,
    },
  };

  const services = {
    config: {
      appEnv: options.appEnv ?? 'dev',
      appBaseUrl: 'https://auction-market-dev-api.onrender.com',
      firebaseProjectId: 'auction-market-dev',
      tossApiBaseUrl: 'https://api.tosspayments.com',
      enableTossSandbox: false,
    },
    auth: {
      async verifyIdToken(token) {
        if (token !== 'valid-token') {
          throw new Error('invalid token');
        }
        return { uid: 'buyer1' };
      },
    },
    db: {
      collection(name) {
        if (name === 'notifications') {
          return {
            doc(uid) {
              return {
                collection(subName) {
                  assert.equal(subName, 'inbox');
                  return {
                    doc(docId) {
                      const resolvedId = docId ?? `notif-${++notificationCounter}`;
                      return {
                        id: resolvedId,
                        async set(payload) {
                          notificationWrites.push({
                            uid,
                            id: resolvedId,
                            payload,
                          });
                        },
                      };
                    },
                  };
                },
              };
            },
          };
        }

        if (name === 'users') {
          return {
            doc(uid) {
              return {
                async get() {
                  return {
                    exists: true,
                    id: uid,
                    data() {
                      return {
                        preferences: userPreferences,
                      };
                    },
                  };
                },
                collection(subName) {
                  assert.equal(subName, 'deviceTokens');
                  return {
                    async get() {
                      return {
                        docs: tokenDocs.map((entry) => ({
                          data() {
                            return entry;
                          },
                        })),
                      };
                    },
                  };
                },
              };
            },
          };
        }

        throw new Error(`Unexpected collection: ${name}`);
      },
    },
    messaging: {
      async sendEachForMulticast(payload) {
        multicastCalls.push(payload);
        return {
          successCount: payload.tokens.length,
          failureCount: 0,
          responses: payload.tokens.map(() => ({ success: true })),
        };
      },
    },
  };

  return {
    services,
    notificationWrites,
    multicastCalls,
  };
}

async function withServer(app, callback) {
  const server = app.listen(0);
  await once(server, 'listening');
  try {
    const address = server.address();
    assert.ok(address && typeof address === 'object');
    await callback(address.port);
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
}

test('debug push probe requires authorization', async () => {
  const { services } = createMockServices();
  const app = createApp(services);

  await withServer(app, async (port) => {
    const response = await fetch(
      `http://127.0.0.1:${port}/api/notifications/debug/push-probe`,
      {
        method: 'POST',
      },
    );
    assert.equal(response.status, 401);
  });
});

test('debug push probe creates inbox and dispatches push when eligible', async () => {
  const { services, notificationWrites, multicastCalls } = createMockServices();
  const app = createApp(services);

  await withServer(app, async (port) => {
    const response = await fetch(
      `http://127.0.0.1:${port}/api/notifications/debug/push-probe`,
      {
        method: 'POST',
        headers: {
          Authorization: 'Bearer valid-token',
        },
      },
    );
    assert.equal(response.status, 200);

    const body = await response.json();
    assert.equal(body.ok, true);
    assert.equal(body.type, 'SYSTEM_TEST');
    assert.equal(body.category, 'system');
    assert.equal(body.entityType, 'ORDER');
    assert.equal(body.entityId, 'debug-push-probe');
    assert.equal(body.deeplink, 'app://notifications');
    assert.equal(body.pushAttempted, true);
    assert.equal(body.tokenCount, 1);
  });

  assert.equal(notificationWrites.length, 1);
  assert.equal(notificationWrites[0].payload.type, 'SYSTEM_TEST');
  assert.equal(notificationWrites[0].payload.category, 'system');
  assert.equal(notificationWrites[0].payload.entityType, 'ORDER');
  assert.equal(notificationWrites[0].payload.entityId, 'debug-push-probe');

  assert.equal(multicastCalls.length, 1);
  assert.deepEqual(multicastCalls[0].tokens, ['token-a']);
  assert.equal(multicastCalls[0].data.type, 'SYSTEM_TEST');
  assert.equal(multicastCalls[0].data.category, 'system');
  assert.equal(multicastCalls[0].data.deeplink, 'app://notifications');
  assert.equal(multicastCalls[0].data.entityType, 'ORDER');
  assert.equal(multicastCalls[0].data.entityId, 'debug-push-probe');
  assert.equal(typeof multicastCalls[0].data.notificationId, 'string');
  assert.equal(typeof multicastCalls[0].data.timestamp, 'string');
});

test('debug push probe skips dispatch when system category is disabled', async () => {
  const { services, multicastCalls } = createMockServices({
    systemCategoryEnabled: false,
  });
  const app = createApp(services);

  await withServer(app, async (port) => {
    const response = await fetch(
      `http://127.0.0.1:${port}/api/notifications/debug/push-probe`,
      {
        method: 'POST',
        headers: {
          Authorization: 'Bearer valid-token',
        },
      },
    );
    assert.equal(response.status, 200);
    const body = await response.json();
    assert.equal(body.pushAttempted, false);
    assert.equal(body.tokenCount, 1);
  });

  assert.equal(multicastCalls.length, 0);
});

test('debug push probe is blocked outside dev environment', async () => {
  const { services } = createMockServices({ appEnv: 'prod' });
  const app = createApp(services);

  await withServer(app, async (port) => {
    const response = await fetch(
      `http://127.0.0.1:${port}/api/notifications/debug/push-probe`,
      {
        method: 'POST',
        headers: {
          Authorization: 'Bearer valid-token',
        },
      },
    );
    assert.equal(response.status, 412);
    const body = await response.json();
    assert.equal(body.code, 'failed-precondition');
  });
});
