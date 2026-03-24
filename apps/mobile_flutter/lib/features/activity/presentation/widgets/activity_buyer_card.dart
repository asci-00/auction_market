import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/activity_hub_summary.dart';
import 'activity_stat_card.dart';

class ActivityBuyerCard extends ConsumerWidget {
  const ActivityBuyerCard({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: context.l10n.activityBuyerCardTitle,
        description: context.l10n.activitySignedOutDescription,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ref
          .read(firestoreProvider)
          .collection('orders')
          .where('buyerId', isEqualTo: userId)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.activityBuyerCardDescription,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = ActivityHubSummary.fromBuyerOrders(snapshot.data!.docs);
        final totalAttentionCount =
            summary.pendingPaymentCount + summary.awaitingReceiptCount;

        return ActivityStatCard(
          icon: Icons.receipt_long_rounded,
          title: context.l10n.activityBuyerCardTitle,
          subtitle: summary.pendingPaymentCount > 0
              ? context.l10n.activityBuyerPendingPaymentSubtitle(
                  summary.pendingPaymentCount,
                )
              : summary.awaitingReceiptCount > 0
                  ? context.l10n.activityBuyerAwaitingReceiptSubtitle(
                      summary.awaitingReceiptCount,
                    )
                  : context.l10n.activityBuyerCardDescription,
          primaryMetric: '$totalAttentionCount',
          metricLabel: context.l10n.activityBuyerMetricLabel,
          badgeKind: totalAttentionCount > 0
              ? AppStatusKind.pending
              : AppStatusKind.verified,
          onTap: () => context.push('/orders'),
        );
      },
    );
  }
}
