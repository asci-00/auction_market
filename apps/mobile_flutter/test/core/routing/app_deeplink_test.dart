import 'package:auction_market_mobile/core/routing/app_deeplink.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payment success deep links normalize with query parameters intact', () {
    final normalized = normalizeAppDeepLink(
      Uri.parse(
        'app://payments/success?orderId=order-paid&paymentKey=pay_1&amount=230000',
      ),
    );

    expect(
      normalized,
      '/payments/success?orderId=order-paid&paymentKey=pay_1&amount=230000',
    );
  });

  test('payment fail deep links normalize back to payment fail route', () {
    final normalized = normalizeAppDeepLink(
      Uri.parse(
        'app://payments/fail?orderId=order-paid&code=PAYMENT_CANCELED&message=test',
      ),
    );

    expect(
      normalized,
      '/payments/fail?orderId=order-paid&code=PAYMENT_CANCELED&message=test',
    );
  });

  test('payment deep link without path falls back to orders', () {
    final normalized = normalizeAppDeepLink(Uri.parse('app://payments'));

    expect(normalized, '/orders');
  });
}
