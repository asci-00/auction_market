import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/firebase/firebase_providers.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';

class AuctionBidHistoryCard extends ConsumerWidget {
  const AuctionBidHistoryCard({
    super.key,
    required this.auctionId,
  });

  final String auctionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreProvider);
    final bidsStream = firestore
        .collection('auctions')
        .doc(auctionId)
        .collection('bids')
        .orderBy('createdAt')
        .limitToLast(6)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: bidsStream,
      builder: (context, snapshot) {
        final tokens = context.tokens;

        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.bar_chart_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.auctionDetailNoBidHistory,
          );
        }

        if (!snapshot.hasData) {
          return AppPanel(
            tone: AppPanelTone.surface,
            child: AppShimmer(
              child: Column(
                children: [
                  AppShimmerBlock(
                    height: 180,
                    radius: tokens.cardRadius,
                  ),
                  SizedBox(height: tokens.space4),
                  ...List<Widget>.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: index == 2 ? 0 : tokens.space3,
                      ),
                      child: const AppShimmerBlock(
                        height: 18,
                        radius: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return AppEmptyState(
            icon: Icons.gavel_rounded,
            title: context.l10n.auctionDetailBidHistory,
            description: context.l10n.auctionDetailNoBidHistory,
          );
        }

        final spots = <FlSpot>[];
        for (var index = 0; index < docs.length; index++) {
          final amount =
              (docs[index].data()['amount'] as num?)?.toDouble() ?? 0;
          spots.add(FlSpot(index.toDouble(), amount));
        }

        return AppPanel(
          tone: AppPanelTone.surface,
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    minY: 0,
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        barWidth: 4,
                        color: AppColors.accentPrimary,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              AppColors.accentPrimary.withValues(alpha: 0.12),
                        ),
                        spots: spots,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: tokens.space4),
              ...docs.reversed.map((document) {
                final data = document.data();
                final amount = (data['amount'] as num?) ?? 0;
                final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

                return Padding(
                  padding: EdgeInsets.only(bottom: tokens.space3),
                  child: Row(
                    children: [
                      const AppStatusBadge(kind: AppStatusKind.pending),
                      SizedBox(width: tokens.space3),
                      Expanded(
                        child: Text(
                          formatKrw(context, amount),
                          style: context.textTheme.titleMedium,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          formatCompactDateTime(context, createdAt),
                          style: context.textTheme.bodySmall,
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
