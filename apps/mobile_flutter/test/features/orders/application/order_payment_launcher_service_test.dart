import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/features/orders/application/order_payment_launcher_service.dart';
import 'package:auction_market_mobile/features/orders/data/order_payment_session.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildCheckoutUri appends public Toss launch params', () {
    const service = OrderPaymentLauncherService(
      AppConfig(
        environment: AppEnvironment.dev,
        useFirebaseEmulators: true,
        tossClientKey: 'test_ck_example',
        firebaseEmulatorHostOverride: null,
      ),
    );

    const session = OrderPaymentSession(
      provider: 'TOSS_PAYMENTS',
      mode: 'TOSS',
      orderId: 'order-paid',
      amount: 230000,
      orderName: 'Auction order',
      customerKey: 'buyer_uid-1',
      customerName: 'Buyer One',
      customerEmail: 'buyer@example.com',
      successUrl: 'https://app.example.com/payments/success?orderId=order-paid',
      failUrl: 'https://app.example.com/payments/fail?orderId=order-paid',
      checkoutUrl:
          'https://bridge.example.com/payments/launch?orderId=order-paid',
      devPaymentKey: null,
    );

    final uri = service.buildCheckoutUri(session);

    expect(uri.toString(), contains('clientKey=test_ck_example'));
    expect(uri.toString(), contains('customerKey=buyer_uid-1'));
    expect(uri.toString(), contains('amount=230000'));
    expect(uri.toString(), contains('customerEmail=buyer%40example.com'));
    expect(
      uri.toString(),
      contains(
        'successUrl=https%3A%2F%2Fapp.example.com%2Fpayments%2Fsuccess%3ForderId%3Dorder-paid',
      ),
    );
  });
}
