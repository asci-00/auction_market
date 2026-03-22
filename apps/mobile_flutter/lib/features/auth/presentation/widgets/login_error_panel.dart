import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class LoginErrorPanel extends StatelessWidget {
  const LoginErrorPanel({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      tone: AppPanelTone.soft,
      borderColor: AppColors.accentUrgent.withValues(alpha: 0.3),
      child: Text(
        message,
        style: context.textTheme.bodyMedium?.copyWith(
          color: AppColors.accentUrgent,
        ),
      ),
    );
  }
}
