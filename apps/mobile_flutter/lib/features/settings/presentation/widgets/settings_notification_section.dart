import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../data/settings_preferences.dart';
import 'settings_section_heading.dart';
import 'settings_switch_tile.dart';

class SettingsNotificationSection extends StatelessWidget {
  const SettingsNotificationSection({
    super.key,
    required this.preferences,
    required this.permissionStatus,
    required this.onPushEnabledChanged,
    required this.onCategoryChanged,
    required this.onRequestPermission,
    required this.onOpenSystemSettings,
    required this.masterTitle,
    required this.masterDescription,
    required this.permissionTitle,
    required this.permissionDescription,
    required this.permissionActionLabel,
    required this.permissionStatusLabel,
    required this.categoryTitle,
    required this.categoryDescription,
    required this.categoryLabels,
    required this.categoryDescriptions,
  });

  final SettingsPreferences preferences;
  final AuthorizationStatus permissionStatus;
  final ValueChanged<bool> onPushEnabledChanged;
  final void Function(SettingsNotificationCategory category, bool enabled)
  onCategoryChanged;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenSystemSettings;
  final String masterTitle;
  final String masterDescription;
  final String permissionTitle;
  final String permissionDescription;
  final String permissionActionLabel;
  final String permissionStatusLabel;
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
    final needsPermissionRequest =
        permissionStatus == AuthorizationStatus.notDetermined;
    final needsSystemSettings = permissionStatus == AuthorizationStatus.denied;

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
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(tokens.cardRadius),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(permissionTitle, style: context.textTheme.titleSmall),
                  SizedBox(height: tokens.space1),
                  Text(
                    permissionDescription,
                    style: context.textTheme.bodySmall,
                  ),
                  SizedBox(height: tokens.space3),
                  Row(
                    children: [
                      Icon(
                        _permissionIcon(permissionStatus),
                        size: 18,
                        color: _permissionColor(context, permissionStatus),
                      ),
                      SizedBox(width: tokens.space2),
                      Expanded(
                        child: Text(
                          permissionStatusLabel,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: _permissionColor(context, permissionStatus),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (needsPermissionRequest || needsSystemSettings) ...[
                    SizedBox(height: tokens.space3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: needsPermissionRequest
                            ? onRequestPermission
                            : onOpenSystemSettings,
                        child: Text(permissionActionLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

  IconData _permissionIcon(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return Icons.notifications_active_outlined;
      case AuthorizationStatus.provisional:
        return Icons.notifications_paused_outlined;
      case AuthorizationStatus.denied:
        return Icons.notifications_off_outlined;
      case AuthorizationStatus.notDetermined:
        return Icons.notifications_none_outlined;
    }
  }

  Color _permissionColor(BuildContext context, AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return context.colorScheme.primary;
      case AuthorizationStatus.provisional:
        return context.colorScheme.tertiary;
      case AuthorizationStatus.denied:
        return context.colorScheme.error;
      case AuthorizationStatus.notDetermined:
        return context.colorScheme.onSurfaceVariant;
    }
  }
}
