import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'shows dev quick-login panel in non-release when dev emulator config is enabled',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const _TestApp(
          child: LoginScreen(
            configOverride: _devEmulatorConfig,
            releaseModeOverride: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in as seeded buyer'), findsOneWidget);
      expect(find.text('Sign in as seeded seller'), findsOneWidget);
    },
  );

  testWidgets(
    'hides dev quick-login panel in release mode even when dev emulator config is enabled',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const _TestApp(
          child: LoginScreen(
            configOverride: _devEmulatorConfig,
            releaseModeOverride: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in as seeded buyer'), findsNothing);
      expect(find.text('Sign in as seeded seller'), findsNothing);
    },
  );
}

const _devEmulatorConfig = AppConfig(
  environment: AppEnvironment.dev,
  backendTransport: AppBackendTransport.firebaseCallable,
  apiBaseUrl: null,
  useFirebaseEmulators: true,
  tossClientKey: null,
  firebaseEmulatorHostOverride: null,
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        locale: const Locale('en'),
        localeResolutionCallback: resolveAppLocale,
        home: child,
      ),
    );
  }
}
