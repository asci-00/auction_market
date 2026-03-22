import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class MyAccountPanel extends StatelessWidget {
  const MyAccountPanel({
    super.key,
    required this.user,
  });

  final User? user;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.mySignedInAs,
            style: context.textTheme.bodySmall,
          ),
          SizedBox(height: tokens.space2),
          Text(
            user?.displayName ?? user?.email ?? context.l10n.genericUnknownUser,
            style: context.textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
