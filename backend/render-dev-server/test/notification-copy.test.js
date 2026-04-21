import assert from 'node:assert/strict';
import test from 'node:test';

import {
  buildNotificationCopy,
  normalizeNotificationLocale,
  resolveNotificationLocale,
} from '../src/notificationCopy.js';

test('normalizeNotificationLocale supports underscore locale separators', () => {
  assert.equal(normalizeNotificationLocale('EN_us'), 'en');
  assert.equal(normalizeNotificationLocale('ko_KR'), 'ko');
});

test('notification copy templates cover all render notification types', () => {
  const notificationTypes = [
    'SYSTEM_TEST',
    'AUTO_BID_CEILING_REACHED',
    'OUTBID',
    'WON',
    'BUY_NOW_COMPLETED',
    'ORDER_AWAITING_PAYMENT',
    'PAYMENT_DUE',
    'PAYMENT_FAILED',
    'PAYMENT_COMPLETED',
    'SHIPPED',
    'SHIPMENT_REMINDER',
    'RECEIPT_REMINDER',
    'RECEIPT_CONFIRMED',
    'SETTLED',
  ];

  for (const type of notificationTypes) {
    const koCopy = buildNotificationCopy(type, 'ko', {
      finalPrice: 12000,
      orderId: 'order-1',
      carrierName: 'CJ',
      trackingNumber: '12345',
    });
    const enCopy = buildNotificationCopy(type, 'en', {
      finalPrice: 12000,
      orderId: 'order-1',
      carrierName: 'CJ',
      trackingNumber: '12345',
    });

    assert.ok(koCopy, `missing ko template for ${type}`);
    assert.ok(enCopy, `missing en template for ${type}`);
    assert.equal(typeof koCopy.title, 'string');
    assert.equal(typeof koCopy.body, 'string');
    assert.equal(typeof enCopy.title, 'string');
    assert.equal(typeof enCopy.body, 'string');
  }
});

test('resolveNotificationLocale falls back to token locale when user locale is unsupported', () => {
  const locale = resolveNotificationLocale({
    userLanguageCode: 'ja',
    tokenLocales: ['EN_us', 'ko-KR'],
  });
  assert.equal(locale, 'en');
});
