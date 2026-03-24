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

class ActivitySellerCard extends ConsumerWidget {
  const ActivitySellerCard({
    super.key,
    required this.userId,
  });

  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null) {
      return AppEmptyState(
        icon: Icons.local_shipping_outlined,
        title: context.l10n.activitySellerCardTitle,
        description: context.l10n.activitySignedOutDescription,
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ref
          .read(firestoreProvider)
          .collection('orders')
          .where('sellerId', isEqualTo: userId)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.activitySellerCardDescription,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary =
            ActivityHubSummary.fromSellerOrders(snapshot.data!.docs);

        return ActivityStatCard(
          icon: Icons.local_shipping_rounded,
          title: context.l10n.activitySellerCardTitle,
          subtitle: summary.awaitingShipmentCount > 0
              ? context.l10n.activitySellerAwaitingShipmentSubtitle(
                  summary.awaitingShipmentCount,
                )
              : context.l10n.activitySellerCardDescription,
          primaryMetric: '${summary.awaitingShipmentCount}',
          metricLabel: context.l10n.activitySellerMetricLabel,
          badgeKind: summary.awaitingShipmentCount > 0
              ? AppStatusKind.pending
              : AppStatusKind.verified,
          onTap: () => context.push('/orders'),
        );
      },
    );
  }
}
