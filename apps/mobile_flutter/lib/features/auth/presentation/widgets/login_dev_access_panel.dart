import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class LoginDevAccessPanel extends StatelessWidget {
  const LoginDevAccessPanel({
    super.key,
    required this.isSubmitting,
    required this.onBuyerPressed,
    required this.onSellerPressed,
  });

  final bool isSubmitting;
  final VoidCallback onBuyerPressed;
  final VoidCallback onSellerPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.loginDevAccessTitle,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: tokens.space2),
          Text(
            context.l10n.loginDevAccessDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: tokens.space3),
          FilledButton(
            onPressed: isSubmitting ? null : onBuyerPressed,
            child: Text(context.l10n.loginDevBuyer),
          ),
          SizedBox(height: tokens.space2),
          OutlinedButton(
            onPressed: isSubmitting ? null : onSellerPressed,
            child: Text(context.l10n.loginDevSeller),
          ),
        ],
      ),
    );
  }
}
