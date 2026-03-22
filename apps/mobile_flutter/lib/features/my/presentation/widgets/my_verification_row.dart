import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';

class MyVerificationRow extends StatelessWidget {
  const MyVerificationRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.elevated,
      child: Row(
        children: [
          const AppStatusBadge(kind: AppStatusKind.verified),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.titleMedium,
            ),
          ),
          Text(value, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
