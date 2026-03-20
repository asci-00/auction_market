import 'dart:io';

import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/error/app_error.dart';
import 'package:auction_market_mobile/core/error/error_views.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login screen renders Korean copy when locale is Korean', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('ko'),
        child: LoginScreen(),
      ),
    );

    expect(find.text('Google로 계속하기'), findsOneWidget);
    expect(find.text('진지한 입찰을 위한 차분한 마켓에 입장하세요.'), findsOneWidget);
  });

  testWidgets('login screen renders English copy when locale is English', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('en'),
        child: LoginScreen(),
      ),
    );

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(
      find.text('Enter a quieter marketplace for serious bidding.'),
      findsOneWidget,
    );
  });

  testWidgets('unsupported locale falls back to Korean', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('ja'),
        child: AppBootstrapLoadingScreen(),
      ),
    );

    expect(find.text('앱 환경을 준비하고 있습니다'), findsOneWidget);
  });

  testWidgets('dev emulator build shows seeded quick-login actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('en'),
        child: LoginScreen(
          configOverride: AppConfig(
            environment: AppEnvironment.dev,
            useFirebaseEmulators: true,
            tossClientKey: null,
          ),
        ),
      ),
    );

    expect(
      find.text('Quick access for emulator checks', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Sign in as seeded buyer', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Sign in as seeded seller', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('startup failure titles are localized', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('en'),
        child: StartupFailureView(
          error: AppError(
            kind: AppErrorKind.configuration,
            message: 'APP_ENV is missing. Provide it in dart_defines.json.',
          ),
        ),
      ),
    );

    expect(find.text('Setup required'), findsOneWidget);
    expect(find.textContaining('APP_ENV is missing'), findsOneWidget);
  });

  test('mobile UI source no longer contains banned engineering copy', () {
    final repoRoot = Directory.current.path;
    final targetFiles = [
      Directory('$repoRoot/lib/features'),
      Directory('$repoRoot/lib/core/widgets'),
    ].expand((directory) => directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart')));

    const bannedTerms = [
      'DETAIL ROUTE',
      'AUTH SESSION',
      'DEEPLINK',
      'LIVE READY',
      'WARM CURATION',
      'ANTI-SNIPING',
      'Phase 1',
      'Phase 2',
      'Phase 3',
      'Firestore 피드와 연결되면',
      '실제 callable write',
      'Firebase UID',
    ];

    for (final file in targetFiles) {
      final contents = file.readAsStringSync();
      for (final term in bannedTerms) {
        expect(
          contents.contains(term),
          isFalse,
          reason: 'Found banned term "$term" in ${file.path}',
        );
      }
    }
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({
    required this.child,
    this.locale,
  });

  final Widget child;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: child,
      ),
    );
  }
}
