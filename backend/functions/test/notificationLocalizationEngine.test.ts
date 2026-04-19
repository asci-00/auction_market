import { describe, expect, it } from 'vitest';

import {
  buildInboxNotificationCopy,
  resolveNotificationLocale,
} from '../src/domain/notificationLocalizationEngine.js';
import type { InboxNotificationType } from '../src/domain/notificationDispatchEngine.js';

const supportedTypes: InboxNotificationType[] = [
  'OUTBID',
  'AUTO_BID_CEILING_REACHED',
  'WON',
  'BUY_NOW_COMPLETED',
  'ORDER_AWAITING_PAYMENT',
  'PAYMENT_COMPLETED',
  'PAYMENT_DUE',
  'PAYMENT_FAILED',
  'SHIPMENT_REMINDER',
  'SHIPPED',
  'RECEIPT_REMINDER',
  'RECEIPT_CONFIRMED',
  'SETTLED',
  'SYSTEM_TEST',
];

describe('notification localization engine', () => {
  it('builds non-empty copy for every supported type in ko and en', () => {
    for (const type of supportedTypes) {
      const ko = buildInboxNotificationCopy({ type, locale: 'ko' });
      const en = buildInboxNotificationCopy({ type, locale: 'en' });

      expect(ko.title.trim().length).toBeGreaterThan(0);
      expect(ko.body.trim().length).toBeGreaterThan(0);
      expect(en.title.trim().length).toBeGreaterThan(0);
      expect(en.body.trim().length).toBeGreaterThan(0);
    }
  });

  it('normalizes user preference locale before token locale', () => {
    const locale = resolveNotificationLocale({
      userData: {
        preferences: {
          languageCode: 'EN_us',
        },
      },
      tokenCandidates: [
        {
          tokenId: 'token-a',
          locale: 'ko-KR',
          isActive: true,
          permissionStatus: 'AUTHORIZED',
          lastSeenAtMs: 100,
        },
      ],
    });

    expect(locale).toBe('en');
  });

  it('falls back to latest deliverable token locale when user preference is missing', () => {
    const locale = resolveNotificationLocale({
      userData: {},
      tokenCandidates: [
        {
          tokenId: 'token-older',
          locale: 'ko-KR',
          isActive: true,
          permissionStatus: 'AUTHORIZED',
          lastSeenAtMs: 100,
        },
        {
          tokenId: 'token-newer',
          locale: 'en-US',
          isActive: true,
          permissionStatus: 'PROVISIONAL',
          lastSeenAtMs: 200,
        },
      ],
    });

    expect(locale).toBe('en');
  });

  it('falls back to explicit fallback locale and then ko default', () => {
    const explicitFallback = resolveNotificationLocale({
      userData: {},
      tokenCandidates: [
        {
          tokenId: 'token-a',
          locale: 'fr-FR',
          isActive: true,
          permissionStatus: 'AUTHORIZED',
          lastSeenAtMs: 300,
        },
      ],
      fallbackLocale: 'en',
    });
    const defaultFallback = resolveNotificationLocale({
      userData: {},
      tokenCandidates: [
        {
          tokenId: 'token-a',
          locale: 'fr-FR',
          isActive: true,
          permissionStatus: 'AUTHORIZED',
          lastSeenAtMs: 300,
        },
      ],
    });

    expect(explicitFallback).toBe('en');
    expect(defaultFallback).toBe('ko');
  });

  it('interpolates price values in localized outbid copy', () => {
    const ko = buildInboxNotificationCopy({
      type: 'OUTBID',
      locale: 'ko',
      context: { finalPrice: 12345 },
    });
    const en = buildInboxNotificationCopy({
      type: 'OUTBID',
      locale: 'en',
      context: { finalPrice: 12345 },
    });

    expect(ko.body).toContain('12,345');
    expect(en.body).toContain('12,345');
    expect(en.body).toContain('KRW');
  });

  it('interpolates shipping details with graceful fallback', () => {
    const withDetails = buildInboxNotificationCopy({
      type: 'SHIPPED',
      locale: 'en',
      context: {
        carrierName: 'CJ',
        trackingNumber: '1234',
      },
    });
    const withoutDetails = buildInboxNotificationCopy({
      type: 'SHIPPED',
      locale: 'ko',
      context: {},
    });

    expect(withDetails.body).toContain('CJ 1234');
    expect(withoutDetails.body).toBe('배송 정보가 등록되었습니다.');
  });

  it('interpolates settlement order id when present', () => {
    const withOrderId = buildInboxNotificationCopy({
      type: 'SETTLED',
      locale: 'en',
      context: {
        orderId: 'order-123',
      },
    });

    expect(withOrderId.body).toContain('order-123');
  });

  it('normalizes unknown input locale to ko fallback in copy builder', () => {
    const copy = buildInboxNotificationCopy({
      type: 'PAYMENT_COMPLETED',
      locale: 'ja',
    });

    expect(copy.title).toBe('결제 완료');
  });
});
