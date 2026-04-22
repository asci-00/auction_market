import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class LoginNotesPanel extends StatelessWidget {
  const LoginNotesPanel({super.key, required this.showReturnNotice});

  final bool showReturnNotice;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.loginTrustNote,
            style: context.textTheme.titleMedium,
          ),
          if (showReturnNotice) ...[
            SizedBox(height: tokens.space2),
            Text(
              context.l10n.loginReturnNotice,
              style: context.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
