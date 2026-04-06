import 'package:auction_market_mobile/core/firebase/firebase_providers.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/my/presentation/my_screen.dart';
import 'package:auction_market_mobile/features/settings/presentation/settings_screen.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

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
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.overrides, this.router, this.home});

  final GoRouter? router;
  final Widget? home;
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: router != null
          ? MaterialApp.router(
              theme: AppTheme.light(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: supportedAppLocales,
              locale: const Locale('en'),
              localeResolutionCallback: resolveAppLocale,
              routerConfig: router!,
            )
          : MaterialApp(
              theme: AppTheme.light(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: supportedAppLocales,
              locale: const Locale('en'),
              localeResolutionCallback: resolveAppLocale,
              home: home,
            ),
    );
  }
}
