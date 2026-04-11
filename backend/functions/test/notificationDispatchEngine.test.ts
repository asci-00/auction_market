import { describe, expect, it } from 'vitest';
import {
  buildPushDataPayload,
  getDeliverableTokens,
  getNotificationCategoryForType,
  normalizeNotificationPreferences,
  shouldDispatchPush,
} from '../src/domain/notificationDispatchEngine.js';

describe('notification dispatch engine', () => {
  it('maps supported inbox types to notification categories', () => {
    expect(getNotificationCategoryForType('OUTBID')).toBe('auctionActivity');
    expect(getNotificationCategoryForType('WON')).toBe('orderPayment');
    expect(getNotificationCategoryForType('ORDER_AWAITING_PAYMENT')).toBe(
      'orderPayment',
    );
    expect(getNotificationCategoryForType('PAYMENT_COMPLETED')).toBe(
      'orderPayment',
    );
    expect(getNotificationCategoryForType('PAYMENT_DUE')).toBe('orderPayment');
    expect(getNotificationCategoryForType('SHIPPED')).toBe(
      'shippingAndReceipt',
    );
    expect(getNotificationCategoryForType('RECEIPT_CONFIRMED')).toBe(
      'shippingAndReceipt',
    );
    expect(getNotificationCategoryForType('SETTLED')).toBe(
      'shippingAndReceipt',
    );
  });

  it('defaults missing preferences to enabled state', () => {
    expect(normalizeNotificationPreferences(undefined)).toEqual({
      pushEnabled: true,
      notificationCategories: {
        auctionActivity: true,
        orderPayment: true,
        shippingAndReceipt: true,
        system: true,
      },
    });
  });

  it('keeps explicit master and category preference values', () => {
    expect(
      normalizeNotificationPreferences({
        preferences: {
          pushEnabled: false,
          notificationCategories: {
            orderPayment: false,
          },
        },
      }),
    ).toEqual({
      pushEnabled: false,
      notificationCategories: {
        auctionActivity: true,
        orderPayment: false,
        shippingAndReceipt: true,
        system: true,
      },
    });
  });

  it('filters tokens by active status, permission, and uniqueness', () => {
    expect(
      getDeliverableTokens([
        {
          token: 'token-a',
          isActive: true,
          permissionStatus: 'AUTHORIZED',
        },
        {
          token: 'token-a',
          isActive: true,
          permissionStatus: 'AUTHORIZED',
        },
        {
          token: 'token-b',
          isActive: true,
          permissionStatus: 'PROVISIONAL',
        },
        {
          token: 'token-c',
          isActive: false,
          permissionStatus: 'AUTHORIZED',
        },
        {
          token: 'token-d',
          isActive: true,
          permissionStatus: 'DENIED',
        },
        {
          token: '   ',
          isActive: true,
          permissionStatus: 'AUTHORIZED',
        },
      ]),
    ).toEqual(['token-a', 'token-b']);
  });

  it('dispatches only when master switch, category switch, and token exist', () => {
    const preferences = normalizeNotificationPreferences({
      preferences: {
        pushEnabled: true,
        notificationCategories: {
          shippingAndReceipt: false,
        },
      },
    });

    expect(shouldDispatchPush(preferences, 'orderPayment', 1)).toBe(true);
    expect(shouldDispatchPush(preferences, 'shippingAndReceipt', 1)).toBe(
      false,
    );
    expect(shouldDispatchPush(preferences, 'orderPayment', 0)).toBe(false);
    expect(
      shouldDispatchPush(
        normalizeNotificationPreferences({
          preferences: { pushEnabled: false },
        }),
        'orderPayment',
        1,
      ),
    ).toBe(false);
  });

  it('builds string-only payload data for push routing', () => {
    expect(
      buildPushDataPayload({
        notificationId: 'notif-1',
        type: 'PAYMENT_COMPLETED',
        category: 'orderPayment',
        deeplink: 'app://orders/order-1',
        entityType: 'ORDER',
        entityId: 'order-1',
        timestamp: '2026-04-11T00:00:00.000Z',
      }),
    ).toEqual({
      notificationId: 'notif-1',
      type: 'PAYMENT_COMPLETED',
      category: 'orderPayment',
      deeplink: 'app://orders/order-1',
      entityType: 'ORDER',
      entityId: 'order-1',
      timestamp: '2026-04-11T00:00:00.000Z',
    });
  });
});
