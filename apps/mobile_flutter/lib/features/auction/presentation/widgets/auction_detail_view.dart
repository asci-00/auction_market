import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_editorial_hero.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_page_insets.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_page_scaffold.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/auction_bid_history_entry.dart';
import '../../data/auction_detail_view_data.dart';
import 'auction_bid_history_card.dart';
import 'auction_detail_action_bar.dart';
import 'auction_detail_description_panel.dart';
import 'auction_detail_header.dart';
import 'auction_detail_price_summary.dart';

class AuctionDetailView extends StatelessWidget {
  const AuctionDetailView({
    super.key,
    required this.heroTag,
    required this.userId,
    required this.isSubmitting,
    required this.auction,
    required this.hasError,
    required this.bidHistory,
    required this.isLoading,
    required this.onBrowseHome,
    required this.onRequireLogin,
    required this.onReviewOrders,
    required this.onOpenOrder,
    required this.onPlaceBid,
    required this.onSetAutoBid,
    required this.onBuyNow,
  });

  final String? heroTag;
  final String? userId;
  final bool isSubmitting;
  final AuctionDetailViewData? auction;
  final bool hasError;
  final List<AuctionBidHistoryEntry> bidHistory;
  final bool isLoading;
  final VoidCallback onBrowseHome;
  final VoidCallback onRequireLogin;
  final VoidCallback onReviewOrders;
  final void Function(String? orderId) onOpenOrder;
  final void Function(int minimumBid) onPlaceBid;
  final void Function(int minimumBid) onSetAutoBid;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPageScaffold(
      title: context.l10n.auctionDetailTitle,
      extendBody: true,
      bottomBar: AuctionDetailActionBar(
        auction: auction,
        userId: userId,
        isSubmitting: isSubmitting,
        onBrowseHome: onBrowseHome,
        onRequireLogin: onRequireLogin,
        onReviewOrders: onReviewOrders,
        onOpenOrder: () => onOpenOrder(auction?.orderId),
        onPlaceBid: auction == null ? null : () => onPlaceBid(auction!.minimumBid),
        onSetAutoBid: auction == null
            ? null
            : () => onSetAutoBid(auction!.minimumBid),
        onBuyNow: onBuyNow,
      ),
      body: Builder(
        builder: (bodyContext) => ListView(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.space4,
            tokens.screenPadding,
            tokens.space8 + bodyContext.pageBottomInset,
          ),
          children: [
            if (hasError)
              AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: context.l10n.genericUnavailable,
                description: context.l10n.auctionDetailFallbackDescription,
                tone: AppPanelTone.soft,
              )
            else if (auction == null && isLoading)
              AppPanel(
                tone: AppPanelTone.surface,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: tokens.space6),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              )
            else if (auction == null && !isLoading)
              AppEmptyState(
                icon: Icons.photo_library_outlined,
                eyebrow: context.l10n.auctionDetailGalleryEyebrow,
                title: context.l10n.auctionDetailFallbackTitle,
                description: context.l10n.auctionDetailFallbackDescription,
                tone: AppPanelTone.dark,
              ),
            if (auction != null) ...[
              AuctionDetailHeader(auction: auction!, heroTag: heroTag),
              SizedBox(height: tokens.space5),
              AuctionDetailPriceSummary(auction: auction!),
              SizedBox(height: tokens.space5),
              AppEditorialHero(
                eyebrow: context.l10n.auctionDetailSellerSummary,
                title: auction!.titleSnapshot.isEmpty
                    ? context.l10n.genericUnavailable
                    : auction!.titleSnapshot,
                description: context.l10n.auctionDetailSellerDescription,
                badges: const [
                  AppStatusBadge(kind: AppStatusKind.verified),
                  AppStatusBadge(kind: AppStatusKind.live),
                ],
                tone: AppPanelTone.surface,
                trailing: _SellerSummaryPlate(sellerId: auction!.sellerId),
              ),
              SizedBox(height: tokens.space5),
              AuctionDetailDescriptionPanel(auction: auction!),
              SizedBox(height: tokens.space5),
              AppSectionHeading(
                title: context.l10n.auctionDetailBidHistory,
                subtitle: context.l10n.auctionDetailBidHistorySubtitle,
              ),
              SizedBox(height: tokens.space4),
              AuctionBidHistoryCard(
                bidHistory: bidHistory,
                isLoading: isLoading,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SellerSummaryPlate extends StatelessWidget {
  const _SellerSummaryPlate({required this.sellerId});

  final String? sellerId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return Container(
      width: 92,
      height: 112,
      decoration: BoxDecoration(
        color: AppColors.bgElevatedFor(brightness),
        borderRadius: BorderRadius.circular(tokens.heroRadius),
      ),
      padding: EdgeInsets.all(tokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            context.l10n.genericUnknownSeller,
            style: context.textTheme.bodySmall,
          ),
          SizedBox(height: tokens.space1),
          Text(
            sellerId ?? '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
