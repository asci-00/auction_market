import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppSectionHeading extends StatelessWidget {
  const AppSectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null)
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.space2),
                  child: Text(
                    eyebrow!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.accentPrimary,
                    ),
                  ),
                ),
              Text(title, style: theme.textTheme.headlineSmall),
              SizedBox(height: tokens.space1),
              Text(subtitle, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null)
          Padding(
            padding: EdgeInsets.only(left: tokens.space3),
            child: trailing!,
          ),
      ],
    );
  }
}
