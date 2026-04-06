import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final onSurface = enabled
        ? context.colorScheme.onSurface
        : context.colorScheme.onSurface.withValues(alpha: 0.5);
    final onSurfaceVariant = enabled
        ? context.colorScheme.onSurfaceVariant
        : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return SwitchListTile.adaptive(
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(color: onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
      ),
    );
  }
}
