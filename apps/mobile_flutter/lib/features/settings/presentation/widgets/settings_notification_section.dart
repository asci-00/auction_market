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
    required this.permissionTitle,
    required this.permissionDescription,
    required this.permissionStatusLabel,
    required this.openPermissionSettingsLabel,
    required this.categoryTitle,
    required this.categoryDescription,
    required this.categoryLabels,
    required this.categoryDescriptions,
    this.onOpenPermissionSettings,
  });

  final SettingsPreferences preferences;
  final ValueChanged<bool> onPushEnabledChanged;
  final void Function(SettingsNotificationCategory category, bool enabled)
  onCategoryChanged;
  final String masterTitle;
  final String masterDescription;
  final String permissionTitle;
  final String permissionDescription;
  final String permissionStatusLabel;
  final String openPermissionSettingsLabel;
  final String categoryTitle;
  final String categoryDescription;
  final Map<SettingsNotificationCategory, String> categoryLabels;
  final Map<SettingsNotificationCategory, String> categoryDescriptions;
  final VoidCallback? onOpenPermissionSettings;

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
          SizedBox(height: tokens.space4),
          _PermissionStatusRow(
            title: permissionTitle,
            description: permissionDescription,
            statusLabel: permissionStatusLabel,
            actionLabel: openPermissionSettingsLabel,
            onOpenSettings: onOpenPermissionSettings,
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

class _PermissionStatusRow extends StatelessWidget {
  const _PermissionStatusRow({
    required this.title,
    required this.description,
    required this.statusLabel,
    required this.actionLabel,
    required this.onOpenSettings,
  });

  final String title;
  final String description;
  final String statusLabel;
  final String actionLabel;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_active_outlined, color: colorScheme.primary),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: tokens.space1),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: tokens.space2),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onOpenSettings != null) ...[
                  SizedBox(height: tokens.space2),
                  TextButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
