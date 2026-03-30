import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../data/home_auction_summary.dart';
import 'home_auction_rail.dart';

class HomeCuratedCategoryRows extends StatelessWidget {
  const HomeCuratedCategoryRows({
    super.key,
    required this.goods,
    required this.precious,
    required this.isLoading,
    required this.onTapAuction,
  });

  final List<HomeAuctionSummary> goods;
  final List<HomeAuctionSummary> precious;
  final bool isLoading;
  final void Function(String auctionId, String heroTag) onTapAuction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(
          eyebrow: context.l10n.searchFilterCategoryGoods,
          title: context.l10n.homeCuratedGoodsTitle,
          subtitle: context.l10n.homeCuratedGoodsSubtitle,
          trailing: TextButton(
            onPressed: () => context.go('/search?category=goods'),
            child: Text(context.l10n.homeSectionViewAll),
          ),
        ),
        SizedBox(height: tokens.space4),
        HomeAuctionRail(
          auctions: goods,
          isLoading: isLoading,
          heroNamespace: 'home-goods',
          onTapAuction: onTapAuction,
        ),
        SizedBox(height: tokens.space7),
        AppSectionHeading(
          eyebrow: context.l10n.searchFilterCategoryPrecious,
          title: context.l10n.homeCuratedPreciousTitle,
          subtitle: context.l10n.homeCuratedPreciousSubtitle,
          trailing: TextButton(
            onPressed: () => context.go('/search?category=precious'),
            child: Text(context.l10n.homeSectionViewAll),
          ),
        ),
        SizedBox(height: tokens.space4),
        HomeAuctionRail(
          auctions: precious,
          isLoading: isLoading,
          heroNamespace: 'home-precious',
          onTapAuction: onTapAuction,
        ),
      ],
    );
  }
}
