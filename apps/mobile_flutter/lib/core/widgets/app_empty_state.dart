import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_panel.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.eyebrow,
    this.action,
    this.tone = AppPanelTone.surface,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? eyebrow;
  final Widget? action;
  final AppPanelTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    final accentColor = switch (tone) {
      AppPanelTone.dark => AppColors.accentPrimarySoft,
      AppPanelTone.elevated => AppColors.accentPrimary,
      AppPanelTone.soft => AppColors.accentUrgent,
      AppPanelTone.surface => AppColors.accentPrimary,
    };

    return AppPanel(
      tone: tone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.18),
                  accentColor.withValues(alpha: 0.34),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: tone == AppPanelTone.dark
                  ? AppColors.textInverse
                  : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.space4),
          if (eyebrow != null)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space2),
              child: Text(
                eyebrow!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: tone == AppPanelTone.dark
                      ? AppColors.accentPrimarySoft
                      : AppColors.accentPrimary,
                ),
              ),
            ),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: tone == AppPanelTone.dark
                  ? AppColors.textInverse
                  : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: tokens.space2),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: tone == AppPanelTone.dark
                  ? AppColors.textInverse.withValues(alpha: 0.82)
                  : AppColors.textSecondary,
            ),
          ),
          if (action != null)
            Padding(
              padding: EdgeInsets.only(top: tokens.space4),
              child: action!,
            ),
        ],
      ),
    );
  }
}
