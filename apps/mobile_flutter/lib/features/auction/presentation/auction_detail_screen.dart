import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../application/auction_detail_action_service.dart';
import 'auction_detail_dialogs.dart';
import 'auction_view_model.dart';
import 'widgets/auction_detail_view.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  const AuctionDetailScreen({super.key, required this.auctionId, this.heroTag});

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
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final auctionAsync = ref.watch(auctionViewModelProvider(widget.auctionId));

    return auctionAsync.when(
      error: (_, __) => AuctionDetailView(
        heroTag: widget.heroTag,
        userId: userId,
        isSubmitting: _isSubmitting,
        auction: null,
        hasError: true,
        bidHistory: const [],
        isLoading: false,
        onBrowseHome: () => context.go('/home'),
        onRequireLogin: () =>
            context.go('/login?from=/auction/${widget.auctionId}'),
        onReviewOrders: () => context.pushReplacement('/orders'),
        onOpenOrder: (orderId) {
          if (orderId != null && orderId.isNotEmpty) {
            context.pushReplacement('/orders/$orderId');
          }
        },
        onPlaceBid: _placeBid,
        onSetAutoBid: _setAutoBid,
        onBuyNow: _buyNow,
      ),
      loading: () => AuctionDetailView(
        heroTag: widget.heroTag,
        userId: userId,
        isSubmitting: _isSubmitting,
        auction: null,
        hasError: false,
        bidHistory: const [],
        isLoading: true,
        onBrowseHome: () => context.go('/home'),
        onRequireLogin: () =>
            context.go('/login?from=/auction/${widget.auctionId}'),
        onReviewOrders: () => context.pushReplacement('/orders'),
        onOpenOrder: (orderId) {
          if (orderId != null && orderId.isNotEmpty) {
            context.pushReplacement('/orders/$orderId');
          }
        },
        onPlaceBid: _placeBid,
        onSetAutoBid: _setAutoBid,
        onBuyNow: _buyNow,
      ),
      data: (state) => AuctionDetailView(
        heroTag: widget.heroTag,
        userId: userId,
        isSubmitting: _isSubmitting,
        auction: state.detail,
        hasError: false,
        bidHistory: state.bidHistory,
        isLoading: false,
        onBrowseHome: () => context.go('/home'),
        onRequireLogin: () =>
            context.go('/login?from=/auction/${widget.auctionId}'),
        onReviewOrders: () => context.pushReplacement('/orders'),
        onOpenOrder: (orderId) {
          if (orderId != null && orderId.isNotEmpty) {
            context.pushReplacement('/orders/$orderId');
          }
        },
        onPlaceBid: _placeBid,
        onSetAutoBid: _setAutoBid,
        onBuyNow: _buyNow,
      ),
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
      action: () => ref
          .read(auctionDetailActionServiceProvider)
          .placeBid(auctionId: widget.auctionId, amount: amount),
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
      action: () => ref
          .read(auctionDetailActionServiceProvider)
          .setAutoBid(auctionId: widget.auctionId, maxAmount: maxAmount),
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
