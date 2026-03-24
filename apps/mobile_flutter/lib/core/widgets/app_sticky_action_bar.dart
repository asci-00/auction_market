import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_panel.dart';

class AppStickyActionBar extends StatelessWidget {
  const AppStickyActionBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        tokens.screenPadding,
        tokens.space3,
        tokens.screenPadding,
        tokens.space4,
      ),
      child: AppPanel(
        tone: AppPanelTone.dark,
        blurSigma: 18,
        padding: EdgeInsets.all(tokens.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textInverse,
              ),
            ),
            SizedBox(height: tokens.space1),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textInverse.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: tokens.space3),
            child,
          ],
        ),
      ),
    );
  }
}
