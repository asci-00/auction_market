import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_status_badge.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return AppPageScaffold(
      title: l10n.activityTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppEditorialHero(
            eyebrow: l10n.activityHeroEyebrow,
            title: l10n.activityHeroTitle,
            description: l10n.activityHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.pending),
              AppStatusBadge(kind: AppStatusKind.unread),
            ],
          ),
          SizedBox(height: tokens.space6),
          _ActivityCard(
            icon: Icons.receipt_long_rounded,
            title: l10n.activityOrdersTitle,
            subtitle: l10n.activityOrdersSubtitle,
            onTap: () => context.push('/orders'),
          ),
          SizedBox(height: tokens.space3),
          _ActivityCard(
            icon: Icons.notifications_active_outlined,
            title: l10n.activityNotificationsTitle,
            subtitle: l10n.activityNotificationsSubtitle,
            onTap: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.tokens.cardRadius),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
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
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: tokens.space1),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
