import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/activity_hub_summary.dart';
import 'activity_stat_card.dart';

class ActivityBuyerCard extends StatelessWidget {
  const ActivityBuyerCard({
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
        icon: Icons.receipt_long_outlined,
        title: context.l10n.activityBuyerCardTitle,
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
        description: context.l10n.activityBuyerCardDescription,
      );
    }

    if (isLoading || summary == null) {
      return const AppShimmerCardPlaceholder(height: 148);
    }

    final totalAttentionCount =
        summary!.pendingPaymentCount + summary!.awaitingReceiptCount;

    return ActivityStatCard(
      icon: Icons.receipt_long_rounded,
      title: context.l10n.activityBuyerCardTitle,
      subtitle: summary!.pendingPaymentCount > 0
          ? context.l10n.activityBuyerPendingPaymentSubtitle(
              summary!.pendingPaymentCount,
            )
          : summary!.awaitingReceiptCount > 0
          ? context.l10n.activityBuyerAwaitingReceiptSubtitle(
              summary!.awaitingReceiptCount,
            )
          : context.l10n.activityBuyerCardDescription,
      primaryMetric: '$totalAttentionCount',
      metricLabel: context.l10n.activityBuyerMetricLabel,
      badgeKind: totalAttentionCount > 0
          ? AppStatusKind.pending
          : AppStatusKind.verified,
      onTap: () => context.push('/orders'),
    );
  }
}
