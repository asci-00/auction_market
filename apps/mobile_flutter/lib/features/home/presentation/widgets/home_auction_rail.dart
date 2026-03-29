import 'package:flutter/material.dart';

import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_auction_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_live_countdown_text.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/home_auction_summary.dart';

class HomeAuctionRail extends StatelessWidget {
  const HomeAuctionRail({
    super.key,
    required this.auctions,
    required this.isLoading,
    required this.onTapAuction,
    required this.heroNamespace,
    this.defaultBadge = AppStatusKind.endingSoon,
  });

  final List<HomeAuctionSummary> auctions;
  final bool isLoading;
  final void Function(String auctionId, String heroTag) onTapAuction;
  final String heroNamespace;
  final AppStatusKind defaultBadge;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _HomeAuctionRailPlaceholder();
    }

    if (auctions.isEmpty) {
      return AppEmptyState(
        icon: Icons.hourglass_bottom_rounded,
        title: context.l10n.homeEmptyTitle,
        description: context.l10n.homeEmptyDescription,
      );
    }

    return SizedBox(
      height: 352,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: auctions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final auction = auctions[index];
          return SizedBox(
            width: 236,
            child: AppStaggeredReveal(
              index: index,
              axis: Axis.horizontal,
              child: AppAuctionCard(
                title: auction.title.isNotEmpty
                    ? auction.title
                    : context.l10n.genericUnavailable,
                priceLabel: formatKrw(context, auction.currentPrice),
                meta: auction.endAt != null
                    ? AppLiveCountdownText(
                        targetTime: auction.endAt!,
                        builder: (context, label) => Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        expiredBuilder: (context) => Text(
                          context.l10n.genericUnavailable,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    : Text(
                        context.l10n.genericUnavailable,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                bidCountLabel: context.l10n.genericCountBids(auction.bidCount),
                imageUrl: auction.heroImageUrl,
                heroTag: '$heroNamespace-${auction.id}',
                badgeKind: auction.buyNowPrice != null
                    ? AppStatusKind.buyNow
                    : defaultBadge,
                onTap: () => onTapAuction(
                  auction.id,
                  '$heroNamespace-${auction.id}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeAuctionRailPlaceholder extends StatelessWidget {
  const _HomeAuctionRailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 352,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => const SizedBox(
          width: 236,
          child: AppShimmerCardPlaceholder(height: 352),
        ),
      ),
    );
  }
}
