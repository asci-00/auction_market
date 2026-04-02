import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/auction_bid_history_entry.dart';

class AuctionBidHistoryCard extends StatelessWidget {
  const AuctionBidHistoryCard({
    super.key,
    required this.bidHistory,
    required this.isLoading,
  });

  final List<AuctionBidHistoryEntry> bidHistory;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (isLoading) {
      return AppPanel(
        tone: AppPanelTone.surface,
        child: AppShimmer(
          child: Column(
            children: [
              AppShimmerBlock(height: 180, radius: tokens.cardRadius),
              SizedBox(height: tokens.space4),
              ...List<Widget>.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == 2 ? 0 : tokens.space3,
                  ),
                  child: const AppShimmerBlock(height: 18, radius: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (bidHistory.isEmpty) {
      return AppEmptyState(
        icon: Icons.gavel_rounded,
        title: context.l10n.auctionDetailBidHistory,
        description: context.l10n.auctionDetailNoBidHistory,
      );
    }

    final spots = <FlSpot>[];
    for (var index = 0; index < bidHistory.length; index++) {
      spots.add(FlSpot(index.toDouble(), bidHistory[index].amount.toDouble()));
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
                      color: AppColors.accentPrimary.withValues(alpha: 0.12),
                    ),
                    spots: spots,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.space4),
          ...bidHistory.reversed.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.space3),
              child: Row(
                children: [
                  const AppStatusBadge(kind: AppStatusKind.pending),
                  SizedBox(width: tokens.space3),
                  Expanded(
                    child: Text(
                      formatKrw(context, entry.amount),
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  if (entry.createdAt != null)
                    Text(
                      formatCompactDateTime(context, entry.createdAt!),
                      style: context.textTheme.bodySmall,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
