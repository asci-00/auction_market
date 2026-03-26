import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_panel.dart';

class AppEditorialHero extends StatelessWidget {
  const AppEditorialHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.badges = const <Widget>[],
    this.trailing,
    this.tone = AppPanelTone.dark,
  });

  final String eyebrow;
  final String title;
  final String description;
  final List<Widget> badges;
  final Widget? trailing;
  final AppPanelTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final isDark = tone == AppPanelTone.dark;

    return AppPanel(
      tone: tone,
      padding: EdgeInsets.all(tokens.space6),
      blurSigma: 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: -125,
            right: -125,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPrimarySoft.withValues(alpha: 0.34),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isDark
                            ? AppColors.accentPrimarySoft
                            : AppColors.accentPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.space3),
                    Text(
                      title,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: isDark
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.space3),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.textInverse.withValues(alpha: 0.82)
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (badges.isNotEmpty) ...[
                      SizedBox(height: tokens.space5),
                      Wrap(
                        spacing: tokens.space2,
                        runSpacing: tokens.space2,
                        children: badges,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: tokens.space4),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
