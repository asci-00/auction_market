import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/settings/data/settings_preferences.dart';
import 'package:auction_market_mobile/features/settings/presentation/widgets/settings_notification_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('disables category toggles when push notifications are off', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SettingsNotificationSection(
          preferences: SettingsPreferences(
            pushEnabled: false,
            categories: {
              SettingsNotificationCategory.auctionActivity: true,
              SettingsNotificationCategory.orderPayment: true,
              SettingsNotificationCategory.shippingAndReceipt: true,
              SettingsNotificationCategory.system: true,
            },
          ),
          onPushEnabledChanged: _noopBool,
          onCategoryChanged: _noopCategory,
          masterTitle: 'Push notifications',
          masterDescription: 'Turn updates on or off.',
          permissionTitle: 'Device permission',
          permissionDescription: 'Device permission copy',
          permissionStatusLabel: 'Notifications are allowed on this device.',
          openPermissionSettingsLabel: 'Open system settings',
          categoryTitle: 'Alert categories',
          categoryDescription: 'Category help text',
          categoryLabels: {
            SettingsNotificationCategory.auctionActivity: 'Auction activity',
            SettingsNotificationCategory.orderPayment: 'Orders and payment',
            SettingsNotificationCategory.shippingAndReceipt:
                'Shipping and receipt',
            SettingsNotificationCategory.system: 'System notices',
          },
          categoryDescriptions: {
            SettingsNotificationCategory.auctionActivity:
                'Auction activity copy',
            SettingsNotificationCategory.orderPayment: 'Order payment copy',
            SettingsNotificationCategory.shippingAndReceipt: 'Shipping copy',
            SettingsNotificationCategory.system: 'System copy',
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final tiles = tester.widgetList<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(tiles.length, 5);
    expect(tiles.first.onChanged, isNotNull);
    for (final tile in tiles.skip(1)) {
      expect(tile.onChanged, isNull);
    }
  });

  testWidgets('shows current device permission state', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SettingsNotificationSection(
          preferences: SettingsPreferences.defaults(),
          onPushEnabledChanged: _noopBool,
          onCategoryChanged: _noopCategory,
          masterTitle: 'Push notifications',
          masterDescription: 'Turn updates on or off.',
          permissionTitle: 'Device permission',
          permissionDescription: 'Device permission copy',
          permissionStatusLabel: 'Notifications are allowed on this device.',
          openPermissionSettingsLabel: 'Open system settings',
          categoryTitle: 'Alert categories',
          categoryDescription: 'Category help text',
          categoryLabels: {
            SettingsNotificationCategory.auctionActivity: 'Auction activity',
            SettingsNotificationCategory.orderPayment: 'Orders and payment',
            SettingsNotificationCategory.shippingAndReceipt:
                'Shipping and receipt',
            SettingsNotificationCategory.system: 'System notices',
          },
          categoryDescriptions: {
            SettingsNotificationCategory.auctionActivity:
                'Auction activity copy',
            SettingsNotificationCategory.orderPayment: 'Order payment copy',
            SettingsNotificationCategory.shippingAndReceipt: 'Shipping copy',
            SettingsNotificationCategory.system: 'System copy',
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Device permission'), findsOneWidget);
    expect(find.text('Device permission copy'), findsOneWidget);
    expect(
      find.text('Notifications are allowed on this device.'),
      findsOneWidget,
    );
    expect(find.text('Open system settings'), findsNothing);
  });

  testWidgets('opens system settings from denied permission state', (
    tester,
  ) async {
    var openSettingsCount = 0;

    await tester.pumpWidget(
      _TestApp(
        child: SettingsNotificationSection(
          preferences: const SettingsPreferences.defaults(),
          onPushEnabledChanged: _noopBool,
          onCategoryChanged: _noopCategory,
          masterTitle: 'Push notifications',
          masterDescription: 'Turn updates on or off.',
          permissionTitle: 'Device permission',
          permissionDescription: 'Device permission copy',
          permissionStatusLabel:
              'Notifications are blocked in system settings.',
          openPermissionSettingsLabel: 'Open system settings',
          onOpenPermissionSettings: () {
            openSettingsCount += 1;
          },
          categoryTitle: 'Alert categories',
          categoryDescription: 'Category help text',
          categoryLabels: const {
            SettingsNotificationCategory.auctionActivity: 'Auction activity',
            SettingsNotificationCategory.orderPayment: 'Orders and payment',
            SettingsNotificationCategory.shippingAndReceipt:
                'Shipping and receipt',
            SettingsNotificationCategory.system: 'System notices',
          },
          categoryDescriptions: const {
            SettingsNotificationCategory.auctionActivity:
                'Auction activity copy',
            SettingsNotificationCategory.orderPayment: 'Order payment copy',
            SettingsNotificationCategory.shippingAndReceipt: 'Shipping copy',
            SettingsNotificationCategory.system: 'System copy',
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Open system settings'));
    await tester.pumpAndSettle();

    expect(openSettingsCount, 1);
  });
}

void _noopBool(bool _) {}

void _noopCategory(SettingsNotificationCategory _, bool __) {}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      localeResolutionCallback: resolveAppLocale,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }
}
