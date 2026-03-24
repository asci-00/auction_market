import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../application/auction_detail_action_service.dart';
import '../data/auction_detail_view_data.dart';
import 'auction_detail_dialogs.dart';
import 'widgets/auction_bid_history_card.dart';
import 'widgets/auction_detail_action_bar.dart';
import 'widgets/auction_detail_header.dart';
import 'widgets/auction_detail_price_summary.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  const AuctionDetailScreen({
    super.key,
    required this.auctionId,
    this.heroTag,
  });

  final String auctionId;
  final String? heroTag;

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final auctionStream = FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.auctionId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: auctionStream,
      builder: (context, snapshot) {
        final auction = snapshot.hasData && snapshot.data!.exists
            ? AuctionDetailViewData.fromDocument(snapshot.data!)
            : null;

        return AppPageScaffold(
          title: context.l10n.auctionDetailTitle,
          extendBody: true,
          bottomBar: AuctionDetailActionBar(
            auction: auction,
            userId: userId,
            isSubmitting: _isSubmitting,
            onBrowseHome: () => context.go('/home'),
            onRequireLogin: () =>
                context.go('/login?from=/auction/${widget.auctionId}'),
            onReviewOrders: () => context.go('/orders'),
            onOpenOrder: () {
              final orderId = auction?.orderId;
              if (orderId != null && orderId.isNotEmpty) {
                context.go('/orders/$orderId');
              }
            },
            onPlaceBid:
                auction == null ? null : () => _placeBid(auction.minimumBid),
            onSetAutoBid:
                auction == null ? null : () => _setAutoBid(auction.minimumBid),
            onBuyNow: _buyNow,
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.space4,
              tokens.screenPadding,
              tokens.stickyActionHeight +
                  MediaQuery.paddingOf(context).bottom +
                  tokens.space8,
            ),
            children: [
              if (snapshot.hasError)
                AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: context.l10n.genericUnavailable,
                  description: context.l10n.auctionDetailFallbackDescription,
                  tone: AppPanelTone.soft,
                )
              else if (auction == null)
                AppEmptyState(
                  icon: Icons.photo_library_outlined,
                  eyebrow: context.l10n.auctionDetailGalleryEyebrow,
                  title: context.l10n.auctionDetailFallbackTitle,
                  description: context.l10n.auctionDetailFallbackDescription,
                  tone: AppPanelTone.dark,
                )
              else
                AuctionDetailHeader(
                  auction: auction,
                  heroTag: widget.heroTag,
                ),
              SizedBox(height: tokens.space5),
              if (auction != null) AuctionDetailPriceSummary(auction: auction),
              if (auction != null) ...[
                SizedBox(height: tokens.space5),
                AppEditorialHero(
                  eyebrow: context.l10n.auctionDetailSellerSummary,
                  title: auction.titleSnapshot.isEmpty
                      ? context.l10n.genericUnavailable
                      : auction.titleSnapshot,
                  description: context.l10n.auctionDetailSellerDescription,
                  badges: const [
                    AppStatusBadge(kind: AppStatusKind.verified),
                    AppStatusBadge(kind: AppStatusKind.live),
                  ],
                  tone: AppPanelTone.surface,
                  trailing: _SellerSummaryPlate(sellerId: auction.sellerId),
                ),
                SizedBox(height: tokens.space5),
                AppSectionHeading(
                  title: context.l10n.auctionDetailBidHistory,
                  subtitle: context.l10n.auctionDetailBidHistorySubtitle,
                ),
                SizedBox(height: tokens.space4),
                AuctionBidHistoryCard(auctionId: widget.auctionId),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeBid(int minimumBid) async {
    final amount = await showAuctionBidAmountDialog(
      context,
      minimumBid: minimumBid,
    );
    if (!mounted || amount == null) {
      return;
    }

    await _runAuctionAction(
      action: () => ref.read(auctionDetailActionServiceProvider).placeBid(
            auctionId: widget.auctionId,
            amount: amount,
          ),
      successMessage: context.l10n.auctionDetailActionSuccessBid,
    );
  }

  Future<void> _setAutoBid(int minimumBid) async {
    final maxAmount = await showAuctionAutoBidDialog(
      context,
      minimumBid: minimumBid,
    );
    if (!mounted || maxAmount == null) {
      return;
    }

    await _runAuctionAction(
      action: () => ref.read(auctionDetailActionServiceProvider).setAutoBid(
            auctionId: widget.auctionId,
            maxAmount: maxAmount,
          ),
      successMessage: context.l10n.auctionDetailActionSuccessAutoBid,
    );
  }

  Future<void> _buyNow() async {
    String? orderId;

    await _runAuctionAction(
      action: () async {
        orderId = await ref
            .read(auctionDetailActionServiceProvider)
            .buyNow(auctionId: widget.auctionId);
      },
      successMessage: context.l10n.auctionDetailActionSuccessBuyNow,
    );

    if (!mounted || (orderId?.isEmpty ?? true)) {
      return;
    }

    context.go('/orders/$orderId');
  }

  Future<void> _runAuctionAction({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await action();
      if (!mounted) {
        return;
      }
      context.showSnackBarMessage(successMessage);
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(
        error.message ?? context.l10n.auctionDetailActionFailed,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.auctionDetailActionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _SellerSummaryPlate extends StatelessWidget {
  const _SellerSummaryPlate({
    required this.sellerId,
  });

  final String? sellerId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
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
