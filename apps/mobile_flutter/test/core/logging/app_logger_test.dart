import 'package:auction_market_mobile/core/logging/app_logger.dart';
import 'package:logger/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('printer includes timestamp, level, domain, and source', () {
    final printer = AppLogPrinter(redactSensitiveData: false);

    final lines = printer.log(
      LogEvent(
        Level.info,
        const AppLogEntry(
          domain: AppLogDomain.payment,
          message: 'payment started',
          source: 'orders/payment_service.dart:41',
        ),
      ),
    );

    expect(lines.single, contains('INFO'));
    expect(lines.single, contains('payment'));
    expect(lines.single, contains('orders/payment_service.dart:41'));
    expect(lines.single, contains('payment started'));
  });

  test('printer redacts sensitive query values', () {
    final printer = AppLogPrinter(redactSensitiveData: true);

    final lines = printer.log(
      LogEvent(
        Level.error,
        const AppLogEntry(
          domain: AppLogDomain.payment,
          message:
              'redirect failed paymentKey=secret123 clientKey=secret456 token=secret789',
          source: 'payment/bridge',
        ),
      ),
    );

    expect(lines.single, isNot(contains('secret123')));
    expect(lines.single, isNot(contains('secret456')));
    expect(lines.single, isNot(contains('secret789')));
    expect(lines.single, contains('<redacted>'));
  });
}
