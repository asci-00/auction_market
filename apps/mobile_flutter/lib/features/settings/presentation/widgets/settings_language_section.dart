import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_panel.dart';
import 'settings_section_heading.dart';

class SettingsLanguageSection extends StatelessWidget {
  const SettingsLanguageSection({
    super.key,
    required this.sectionTitle,
    required this.sectionDescription,
    required this.currentLanguageLabel,
    required this.supportedLanguageLabel,
    required this.supportedLanguageValue,
    required this.koreanLanguageLabel,
    required this.englishLanguageLabel,
    this.deviceLocale,
    this.supportedLocales = supportedAppLocales,
  });

  final String sectionTitle;
  final String sectionDescription;
  final String currentLanguageLabel;
  final String supportedLanguageLabel;
  final String supportedLanguageValue;
  final String koreanLanguageLabel;
  final String englishLanguageLabel;
  final Locale? deviceLocale;
  final Iterable<Locale> supportedLocales;

  @override
  Widget build(BuildContext context) {
    final effectiveLocale = resolveAppLocale(
      deviceLocale ?? Localizations.localeOf(context),
      supportedLocales,
    );

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSectionHeading(
            title: sectionTitle,
            description: sectionDescription,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              currentLanguageLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              effectiveLocale.languageCode == 'en'
                  ? englishLanguageLabel
                  : koreanLanguageLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              supportedLanguageLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              supportedLanguageValue,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
