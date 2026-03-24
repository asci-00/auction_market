import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/activity_hub_summary.dart';
import 'activity_stat_card.dart';

class ActivityNotificationsCard extends ConsumerWidget {
  const ActivityNotificationsCard({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return AppEmptyState(
        icon: Icons.notifications_outlined,
        title: context.l10n.activityNotificationsCardTitle,
        description: context.l10n.activitySignedOutDescription,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ref
          .read(firestoreProvider)
          .collection('notifications')
          .doc(userId)
          .collection('inbox')
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.activityNotificationsCardDescription,
          );
        }

        if (!snapshot.hasData) {
          return const AppShimmerCardPlaceholder(height: 148);
        }

        final summary =
            ActivityHubSummary.fromNotifications(snapshot.data!.docs);

        return ActivityStatCard(
          icon: Icons.notifications_active_outlined,
          title: context.l10n.activityNotificationsCardTitle,
          subtitle: summary.unreadNotificationCount > 0
              ? context.l10n.activityNotificationsUnreadSubtitle(
                  summary.unreadNotificationCount,
                )
              : context.l10n.activityNotificationsCardDescription,
          primaryMetric: '${summary.unreadNotificationCount}',
          metricLabel: context.l10n.activityNotificationsMetricLabel,
          badgeKind: summary.unreadNotificationCount > 0
              ? AppStatusKind.unread
              : AppStatusKind.verified,
          onTap: () => context.push('/notifications'),
        );
      },
    );
  }
}
