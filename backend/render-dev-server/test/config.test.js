import test from 'node:test';
import assert from 'node:assert/strict';

import { readConfig } from '../src/config.js';

test('readConfig normalizes urls and parses service account json', () => {
  const config = readConfig({
    PORT: '8080',
    APP_ENV: 'dev',
    APP_BASE_URL: 'https://auction-market-dev.onrender.com/',
    TOSS_API_BASE_URL: 'https://api.tosspayments.com/',
    FIREBASE_PROJECT_ID: 'auction-market-dev',
    FIREBASE_SERVICE_ACCOUNT_JSON: JSON.stringify({
      project_id: 'auction-market-dev',
      client_email: 'firebase-adminsdk@example.com',
      private_key: 'test',
    }),
    ENABLE_TOSS_SANDBOX: 'true',
  });

  assert.equal(config.port, 8080);
  assert.equal(config.appEnv, 'dev');
  assert.equal(config.appBaseUrl, 'https://auction-market-dev.onrender.com');
  assert.equal(config.tossApiBaseUrl, 'https://api.tosspayments.com');
  assert.equal(config.firebaseProjectId, 'auction-market-dev');
  assert.equal(
    config.firebaseServiceAccountJson?.project_id,
    'auction-market-dev',
  );
  assert.equal(config.enableTossSandbox, true);
});

test('readConfig allows empty optional fields', () => {
  const config = readConfig({
    APP_ENV: 'prod',
    TOSS_API_BASE_URL: 'https://api.tosspayments.com',
  });

  assert.equal(config.appBaseUrl, null);
  assert.equal(config.firebaseProjectId, null);
  assert.equal(config.firebaseServiceAccountJson, null);
  assert.equal(config.tossSecretKey, null);
  assert.equal(config.tossWebhookSecret, null);
});

test('readConfig rejects invalid app env', () => {
  assert.throws(
    () =>
      readConfig({
        APP_ENV: 'qa',
        TOSS_API_BASE_URL: 'https://api.tosspayments.com',
      }),
    /APP_ENV must be dev or prod/,
  );
});
