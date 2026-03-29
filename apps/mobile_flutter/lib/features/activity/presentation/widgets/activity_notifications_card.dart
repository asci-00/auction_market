import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/activity_hub_summary.dart';
import 'activity_stat_card.dart';

class ActivityNotificationsCard extends StatelessWidget {
  const ActivityNotificationsCard({
    super.key,
    required this.userId,
    required this.summary,
    required this.isLoading,
    required this.hasError,
    this.onRetry,
  });

  final String? userId;
  final ActivityHubSummary? summary;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return AppEmptyState(
        icon: Icons.notifications_outlined,
        title: context.l10n.activityNotificationsCardTitle,
        description: context.l10n.activitySignedOutDescription,
        action: TextButton(
          onPressed: () =>
              context.go('/login?from=${Uri.encodeComponent('/activity')}'),
          child: Text(context.l10n.genericSignInAction),
        ),
      );
    }

    if (hasError) {
      return AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: context.l10n.genericUnavailable,
        description: context.l10n.activityNotificationsCardDescription,
        action: TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      );
    }

    if (isLoading || summary == null) {
      return const AppShimmerCardPlaceholder(height: 148);
    }

    return ActivityStatCard(
      icon: Icons.notifications_active_outlined,
      title: context.l10n.activityNotificationsCardTitle,
      subtitle: summary!.unreadNotificationCount > 0
          ? context.l10n.activityNotificationsUnreadSubtitle(
              summary!.unreadNotificationCount,
            )
          : context.l10n.activityNotificationsCardDescription,
      primaryMetric: '${summary!.unreadNotificationCount}',
      metricLabel: context.l10n.activityNotificationsMetricLabel,
      badgeKind: summary!.unreadNotificationCount > 0
          ? AppStatusKind.unread
          : AppStatusKind.verified,
      onTap: () => context.push('/notifications'),
    );
  }
}
