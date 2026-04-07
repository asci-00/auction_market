import assert from 'node:assert/strict';
import test from 'node:test';

import { createApp } from '../src/app.js';

test('healthz returns runtime metadata', async () => {
  const app = createApp({
    config: {
      appEnv: 'dev',
      appBaseUrl: 'https://auction-market-dev-api.onrender.com',
      firebaseProjectId: 'auction-market-dev',
      tossApiBaseUrl: 'https://api.tosspayments.com',
      enableTossSandbox: false,
    },
    auth: {},
    db: {},
  });

  const server = app.listen(0);

  try {
    const address = server.address();
    assert.ok(address && typeof address === 'object');

    const response = await fetch(
      `http://127.0.0.1:${address.port}/healthz`,
    );
    assert.equal(response.status, 200);

    const body = await response.json();
    assert.deepEqual(body, {
      ok: true,
      appEnv: 'dev',
      appBaseUrl: 'https://auction-market-dev-api.onrender.com',
      firebaseProjectId: 'auction-market-dev',
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
