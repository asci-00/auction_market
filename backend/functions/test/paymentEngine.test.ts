import { describe, expect, it } from 'vitest';
import {
  buildPaymentSessionContract,
  buildWebhookEventMarker,
  extractWebhookSecret,
  isDevDummyPaymentEnabled,
  isDuplicatePaymentConfirmation,
  normalizeWebhookPayment,
  toCancelledPaymentOrder,
  toConfirmedPaymentOrder,
  withLastWebhookEventId,
} from '../src/domain/paymentEngine.js';
import { buildOrderFees } from '../src/domain/orderEngine.js';

const baseOrder = {
  id: 'order-1',
  auctionId: 'auction-1',
  itemId: 'item-1',
  buyerId: 'buyer-1',
  sellerId: 'seller-1',
  finalPrice: 18000,
  paymentStatus: 'UNPAID' as const,
  orderStatus: 'AWAITING_PAYMENT' as const,
  paymentDueAt: new Date('2026-03-17T00:00:00.000Z'),
  payment: {
    provider: 'TOSS_PAYMENTS' as const,
    paymentKey: null,
    method: null,
    approvedAt: null,
    lastWebhookEventId: null,
  },
  shipping: {
    carrierCode: null,
    carrierName: null,
    trackingNumber: null,
    trackingUrl: null,
    shippedAt: null,
  },
  settlement: {
    expectedAt: null,
    settledAt: null,
    payoutBatchId: null,
  },
  fees: buildOrderFees(18000),
};

describe('payment engine', () => {
  it('allows dev dummy payment only in emulator-backed dev runtime', () => {
    expect(
      isDevDummyPaymentEnabled('dev', {
        FUNCTIONS_EMULATOR: 'true',
      } as NodeJS.ProcessEnv),
    ).toBe(true);
    expect(
      isDevDummyPaymentEnabled('dev', {
        FIRESTORE_EMULATOR_HOST: '127.0.0.1:8080',
      } as NodeJS.ProcessEnv),
    ).toBe(true);
    expect(isDevDummyPaymentEnabled('dev', {} as NodeJS.ProcessEnv)).toBe(
      false,
    );
    expect(
      isDevDummyPaymentEnabled('dev', {
        FIRESTORE_EMULATOR_HOST: '',
      } as NodeJS.ProcessEnv),
    ).toBe(false);
    expect(
      isDevDummyPaymentEnabled('dev', {
        FIRESTORE_EMULATOR_HOST: '   ',
      } as NodeJS.ProcessEnv),
    ).toBe(false);
    expect(
      isDevDummyPaymentEnabled('staging', {
        FUNCTIONS_EMULATOR: 'true',
      } as NodeJS.ProcessEnv),
    ).toBe(false);
  });

  it('builds dev dummy payment session without app base url', () => {
    const contract = buildPaymentSessionContract({
      appEnv: 'dev',
      appBaseUrl: null,
      orderId: 'order-1',
      allowDevDummyPayment: true,
      buildDevPaymentKey: (orderId) => `dev_pay_${orderId}`,
    });

    expect(contract).toEqual({
      mode: 'DEV_DUMMY',
      successUrl: null,
      failUrl: null,
      devPaymentKey: 'dev_pay_order-1',
    });
  });

  it('builds toss payment session urls and trims trailing slash', () => {
    const contract = buildPaymentSessionContract({
      appEnv: 'staging',
      appBaseUrl: 'https://app.example.com/',
      orderId: 'order-1',
      allowDevDummyPayment: false,
      buildDevPaymentKey: (orderId) => `dev_pay_${orderId}`,
    });

    expect(contract).toEqual({
      mode: 'TOSS',
      successUrl: 'https://app.example.com/payments/success?orderId=order-1',
      failUrl: 'https://app.example.com/payments/fail?orderId=order-1',
      devPaymentKey: null,
    });
  });

  it('keeps app base path and drops query noise when building payment urls', () => {
    const contract = buildPaymentSessionContract({
      appEnv: 'prod',
      appBaseUrl: 'https://app.example.com/mobile/?foo=bar',
      orderId: 'order-1',
      allowDevDummyPayment: false,
      buildDevPaymentKey: (orderId) => `dev_pay_${orderId}`,
    });

    expect(contract.successUrl).toBe(
      'https://app.example.com/mobile/payments/success?orderId=order-1',
    );
    expect(contract.failUrl).toBe(
      'https://app.example.com/mobile/payments/fail?orderId=order-1',
    );
  });

  it('requires app base url when toss handoff must be prepared', () => {
    expect(() =>
      buildPaymentSessionContract({
        appEnv: 'staging',
        appBaseUrl: null,
        orderId: 'order-1',
        allowDevDummyPayment: false,
        buildDevPaymentKey: (orderId) => `dev_pay_${orderId}`,
      }),
    ).toThrowError('APP_BASE_URL is required outside dev builds.');

    expect(() =>
      buildPaymentSessionContract({
        appEnv: 'dev',
        appBaseUrl: null,
        orderId: 'order-1',
        allowDevDummyPayment: false,
        buildDevPaymentKey: (orderId) => `dev_pay_${orderId}`,
      }),
    ).toThrowError(
      'APP_BASE_URL is required when dev dummy payment is unavailable.',
    );
  });

  it('rejects invalid app base urls', () => {
    expect(() =>
      buildPaymentSessionContract({
        appEnv: 'staging',
        appBaseUrl: 'notaurl',
        orderId: 'order-1',
        allowDevDummyPayment: false,
        buildDevPaymentKey: (orderId) => `dev_pay_${orderId}`,
      }),
    ).toThrowError('APP_BASE_URL must be a valid http or https URL.');

    expect(() =>
      buildPaymentSessionContract({
        appEnv: 'staging',
        appBaseUrl: 'app://payments',
        orderId: 'order-1',
        allowDevDummyPayment: false,
        buildDevPaymentKey: (orderId) => `dev_pay_${orderId}`,
      }),
    ).toThrowError('APP_BASE_URL must use http or https.');
  });

  it('marks confirmed payments as paid escrow hold', () => {
    const updated = toConfirmedPaymentOrder(
      baseOrder,
      {
        paymentKey: 'pay_1',
        method: 'CARD',
        approvedAt: new Date('2026-03-17T01:00:00.000Z'),
        totalAmount: 18000,
        status: 'DONE',
      },
      'event-1',
    );

    expect(updated.paymentStatus).toBe('PAID');
    expect(updated.orderStatus).toBe('PAID_ESCROW_HOLD');
    expect(updated.payment.paymentKey).toBe('pay_1');
    expect(updated.payment.lastWebhookEventId).toBe('event-1');
  });

  it('detects duplicate payment confirmation and normalizes webhook payload', () => {
    const paidOrder = toConfirmedPaymentOrder(
      baseOrder,
      {
        paymentKey: 'pay_1',
        method: 'CARD',
        approvedAt: new Date('2026-03-17T01:00:00.000Z'),
        totalAmount: 18000,
        status: 'DONE',
      },
      null,
    );

    expect(isDuplicatePaymentConfirmation(paidOrder, 'pay_1', 18000)).toBe(
      true,
    );

    const webhook = normalizeWebhookPayment({
      data: {
        orderId: 'order-1',
        paymentKey: 'pay_1',
        method: 'CARD',
        totalAmount: 18000,
        status: 'DONE',
        secret: 'whsec_test',
        approvedAt: '2026-03-17T01:00:00.000Z',
      },
    });

    expect(webhook?.orderId).toBe('order-1');
    expect(webhook?.status).toBe('DONE');
    expect(extractWebhookSecret({ data: { secret: 'whsec_test' } })).toBe(
      'whsec_test',
    );
    expect(
      buildWebhookEventMarker(
        'PAYMENT_STATUS_CHANGED',
        '2026-03-17T01:00:00Z',
        'pay_1',
        'DONE',
      ),
    ).toContain('PAYMENT_STATUS_CHANGED');
  });

  it('marks cancelled webhook payments as cancelled orders', () => {
    const cancelled = toCancelledPaymentOrder(baseOrder, 'event-cancelled');
    expect(cancelled.paymentStatus).toBe('CANCELLED');
    expect(cancelled.orderStatus).toBe('CANCELLED');
    expect(cancelled.payment.lastWebhookEventId).toBe('event-cancelled');
  });

  it('updates webhook marker without replaying payment state transitions', () => {
    const paidOrder = toConfirmedPaymentOrder(
      baseOrder,
      {
        paymentKey: 'pay_1',
        method: 'CARD',
        approvedAt: new Date('2026-03-17T01:00:00.000Z'),
        totalAmount: 18000,
        status: 'DONE',
      },
      'event-1',
    );

    const updated = withLastWebhookEventId(paidOrder, 'event-2');

    expect(updated.paymentStatus).toBe('PAID');
    expect(updated.orderStatus).toBe('PAID_ESCROW_HOLD');
    expect(updated.payment.paymentKey).toBe('pay_1');
    expect(updated.payment.lastWebhookEventId).toBe('event-2');
  });
});
