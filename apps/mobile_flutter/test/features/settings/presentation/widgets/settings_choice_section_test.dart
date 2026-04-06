import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/settings/data/settings_preferences.dart';
import 'package:auction_market_mobile/features/settings/presentation/widgets/settings_choice_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping a choice row reports the selected value', (
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
          body: SettingsChoiceSection<SettingsThemeModePreference>(
            sectionTitle: 'Appearance',
            sectionDescription: 'Description',
            groupValue: SettingsThemeModePreference.system,
            options: const [
              SettingsChoiceOption(
                value: SettingsThemeModePreference.system,
                title: 'Follow device',
                description: 'System description',
              ),
              SettingsChoiceOption(
                value: SettingsThemeModePreference.dark,
                title: 'Always dark',
                description: 'Dark description',
              ),
            ],
            onChanged: (value) => changedValue = value,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Always dark'));
    await tester.pumpAndSettle();

    expect(changedValue, SettingsThemeModePreference.dark);
  });
}
