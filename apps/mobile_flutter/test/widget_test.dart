import 'dart:convert';
import 'dart:io';

import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/auth/presentation/login_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('login screen renders Korean copy when locale is Korean', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('ko'),
        child: LoginScreen(
          configOverride: AppConfig(
            environment: AppEnvironment.dev,
            useFirebaseEmulators: false,
            tossClientKey: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Google로 계속하기'), findsOneWidget);
    expect(find.text('진지한 입찰을 위한 차분한 마켓에 입장하세요.'), findsOneWidget);
  });

  testWidgets('login screen renders English copy when locale is English', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('en'),
        child: LoginScreen(
          configOverride: AppConfig(
            environment: AppEnvironment.dev,
            useFirebaseEmulators: false,
            tossClientKey: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(
      find.text('Enter a quieter marketplace for serious bidding.'),
      findsOneWidget,
    );
  });

  test('unsupported locale falls back to Korean', () {
    expect(resolveAppLocale(const Locale('ja')), fallbackAppLocale);
    expect(resolveAppLocale(null), fallbackAppLocale);
  });

  test('startup failure strings stay localized', () {
    final english = lookupAppLocalizations(const Locale('en'));
    final korean = lookupAppLocalizations(const Locale('ko'));

    expect(english.configRequiredTitle, 'Setup required');
    expect(korean.loadingApp, '앱 환경을 준비하고 있습니다');
  });

  test('easy localization assets expose the same nested keys', () {
    final korean = _flattenKeys(_readJson('ko'));
    final english = _flattenKeys(_readJson('en'));

    expect(korean, english);
    expect(korean, contains('common.language'));
    expect(korean, contains('common.korean'));
    expect(korean, contains('common.english'));
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
    final resolvedLocale = resolveAppLocale(locale);

    return EasyLocalization(
      supportedLocales: supportedAppLocales,
      fallbackLocale: fallbackAppLocale,
      startLocale: resolvedLocale,
      saveLocale: false,
      path: translationAssetPath,
      child: Builder(
        builder: (context) => ProviderScope(
          child: MaterialApp(
            locale: context.locale,
            theme: AppTheme.light(),
            localizationsDelegates: [
              ...context.localizationDelegates,
              AppLocalizations.delegate,
            ],
            supportedLocales: context.supportedLocales,
            home: child,
          ),
        ),
      ),
    );
  }
}

Map<String, dynamic> _readJson(String languageCode) {
  final file = File('assets/translations/$languageCode.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Set<String> _flattenKeys(Map<String, dynamic> source, [String prefix = '']) {
  final keys = <String>{};

  source.forEach((key, value) {
    final next = prefix.isEmpty ? key : '$prefix.$key';

    if (value is Map<String, dynamic>) {
      keys.addAll(_flattenKeys(value, next));
      return;
    }

    keys.add(next);
  });

  return keys;
}
