import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/activity_hub_summary.dart';
import 'activity_stat_card.dart';

class ActivitySellerCard extends StatelessWidget {
  const ActivitySellerCard({
    super.key,
    required this.userId,
    required this.summary,
    required this.isLoading,
    required this.hasError,
  });

  final String? userId;
  final ActivityHubSummary? summary;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return AppEmptyState(
        icon: Icons.local_shipping_outlined,
        title: context.l10n.activitySellerCardTitle,
        description: context.l10n.activitySignedOutDescription,
      );
    }

    if (hasError) {
      return AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: context.l10n.genericUnavailable,
        description: context.l10n.activitySellerCardDescription,
      );
    }

    if (isLoading || summary == null) {
      return const AppShimmerCardPlaceholder(height: 148);
    }

    return ActivityStatCard(
      icon: Icons.local_shipping_rounded,
      title: context.l10n.activitySellerCardTitle,
      subtitle: summary!.awaitingShipmentCount > 0
          ? context.l10n.activitySellerAwaitingShipmentSubtitle(
              summary!.awaitingShipmentCount,
            )
          : context.l10n.activitySellerCardDescription,
      primaryMetric: '${summary!.awaitingShipmentCount}',
      metricLabel: context.l10n.activitySellerMetricLabel,
      badgeKind: summary!.awaitingShipmentCount > 0
          ? AppStatusKind.pending
          : AppStatusKind.verified,
      onTap: () => context.push('/orders'),
    );
  }
}
