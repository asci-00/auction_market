import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/features/notifications/presentation/notification_destination.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps deeplinks to the expected destination labels in English', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      describeNotificationDestination(l10n, 'app://auction/auction-1'),
      'Opens auction detail',
    );
    expect(
      describeNotificationDestination(l10n, 'app://orders/order-1'),
      'Opens order timeline',
    );
    expect(
      describeNotificationDestination(l10n, 'app://notifications'),
      'Stays in inbox',
    );
    expect(
      describeNotificationDestination(
        l10n,
        'app://payments/fail?orderId=order-1',
      ),
      'Opens payment recovery',
    );
    expect(
      describeNotificationDestination(l10n, 'not-a-valid-link'),
      'Opens the next relevant screen',
    );
  });
}
