import 'package:auction_market_mobile/app/app.dart';
import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/firebase/firebase_bootstrap.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/routing/app_router.dart';
import 'package:auction_market_mobile/features/notifications/application/notification_device_token_service.dart';
import 'package:auction_market_mobile/features/settings/application/settings_preferences_service.dart';
import 'package:auction_market_mobile/features/settings/data/settings_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app applies theme override while locale follows the device', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              Text(MaterialLocalizations.of(context).backButtonTooltip),
        ),
      ],
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: supportedAppLocales,
        fallbackLocale: fallbackAppLocale,
        startLocale: const Locale('ko'),
        saveLocale: false,
        path: translationAssetPath,
        child: ProviderScope(
          overrides: [
            appBootstrapProvider.overrideWith(
              (ref) async => const AppBootstrapState(
                config: AppConfig(
                  environment: AppEnvironment.dev,
                  backendTransport: AppBackendTransport.firebaseCallable,
                  apiBaseUrl: null,
                  useFirebaseEmulators: true,
                  tossClientKey: null,
                  firebaseEmulatorHostOverride: null,
                ),
              ),
            ),
            sharedPreferencesProvider.overrideWithValue(
              await SharedPreferences.getInstance(),
            ),
            appSettingsPreferencesProvider.overrideWith(
              (ref) => Stream.value(
                const SettingsPreferences(
                  pushEnabled: true,
                  categories: {
                    SettingsNotificationCategory.auctionActivity: true,
                    SettingsNotificationCategory.orderPayment: true,
                    SettingsNotificationCategory.shippingAndReceipt: true,
                    SettingsNotificationCategory.system: true,
                  },
                ),
              ),
            ),
            themeModePreferenceProvider.overrideWith(
              (ref) => SettingsThemeModePreference.dark,
            ),
            notificationDeviceTokenLifecycleProvider.overrideWith((ref) {}),
            goRouterProvider.overrideWith((ref) => router),
          ],
          child: const AuctionMarketApp(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp).first,
    );

    expect(materialApp.themeMode, ThemeMode.dark);
    expect(materialApp.locale, const Locale('en'));
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets(
    'app uses local theme preference before settings stream resolves',
    (tester) async {
      tester.binding.platformDispatcher.localeTestValue = const Locale('ko');
      addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                Text(MaterialLocalizations.of(context).backButtonTooltip),
          ),
        ],
      );

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: supportedAppLocales,
          fallbackLocale: fallbackAppLocale,
          startLocale: const Locale('ko'),
          saveLocale: false,
          path: translationAssetPath,
          child: ProviderScope(
            overrides: [
              appBootstrapProvider.overrideWith(
                (ref) async => const AppBootstrapState(
                  config: AppConfig(
                    environment: AppEnvironment.dev,
                    backendTransport: AppBackendTransport.firebaseCallable,
                    apiBaseUrl: null,
                    useFirebaseEmulators: true,
                    tossClientKey: null,
                    firebaseEmulatorHostOverride: null,
                  ),
                ),
              ),
              sharedPreferencesProvider.overrideWithValue(
                await SharedPreferences.getInstance(),
              ),
              themeModePreferenceProvider.overrideWith(
                (ref) => SettingsThemeModePreference.light,
              ),
              notificationDeviceTokenLifecycleProvider.overrideWith((ref) {}),
              appSettingsPreferencesProvider.overrideWith(
                (ref) => const Stream.empty(),
              ),
              goRouterProvider.overrideWith((ref) => router),
            ],
            child: const AuctionMarketApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      expect(materialApp.themeMode, ThemeMode.light);
    },
  );
}
