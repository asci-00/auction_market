import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';

class SellPolicyPanel extends StatelessWidget {
  const SellPolicyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.dark,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppStatusBadge(kind: AppStatusKind.endingSoon),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.sellPolicyTitle,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                SizedBox(height: tokens.space2),
                Text(
                  context.l10n.sellPolicyDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
