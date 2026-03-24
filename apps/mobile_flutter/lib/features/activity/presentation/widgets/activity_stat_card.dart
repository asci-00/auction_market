import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';

class ActivityStatCard extends StatelessWidget {
  const ActivityStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryMetric,
    required this.metricLabel,
    required this.badgeKind,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryMetric;
  final String metricLabel;
  final AppStatusKind badgeKind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon),
            ),
            SizedBox(width: tokens.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: context.textTheme.titleMedium,
                        ),
                      ),
                      AppStatusBadge(kind: badgeKind),
                    ],
                  ),
                  SizedBox(height: tokens.space2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium,
                  ),
                  SizedBox(height: tokens.space3),
                  Text(
                    primaryMetric,
                    style: context.textTheme.headlineSmall,
                  ),
                  SizedBox(height: tokens.space1),
                  Text(
                    metricLabel,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.space3),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
