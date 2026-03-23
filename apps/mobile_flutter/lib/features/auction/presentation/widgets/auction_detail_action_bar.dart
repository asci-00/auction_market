import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_sticky_action_bar.dart';
import '../../data/auction_detail_view_data.dart';

class AuctionDetailActionBar extends StatelessWidget {
  const AuctionDetailActionBar({
    super.key,
    required this.auction,
    required this.userId,
    required this.isSubmitting,
    required this.onBrowseHome,
    required this.onRequireLogin,
    required this.onReviewOrders,
    required this.onOpenOrder,
    required this.onPlaceBid,
    required this.onSetAutoBid,
    required this.onBuyNow,
  });

  final AuctionDetailViewData? auction;
  final String? userId;
  final bool isSubmitting;
  final VoidCallback onBrowseHome;
  final VoidCallback onRequireLogin;
  final VoidCallback onReviewOrders;
  final VoidCallback? onOpenOrder;
  final VoidCallback? onPlaceBid;
  final VoidCallback? onSetAutoBid;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (auction == null) {
      return AppStickyActionBar(
        title: l10n.auctionDetailCurrentBid,
        subtitle: l10n.auctionDetailActionHint,
        child: _BrowseHomeAction(onPressed: onBrowseHome),
      );
    }

    final currentPrice = formatKrw(context, auction!.currentPrice);

    if (!auction!.isLive) {
      return AppStickyActionBar(
        title: currentPrice,
        subtitle: auction!.hasOrder
            ? l10n.auctionDetailOrderReadyHint
            : l10n.auctionDetailEndedHint,
        child: auction!.hasOrder
            ? _PrimaryActionButton(
                label: l10n.auctionDetailViewOrder,
                onPressed: onOpenOrder,
              )
            : _BrowseHomeAction(onPressed: onBrowseHome),
      );
    }

    if (userId == null) {
      return AppStickyActionBar(
        title: currentPrice,
        subtitle: l10n.auctionDetailLoginHint,
        child: _PrimaryActionButton(
          label: l10n.auctionDetailSignInAction,
          onPressed: onRequireLogin,
        ),
      );
    }

    if (auction!.sellerId == userId) {
      return AppStickyActionBar(
        title: currentPrice,
        subtitle: auction!.endAt != null
            ? l10n.auctionDetailSellerOwnedHint(
                formatCompactDateTime(context, auction!.endAt!),
              )
            : l10n.auctionDetailSellerOwnedFallback,
        child: _SecondaryActionButton(
          label: l10n.auctionDetailSellerOwnedAction,
          onPressed: onReviewOrders,
        ),
      );
    }

    return AppStickyActionBar(
      title: currentPrice,
      subtitle: auction!.endAt != null
          ? l10n.auctionDetailLiveActionHint(
              formatKrw(context, auction!.minimumBid),
              formatCompactDateTime(context, auction!.endAt!),
            )
          : l10n.auctionDetailActionHint,
      child: _BuyerAuctionActions(
        auction: auction!,
        isSubmitting: isSubmitting,
        onPlaceBid: onPlaceBid,
        onSetAutoBid: onSetAutoBid,
        onBuyNow: onBuyNow,
      ),
    );
  }
}

class _BuyerAuctionActions extends StatelessWidget {
  const _BuyerAuctionActions({
    required this.auction,
    required this.isSubmitting,
    required this.onPlaceBid,
    required this.onSetAutoBid,
    required this.onBuyNow,
  });

  final AuctionDetailViewData auction;
  final bool isSubmitting;
  final VoidCallback? onPlaceBid;
  final VoidCallback? onSetAutoBid;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _PrimaryActionButton(
                label: context.l10n.auctionDetailBidAction(
                  formatKrw(context, auction.minimumBid),
                ),
                onPressed: isSubmitting ? null : onPlaceBid,
              ),
            ),
            if (auction.buyNowPrice != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _SecondaryActionButton(
                  label: context.l10n.auctionDetailBuyNowAction(
                    formatKrw(context, auction.buyNowPrice!),
                  ),
                  onPressed: isSubmitting ? null : onBuyNow,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: isSubmitting ? null : onSetAutoBid,
          child: Text(context.l10n.auctionDetailAutoBidAction),
        ),
      ],
    );
  }
}

class _BrowseHomeAction extends StatelessWidget {
  const _BrowseHomeAction({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _SecondaryActionButton(
      label: context.l10n.auctionDetailBrowseAction,
      onPressed: onPressed,
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: context.textTheme.labelLarge?.copyWith(
            color: AppColors.textInverse,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
