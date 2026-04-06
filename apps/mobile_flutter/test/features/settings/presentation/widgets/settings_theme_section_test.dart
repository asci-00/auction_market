import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/settings/data/settings_preferences.dart';
import 'package:auction_market_mobile/features/settings/presentation/widgets/settings_theme_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping a preview tile reports the selected theme mode', (
    tester,
  ) async {
    SettingsThemeModePreference? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: Scaffold(
          body: SettingsThemeSection(
            sectionTitle: 'Appearance',
            groupValue: SettingsThemeModePreference.system,
            systemTitle: 'System',
            lightTitle: 'Light',
            darkTitle: 'Dark',
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('settings-theme-dark')));
    await tester.pumpAndSettle();

    expect(changedValue, SettingsThemeModePreference.dark);
  });
}
