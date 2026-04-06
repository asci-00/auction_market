import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_config/app_config.dart';
import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import 'settings_section_heading.dart';

class SettingsAppInfoSection extends StatelessWidget {
  const SettingsAppInfoSection({
    super.key,
    required this.sectionTitle,
    required this.sectionDescription,
    required this.versionLabel,
    required this.versionValue,
    required this.licensesLabel,
    required this.licensesDescription,
    required this.onOpenLicenses,
    this.config,
    this.debugTitle,
    this.debugDescription,
  });

  final String sectionTitle;
  final String sectionDescription;
  final String versionLabel;
  final String versionValue;
  final String licensesLabel;
  final String licensesDescription;
  final VoidCallback onOpenLicenses;
  final AppConfig? config;
  final String? debugTitle;
  final String? debugDescription;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSectionHeading(
            title: sectionTitle,
            description: sectionDescription,
          ),
          SizedBox(height: tokens.space3),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(versionLabel, style: context.textTheme.titleSmall),
            subtitle: Text(versionValue, style: context.textTheme.bodySmall),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(licensesLabel, style: context.textTheme.titleSmall),
            subtitle: Text(
              licensesDescription,
              style: context.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onOpenLicenses,
          ),
          if (!kReleaseMode && config != null) ...[
            SizedBox(height: tokens.space4),
            SettingsSectionHeading(
              title: debugTitle ?? '',
              description: debugDescription ?? '',
            ),
            SizedBox(height: tokens.space3),
            _DebugRow(label: 'APP_ENV', value: config!.environment.name),
            _DebugRow(label: 'Platform', value: config!.platformLabel),
            _DebugRow(
              label: 'Use emulators',
              value: config!.useFirebaseEmulators ? 'true' : 'false',
            ),
          ],
        ],
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  const _DebugRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.textTheme.bodySmall)),
          Text(value, style: context.textTheme.labelLarge),
        ],
      ),
    );
  }
}
