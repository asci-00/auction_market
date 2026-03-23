import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_auction_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/home_auction_summary.dart';

class HomeAuctionRail extends StatelessWidget {
  const HomeAuctionRail({
    super.key,
    required this.stream,
    required this.onTapAuction,
    this.defaultBadge = AppStatusKind.endingSoon,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final ValueChanged<String> onTapAuction;
  final AppStatusKind defaultBadge;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.wifi_tethering_error_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.homeEmptyDescription,
          );
        }

        if (!snapshot.hasData) {
          return const _HomeAuctionRailPlaceholder();
        }

        final auctions =
            snapshot.data!.docs.map(HomeAuctionSummary.fromDocument).toList();
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
                child: AppAuctionCard(
                  title: auction.title.isNotEmpty
                      ? auction.title
                      : context.l10n.genericUnavailable,
                  priceLabel: formatKrw(context, auction.currentPrice),
                  metaLabel: auction.endAt != null
                      ? context.l10n.genericEndsAt(
                          formatCompactDateTime(context, auction.endAt!),
                        )
                      : context.l10n.genericUnavailable,
                  bidCountLabel:
                      context.l10n.genericCountBids(auction.bidCount),
                  imageUrl: auction.heroImageUrl,
                  badgeKind: auction.buyNowPrice != null
                      ? AppStatusKind.buyNow
                      : defaultBadge,
                  onTap: () => onTapAuction(auction.id),
                ),
              );
            },
          ),
        );
      },
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
        itemBuilder: (_, __) => Container(
          width: 236,
          decoration: BoxDecoration(
            color: AppColors.bgMuted,
            borderRadius: BorderRadius.circular(context.tokens.cardRadius),
            border: Border.all(color: AppColors.borderSoft),
          ),
        ),
      ),
    );
  }
}
