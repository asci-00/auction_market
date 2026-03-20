import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../../core/widgets/app_sticky_action_bar.dart';

class AuctionDetailScreen extends StatelessWidget {
  const AuctionDetailScreen({super.key, required this.auctionId});

  final String auctionId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final auctionStream = FirebaseFirestore.instance
        .collection('auctions')
        .doc(auctionId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: auctionStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final hasAuction = data != null;

        return AppPageScaffold(
          title: l10n.auctionDetailTitle,
          extendBody: true,
          bottomBar: AppStickyActionBar(
            title: hasAuction
                ? formatKrw(context, (data['currentPrice'] as num?) ?? 0)
                : l10n.auctionDetailCurrentBid,
            subtitle: l10n.auctionDetailActionHint,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/home'),
                child: Text(l10n.auctionDetailBrowseAction),
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.space4,
              tokens.screenPadding,
              tokens.stickyActionHeight + tokens.space7,
            ),
            children: [
              if (snapshot.hasError)
                AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: l10n.genericUnavailable,
                  description: l10n.auctionDetailFallbackDescription,
                  tone: AppPanelTone.soft,
                )
              else if (!hasAuction)
                AppEmptyState(
                  icon: Icons.photo_library_outlined,
                  eyebrow: l10n.auctionDetailGalleryEyebrow,
                  title: l10n.auctionDetailFallbackTitle,
                  description: l10n.auctionDetailFallbackDescription,
                  tone: AppPanelTone.dark,
                )
              else
                _AuctionHeader(data: data, auctionId: auctionId),
              SizedBox(height: tokens.space5),
              if (hasAuction) _PriceSummary(data: data),
              if (hasAuction) ...[
                SizedBox(height: tokens.space5),
                AppEditorialHero(
                  eyebrow: l10n.auctionDetailSellerSummary,
                  title: (data['titleSnapshot'] as String?) ??
                      l10n.genericUnavailable,
                  description: l10n.auctionDetailSellerDescription,
                  badges: const [
                    AppStatusBadge(kind: AppStatusKind.verified),
                    AppStatusBadge(kind: AppStatusKind.live),
                  ],
                  tone: AppPanelTone.surface,
                  trailing: Container(
                    width: 92,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(tokens.heroRadius),
                    ),
                    padding: EdgeInsets.all(tokens.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          context.l10n.genericUnknownSeller,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: tokens.space1),
                        Text(
                          (data['sellerId'] as String?) ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.space5),
                AppSectionHeading(
                  title: l10n.auctionDetailBidHistory,
                  subtitle: l10n.auctionDetailBidHistorySubtitle,
                ),
                SizedBox(height: tokens.space4),
                _BidHistoryCard(auctionId: auctionId),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AuctionHeader extends StatelessWidget {
  const _AuctionHeader({
    required this.data,
    required this.auctionId,
  });

  final Map<String, dynamic> data;
  final String auctionId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final heroImageUrl = data['heroImageUrl'] as String?;
    final hasBuyNow = data['buyNowPrice'] != null;

    return AppPanel(
      tone: AppPanelTone.dark,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (heroImageUrl != null && heroImageUrl.isNotEmpty)
                Image.network(
                  heroImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _DetailFallbackImage(),
                )
              else
                const _DetailFallbackImage(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC1E1C1A)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(tokens.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStatusBadge(
                      kind:
                          hasBuyNow ? AppStatusKind.buyNow : AppStatusKind.live,
                    ),
                    const Spacer(),
                    Text(
                      (data['titleSnapshot'] as String?) ??
                          context.l10n.genericUnavailable,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.textInverse,
                              ),
                    ),
                    SizedBox(height: tokens.space2),
                    Text(
                      '#$auctionId',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                AppColors.textInverse.withValues(alpha: 0.76),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final currentPrice = (data['currentPrice'] as num?) ?? 0;
    final buyNowPrice = data['buyNowPrice'] as num?;

    return Row(
      children: [
        Expanded(
          child: AppPanel(
            tone: AppPanelTone.surface,
            child: _MetricBlock(
              label: context.l10n.auctionDetailCurrentBid,
              value: formatKrw(context, currentPrice),
            ),
          ),
        ),
        SizedBox(width: tokens.space3),
        Expanded(
          child: AppPanel(
            tone: AppPanelTone.elevated,
            child: _MetricBlock(
              label: context.l10n.auctionDetailBuyNow,
              value: buyNowPrice != null
                  ? formatKrw(context, buyNowPrice)
                  : context.l10n.genericUnavailable,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        SizedBox(height: tokens.space2),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _BidHistoryCard extends StatelessWidget {
  const _BidHistoryCard({required this.auctionId});

  final String auctionId;

  @override
  Widget build(BuildContext context) {
    final bidsStream = FirebaseFirestore.instance
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

        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return AppEmptyState(
            icon: Icons.gavel_rounded,
            title: context.l10n.auctionDetailBidHistory,
            description: context.l10n.auctionDetailNoBidHistory,
          );
        }

        final spots = <FlSpot>[];
        for (var i = 0; i < docs.length; i++) {
          final amount = (docs[i].data()['amount'] as num?)?.toDouble() ?? 0;
          spots.add(FlSpot(i.toDouble(), amount));
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
              ...docs.reversed.map((doc) {
                final data = doc.data();
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
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          formatCompactDateTime(context, createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
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

class _DetailFallbackImage extends StatelessWidget {
  const _DetailFallbackImage();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sand,
            AppColors.accentPrimarySoft,
            AppColors.panel
          ],
        ),
      ),
    );
  }
}
