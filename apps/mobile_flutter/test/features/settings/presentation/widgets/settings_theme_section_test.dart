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

  testWidgets('system preview follows platform brightness, not app theme', (
    tester,
  ) async {
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.light;
    addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: Scaffold(
          body: SettingsThemeSection(
            sectionTitle: 'Appearance',
            groupValue: SettingsThemeModePreference.dark,
            systemTitle: 'System',
            lightTitle: 'Light',
            darkTitle: 'Dark',
            onChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final systemPreview = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('settings-theme-preview-system')),
    );
    final darkPreview = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('settings-theme-preview-dark')),
    );

    final systemColor = (systemPreview.decoration as BoxDecoration).color;
    final darkColor = (darkPreview.decoration as BoxDecoration).color;

    expect(systemColor, AppColors.bgSurface);
    expect(darkColor, AppColors.bgSurfaceDark);
  });
}
