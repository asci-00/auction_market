import 'package:auction_market_mobile/features/orders/data/order_payment_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dev dummy session exposes direct confirmation semantics', () {
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

    expect(session.isDevDummyMode, isTrue);
    expect(session.hasDevPaymentKey, isTrue);
    expect(session.requiresManualConfirmation, isFalse);
  });

  test('toss session becomes launcher-ready only with handoff urls', () {
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

    expect(session.isRealTossMode, isTrue);
    expect(session.isRealTossReady, isTrue);
    expect(session.requiresManualConfirmation, isTrue);
  });
}
