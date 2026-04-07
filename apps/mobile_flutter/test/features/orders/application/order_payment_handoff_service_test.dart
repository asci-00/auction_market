import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/features/orders/application/order_payment_handoff_service.dart';
import 'package:auction_market_mobile/features/orders/data/order_payment_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const withClientKeyConfig = AppConfig(
    environment: AppEnvironment.dev,
    backendTransport: AppBackendTransport.firebaseCallable,
    apiBaseUrl: null,
    useFirebaseEmulators: true,
    tossClientKey: 'test_ck_example',
    firebaseEmulatorHostOverride: null,
  );

  const withoutClientKeyConfig = AppConfig(
    environment: AppEnvironment.dev,
    backendTransport: AppBackendTransport.firebaseCallable,
    apiBaseUrl: null,
    useFirebaseEmulators: true,
    tossClientKey: null,
    firebaseEmulatorHostOverride: null,
  );

  test('dev dummy sessions use in-app direct confirmation', () {
    const service = OrderPaymentHandoffService(withClientKeyConfig);

    const session = OrderPaymentSession(
      provider: 'TOSS_PAYMENTS',
      mode: 'DEV_DUMMY',
      orderId: 'order-paid',
      amount: 230000,
      orderName: 'Auction order',
      customerKey: null,
      customerName: null,
      customerEmail: null,
      successUrl: null,
      failUrl: null,
      checkoutUrl: null,
      devPaymentKey: 'dev_pay_order-paid',
    );

    final plan = service.buildPlan(session);

    expect(plan.isDevDummy, isTrue);
    expect(plan.requiresManualConfirmation, isFalse);
    expect(plan.paymentKey, 'dev_pay_order-paid');
  });

  test('toss-ready sessions stay distinct from manual fallback', () {
    const service = OrderPaymentHandoffService(withClientKeyConfig);

    const session = OrderPaymentSession(
      provider: 'TOSS_PAYMENTS',
      mode: 'TOSS',
      orderId: 'order-paid',
      amount: 230000,
      orderName: 'Auction order',
      customerKey: 'buyer_uid-1',
      customerName: null,
      customerEmail: null,
      successUrl: 'https://app.example.com/payments/success?orderId=order-paid',
      failUrl: 'https://app.example.com/payments/fail?orderId=order-paid',
      checkoutUrl: 'https://app.example.com/payments/launch?orderId=order-paid',
      devPaymentKey: null,
    );

    final plan = service.buildPlan(session);

    expect(plan.isLauncherReady, isTrue);
    expect(plan.requiresManualConfirmation, isTrue);
    expect(plan.usesManualFallback, isFalse);
    expect(
      plan.checkoutUrl,
      'https://app.example.com/payments/launch?orderId=order-paid',
    );
  });

  test('missing handoff fields still falls back to manual recovery mode', () {
    const service = OrderPaymentHandoffService(withClientKeyConfig);

    const session = OrderPaymentSession(
      provider: 'TOSS_PAYMENTS',
      mode: 'TOSS',
      orderId: 'order-paid',
      amount: 230000,
      orderName: 'Auction order',
      customerKey: null,
      customerName: null,
      customerEmail: null,
      successUrl: 'https://app.example.com/payments/success?orderId=order-paid',
      failUrl: 'https://app.example.com/payments/fail?orderId=order-paid',
      checkoutUrl: 'https://app.example.com/payments/launch?orderId=order-paid',
      devPaymentKey: null,
    );

    final plan = service.buildPlan(session);

    expect(plan.usesManualFallback, isTrue);
    expect(plan.isLauncherReady, isFalse);
  });

  test('dev dummy handoff selection does not depend on app config', () {
    const service = OrderPaymentHandoffService(withClientKeyConfig);

    const session = OrderPaymentSession(
      provider: 'TOSS_PAYMENTS',
      mode: 'DEV_DUMMY',
      orderId: 'order-paid',
      amount: 230000,
      orderName: 'Auction order',
      customerKey: null,
      customerName: null,
      customerEmail: null,
      successUrl: null,
      failUrl: null,
      checkoutUrl: null,
      devPaymentKey: 'dev_pay_order-paid',
    );

    final plan = service.buildPlan(session);

    expect(plan.isDevDummy, isTrue);
    expect(plan.requiresManualConfirmation, isFalse);
    expect(plan.paymentKey, 'dev_pay_order-paid');
  });

  test('missing toss client key falls back to manual recovery mode', () {
    const service = OrderPaymentHandoffService(withoutClientKeyConfig);

    const session = OrderPaymentSession(
      provider: 'TOSS_PAYMENTS',
      mode: 'TOSS',
      orderId: 'order-paid',
      amount: 230000,
      orderName: 'Auction order',
      customerKey: 'buyer_uid-1',
      customerName: null,
      customerEmail: null,
      successUrl: 'https://app.example.com/payments/success?orderId=order-paid',
      failUrl: 'https://app.example.com/payments/fail?orderId=order-paid',
      checkoutUrl: 'https://app.example.com/payments/launch?orderId=order-paid',
      devPaymentKey: null,
    );

    final plan = service.buildPlan(session);

    expect(plan.usesManualFallback, isTrue);
    expect(plan.isLauncherReady, isFalse);
  });
}
