import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HomeActionIconButton extends StatelessWidget {
  const HomeActionIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Material(
      color: AppColors.bgSurfaceFor(brightness),
      borderRadius: BorderRadius.circular(18),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textPrimaryFor(brightness)),
      ),
    );
  }
}
