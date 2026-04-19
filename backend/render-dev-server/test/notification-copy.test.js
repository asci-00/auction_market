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
    'OUTBID',
    'AUTO_BID_CEILING_REACHED',
    'WON',
    'BUY_NOW_COMPLETED',
    'ORDER_AWAITING_PAYMENT',
    'PAYMENT_COMPLETED',
    'PAYMENT_DUE',
    'PAYMENT_FAILED',
    'SHIPPED',
    'SHIPMENT_REMINDER',
    'RECEIPT_REMINDER',
    'RECEIPT_CONFIRMED',
    'SETTLED',
    'SYSTEM_TEST',
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

test('resolveNotificationLocale falls back to english token locale when available', () => {
  const locale = resolveNotificationLocale({
    userLanguageCode: null,
    tokenLocales: ['EN_us', 'ko-KR'],
  });
  assert.equal(locale, 'en');
});
