import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/settings/presentation/widgets/settings_language_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders language section labels and supported summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SettingsLanguageSection(
          sectionTitle: 'Language',
          sectionDescription: 'Follows system language.',
          currentLanguageLabel: 'Current app language',
          supportedLanguageLabel: 'Supported languages',
          supportedLanguageValue: 'Korean and English (fallback: Korean).',
          koreanLanguageLabel: 'Korean',
          englishLanguageLabel: 'English',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Current app language'), findsOneWidget);
    expect(find.text('Supported languages'), findsOneWidget);
    expect(find.text('Korean and English (fallback: Korean).'), findsOneWidget);
  });

  testWidgets('shows English when effective locale resolves to en', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('en'),
        child: SettingsLanguageSection(
          sectionTitle: 'Language',
          sectionDescription: 'Follows system language.',
          currentLanguageLabel: 'Current app language',
          supportedLanguageLabel: 'Supported languages',
          supportedLanguageValue: 'Korean and English (fallback: Korean).',
          koreanLanguageLabel: 'Korean',
          englishLanguageLabel: 'English',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('falls back to Korean when locale is unsupported', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        locale: Locale('en'),
        child: SettingsLanguageSection(
          sectionTitle: 'Language',
          sectionDescription: 'Follows system language.',
          currentLanguageLabel: 'Current app language',
          supportedLanguageLabel: 'Supported languages',
          supportedLanguageValue: 'Korean and English (fallback: Korean).',
          koreanLanguageLabel: 'Korean',
          englishLanguageLabel: 'English',
          deviceLocale: Locale('ja'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Korean'), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.locale});

  final Widget child;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      localeResolutionCallback: resolveAppLocale,
      locale: locale,
      home: Scaffold(body: child),
    );
  }
}
