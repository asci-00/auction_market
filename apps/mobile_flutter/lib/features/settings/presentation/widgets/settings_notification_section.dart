import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../data/settings_preferences.dart';
import 'settings_section_heading.dart';
import 'settings_switch_tile.dart';

class SettingsNotificationSection extends StatelessWidget {
  const SettingsNotificationSection({
    super.key,
    required this.preferences,
    required this.onPushEnabledChanged,
    required this.onCategoryChanged,
    required this.masterTitle,
    required this.masterDescription,
    required this.categoryTitle,
    required this.categoryDescription,
    required this.categoryLabels,
    required this.categoryDescriptions,
  });

  final SettingsPreferences preferences;
  final ValueChanged<bool> onPushEnabledChanged;
  final void Function(SettingsNotificationCategory category, bool enabled)
  onCategoryChanged;
  final String masterTitle;
  final String masterDescription;
  final String categoryTitle;
  final String categoryDescription;
  final Map<SettingsNotificationCategory, String> categoryLabels;
  final Map<SettingsNotificationCategory, String> categoryDescriptions;

  @override
  Widget build(BuildContext context) {
    final hasAllCategoryEntries = SettingsNotificationCategory.values.every(
      (category) =>
          categoryLabels.containsKey(category) &&
          categoryDescriptions.containsKey(category),
    );
    assert(
      hasAllCategoryEntries,
      'categoryLabels and categoryDescriptions must cover all notification categories.',
    );

    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSectionHeading(
            title: masterTitle,
            description: masterDescription,
          ),
          SizedBox(height: tokens.space3),
          SettingsSwitchTile(
            title: masterTitle,
            subtitle: masterDescription,
            value: preferences.pushEnabled,
            onChanged: onPushEnabledChanged,
          ),
          SizedBox(height: tokens.space5),
          SettingsSectionHeading(
            title: categoryTitle,
            description: categoryDescription,
          ),
          SizedBox(height: tokens.space2),
          for (final category in SettingsNotificationCategory.values)
            SettingsSwitchTile(
              title: categoryLabels[category]!,
              subtitle: categoryDescriptions[category]!,
              value: preferences.isCategoryEnabled(category),
              enabled: preferences.pushEnabled,
              onChanged: (value) => onCategoryChanged(category, value),
            ),
        ],
      ),
    );
  }
}
