import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/backend/backend_gateway.dart';
import 'package:auction_market_mobile/core/firebase/firebase_bootstrap.dart';
import 'package:auction_market_mobile/core/firebase/firebase_providers.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/settings/application/settings_preferences_service.dart';
import 'package:auction_market_mobile/features/settings/data/settings_preferences.dart';
import 'package:auction_market_mobile/features/my/presentation/my_screen.dart';
import 'package:auction_market_mobile/features/settings/presentation/settings_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets(
    'signed-out settings screen redirects through login with return path',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                Text('login:${state.uri.queryParameters['from']}'),
          ),
        ],
      );

      await tester.pumpWidget(
        _TestApp(
          router: router,
          overrides: [
            firebaseAuthProvider.overrideWith((ref) => MockFirebaseAuth()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('login:/settings'), findsOneWidget);
    },
  );

  testWidgets('my screen keeps a persistent settings fallback action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        home: const MyScreen(),
        overrides: [
          firebaseAuthProvider.overrideWith((ref) => MockFirebaseAuth()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('my-settings-fallback-action')),
      find.byType(Scrollable),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('my-settings-fallback-action')),
      findsOneWidget,
    );
  });

  testWidgets(
    'signed-in settings screen shows system-language confirmation section',
    (tester) async {
      final user = MockUser(
        uid: 'settings-user',
        email: 'settings-user@example.com',
      );
      final auth = MockFirebaseAuth(mockUser: user, signedIn: true);

      await tester.pumpWidget(
        _TestApp(
          locale: const Locale('en'),
          home: const SettingsScreen(),
          overrides: [
            firebaseAuthProvider.overrideWith((ref) => auth),
            appBootstrapProvider.overrideWith(
              (ref) async => AppBootstrapState(config: _devConfig()),
            ),
            appConfigProvider.overrideWith((ref) => _devConfig()),
            settingsPreferencesProvider.overrideWith(
              (ref) => Stream.value(const SettingsPreferences.defaults()),
            ),
            themeModePreferenceProvider.overrideWith(
              (ref) => SettingsThemeModePreference.system,
            ),
            notificationPermissionStatusProvider.overrideWith(
              (ref) async => AuthorizationStatus.authorized,
            ),
            appPackageInfoProvider.overrideWith(
              (ref) async => PackageInfo(
                appName: 'Auction Market',
                packageName: 'com.example.auction',
                version: '1.0.0',
                buildNumber: '1',
                buildSignature: '',
                installerStore: null,
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.text('Language'),
        find.byType(Scrollable),
        const Offset(0, -220),
      );
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Current app language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    },
  );

  testWidgets('debug push probe reports successful dispatch', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        locale: const Locale('en'),
        home: const SettingsScreen(),
        overrides: _signedInSettingsOverrides(
          backendGateway: _FakeBackendGateway(
            debugPushProbeHandler: () async => {
              'pushAttempted': true,
              'tokenCount': 1,
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapDebugPushProbeAction(tester);

    expect(
      find.text(
        'Push probe requested. Check your notifications in a few seconds.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('debug push probe reports skipped dispatch details', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        locale: const Locale('en'),
        home: const SettingsScreen(),
        overrides: _signedInSettingsOverrides(
          backendGateway: _FakeBackendGateway(
            debugPushProbeHandler: () async => {
              'pushAttempted': false,
              'tokenCount': 0,
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapDebugPushProbeAction(tester);

    expect(
      find.text(
        'Push probe was created but push dispatch was skipped (eligible tokens: 0). Check notification preference and token status.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('debug push probe surfaces backend failure reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        locale: const Locale('en'),
        home: const SettingsScreen(),
        overrides: _signedInSettingsOverrides(
          backendGateway: _FakeBackendGateway(
            debugPushProbeHandler: () async {
              throw FirebaseFunctionsException(
                code: 'failed-precondition',
                message: 'No eligible token',
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapDebugPushProbeAction(tester);

    expect(find.text('Push probe failed: No eligible token'), findsOneWidget);
  });
}

AppConfig _devConfig() {
  return AppConfig.fromValues(
    environment: AppEnvironment.dev,
    backendTransportRawValue: 'http',
    apiBaseUrl: 'https://auction-market-dev-api.example',
    useFirebaseEmulatorsRawValue: 'false',
    tossClientKey: 'test_ck',
  );
}

List<Override> _signedInSettingsOverrides({
  required BackendGateway backendGateway,
}) {
  final user = MockUser(
    uid: 'settings-user',
    email: 'settings-user@example.com',
  );
  final auth = MockFirebaseAuth(mockUser: user, signedIn: true);
  final config = _devConfig();

  return [
    firebaseAuthProvider.overrideWith((ref) => auth),
    appConfigProvider.overrideWith((ref) => config),
    appBootstrapProvider.overrideWith(
      (ref) async => AppBootstrapState(config: config),
    ),
    settingsPreferencesProvider.overrideWith(
      (ref) => Stream.value(const SettingsPreferences.defaults()),
    ),
    themeModePreferenceProvider.overrideWith(
      (ref) => SettingsThemeModePreference.system,
    ),
    notificationPermissionStatusProvider.overrideWith(
      (ref) async => AuthorizationStatus.authorized,
    ),
    appPackageInfoProvider.overrideWith(
      (ref) async => PackageInfo(
        appName: 'Auction Market',
        packageName: 'com.example.auction',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
        installerStore: null,
      ),
    ),
    backendGatewayProvider.overrideWith((ref) => backendGateway),
  ];
}

Future<void> _tapDebugPushProbeAction(WidgetTester tester) async {
  final actionFinder = find.byKey(
    const ValueKey('settings-debug-push-probe-action'),
  );
  await tester.dragUntilVisible(
    actionFinder,
    find.byType(Scrollable),
    const Offset(0, -320),
  );
  await tester.pumpAndSettle();
  await tester.tap(actionFinder);
  await tester.pumpAndSettle();
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.overrides,
    this.router,
    this.home,
    this.locale,
  });

  final GoRouter? router;
  final Widget? home;
  final List<Override> overrides;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: router != null
          ? MaterialApp.router(
              theme: AppTheme.light(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: supportedAppLocales,
              locale: locale ?? const Locale('en'),
              localeResolutionCallback: resolveAppLocale,
              routerConfig: router!,
            )
          : MaterialApp(
              theme: AppTheme.light(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: supportedAppLocales,
              locale: locale ?? const Locale('en'),
              localeResolutionCallback: resolveAppLocale,
              home: home,
            ),
    );
  }
}

class _FakeBackendGateway extends Fake implements BackendGateway {
  _FakeBackendGateway({required this.debugPushProbeHandler});

  final Future<Map<String, dynamic>> Function() debugPushProbeHandler;

  @override
  Future<Map<String, dynamic>> sendDebugPushProbe() {
    return debugPushProbeHandler();
  }
}
