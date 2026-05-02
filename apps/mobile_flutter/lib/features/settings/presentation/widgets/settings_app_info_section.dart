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
    this.debugPushProbeTitle,
    this.debugPushProbeDescription,
    this.debugPushProbeActionLabel,
    this.onDebugPushProbe,
    this.isDebugPushProbeInFlight = false,
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
  final String? debugPushProbeTitle;
  final String? debugPushProbeDescription;
  final String? debugPushProbeActionLabel;
  final VoidCallback? onDebugPushProbe;
  final bool isDebugPushProbeInFlight;

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
            if (onDebugPushProbe != null &&
                debugPushProbeTitle != null &&
                debugPushProbeDescription != null &&
                debugPushProbeActionLabel != null) ...[
              SizedBox(height: tokens.space1),
              _DebugActionRow(
                title: debugPushProbeTitle!,
                description: debugPushProbeDescription!,
                actionLabel: debugPushProbeActionLabel!,
                isBusy: isDebugPushProbeInFlight,
                onPressed: onDebugPushProbe!,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DebugActionRow extends StatelessWidget {
  const _DebugActionRow({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.isBusy,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String actionLabel;
  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: tokens.space3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleSmall),
                SizedBox(height: tokens.space1),
                Text(description, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 120,
          child: FilledButton.tonal(
            key: const ValueKey('settings-debug-push-probe-action'),
            onPressed: isBusy ? null : onPressed,
            child: isBusy
                ? const SizedBox.square(
                    key: ValueKey('settings-debug-push-probe-progress'),
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(actionLabel),
          ),
        ),
      ],
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
