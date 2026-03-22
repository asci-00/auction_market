import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/firebase/firebase_providers.dart';
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

class AuctionDetailScreen extends ConsumerStatefulWidget {
  const AuctionDetailScreen({super.key, required this.auctionId});

  final String auctionId;

  @override
  ConsumerState<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  bool _submittingBid = false;
  bool _submittingAutoBid = false;
  bool _submittingBuyNow = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final auctionStream = FirebaseFirestore.instance
        .collection('auctions')
        .doc(widget.auctionId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: auctionStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final hasAuction = data != null;

        return AppPageScaffold(
          title: l10n.auctionDetailTitle,
          extendBody: true,
          bottomBar: _buildBottomBar(context, data, userId),
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
                _AuctionHeader(data: data, auctionId: widget.auctionId),
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
                _BidHistoryCard(auctionId: widget.auctionId),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    Map<String, dynamic>? data,
    String? userId,
  ) {
    final l10n = context.l10n;

    if (data == null) {
      return AppStickyActionBar(
        title: l10n.auctionDetailCurrentBid,
        subtitle: l10n.auctionDetailActionHint,
        child: _buildBrowseButton(context),
      );
    }

    final currentPrice = (data['currentPrice'] as num?) ?? 0;
    final buyNowPrice = data['buyNowPrice'] as num?;
    final orderId = data['orderId'] as String?;
    final sellerId = data['sellerId'] as String?;
    final status = data['status'] as String? ?? 'DRAFT';
    final endAt = (data['endAt'] as Timestamp?)?.toDate();
    final minimumBid = (currentPrice + _minIncrementFor(currentPrice)).toInt();

    if (status != 'LIVE') {
      return AppStickyActionBar(
        title: formatKrw(context, currentPrice),
        subtitle: orderId != null
            ? l10n.auctionDetailOrderReadyHint
            : l10n.auctionDetailEndedHint,
        child: orderId != null
            ? SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/orders/$orderId'),
                  child: Text(l10n.auctionDetailViewOrder),
                ),
              )
            : _buildBrowseButton(context),
      );
    }

    if (userId == null) {
      return AppStickyActionBar(
        title: formatKrw(context, currentPrice),
        subtitle: l10n.auctionDetailLoginHint,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () =>
                context.go('/login?from=/auction/${widget.auctionId}'),
            child: Text(l10n.loginContinueGoogle),
          ),
        ),
      );
    }

    if (sellerId == userId) {
      return AppStickyActionBar(
        title: formatKrw(context, currentPrice),
        subtitle: endAt != null
            ? l10n.auctionDetailSellerOwnedHint(
                formatCompactDateTime(context, endAt),
              )
            : l10n.auctionDetailSellerOwnedFallback,
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/orders'),
            child: Text(
              l10n.auctionDetailSellerOwnedAction,
              style: const TextStyle(color: AppColors.textInverse),
            ),
          ),
        ),
      );
    }

    return AppStickyActionBar(
      title: formatKrw(context, currentPrice),
      subtitle: endAt != null
          ? l10n.auctionDetailLiveActionHint(
              formatKrw(context, minimumBid),
              formatCompactDateTime(context, endAt),
            )
          : l10n.auctionDetailActionHint,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed:
                      _submittingBid || _submittingAutoBid || _submittingBuyNow
                          ? null
                          : () => _openBidDialog(minimumBid),
                  child: Text(l10n
                      .auctionDetailBidAction(formatKrw(context, minimumBid))),
                ),
              ),
              if (buyNowPrice != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submittingBid ||
                            _submittingAutoBid ||
                            _submittingBuyNow
                        ? null
                        : () => _buyNow(),
                    child: Text(
                      l10n.auctionDetailBuyNowAction(
                          formatKrw(context, buyNowPrice)),
                      style: const TextStyle(color: AppColors.textInverse),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _submittingBid || _submittingAutoBid || _submittingBuyNow
                ? null
                : () => _openAutoBidDialog(minimumBid),
            child: Text(l10n.auctionDetailAutoBidAction),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => context.go('/home'),
        child: Text(
          context.l10n.auctionDetailBrowseAction,
          style: const TextStyle(color: AppColors.textInverse),
        ),
      ),
    );
  }

  Future<void> _openBidDialog(int minimumBid) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: '$minimumBid');

    try {
      final amount = await showDialog<int>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.auctionDetailBidDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.auctionDetailBidMinimum(formatKrw(context, minimumBid)),
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.auctionDetailBidAmountLabel,
                    hintText: l10n.auctionDetailBidAmountHint,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.auctionDetailDialogCancel),
              ),
              FilledButton(
                onPressed: () {
                  final parsedAmount = int.tryParse(controller.text.trim());
                  if (parsedAmount == null || parsedAmount < minimumBid) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(parsedAmount);
                },
                child: Text(l10n.auctionDetailDialogSubmitBid),
              ),
            ],
          );
        },
      );

      if (!mounted || amount == null) {
        return;
      }

      await _runAuctionAction(
        type: _AuctionActionType.bid,
        action: () =>
            ref.read(functionsProvider).httpsCallable('placeBid').call({
          'auctionId': widget.auctionId,
          'amount': amount,
        }),
        successMessage: l10n.auctionDetailActionSuccessBid,
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _openAutoBidDialog(int minimumBid) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: '$minimumBid');

    try {
      final maxAmount = await showDialog<int>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.auctionDetailAutoBidDialogTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.auctionDetailAutoBidHint(formatKrw(context, minimumBid)),
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.auctionDetailAutoBidAmountLabel,
                    hintText: l10n.auctionDetailAutoBidAmountHint,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.auctionDetailDialogCancel),
              ),
              FilledButton(
                onPressed: () {
                  final parsedAmount = int.tryParse(controller.text.trim());
                  if (parsedAmount == null || parsedAmount < minimumBid) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(parsedAmount);
                },
                child: Text(l10n.auctionDetailDialogSubmitAutoBid),
              ),
            ],
          );
        },
      );

      if (!mounted || maxAmount == null) {
        return;
      }

      await _runAuctionAction(
        type: _AuctionActionType.autoBid,
        action: () =>
            ref.read(functionsProvider).httpsCallable('setAutoBid').call({
          'auctionId': widget.auctionId,
          'maxAmount': maxAmount,
        }),
        successMessage: l10n.auctionDetailActionSuccessAutoBid,
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _buyNow() async {
    final l10n = context.l10n;

    final result = await _runAuctionAction(
      type: _AuctionActionType.buyNow,
      action: () => ref.read(functionsProvider).httpsCallable('buyNow').call({
        'auctionId': widget.auctionId,
      }),
      successMessage: l10n.auctionDetailActionSuccessBuyNow,
    );

    final orderId = result?.data is Map
        ? (result!.data as Map)['orderId'] as String?
        : null;
    if (!mounted || orderId == null || orderId.isEmpty) {
      return;
    }

    context.go('/orders/$orderId');
  }

  Future<HttpsCallableResult<dynamic>?> _runAuctionAction({
    required _AuctionActionType type,
    required Future<HttpsCallableResult<dynamic>> Function() action,
    required String successMessage,
  }) async {
    _setSubmitting(type, true);

    try {
      final result = await action();
      if (!mounted) {
        return result;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
      return result;
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? context.l10n.auctionDetailActionFailed,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.auctionDetailActionFailed)),
      );
    } finally {
      if (mounted) {
        _setSubmitting(type, false);
      }
    }

    return null;
  }

  void _setSubmitting(_AuctionActionType type, bool value) {
    setState(() {
      switch (type) {
        case _AuctionActionType.bid:
          _submittingBid = value;
          break;
        case _AuctionActionType.autoBid:
          _submittingAutoBid = value;
          break;
        case _AuctionActionType.buyNow:
          _submittingBuyNow = value;
          break;
      }
    });
  }
}

enum _AuctionActionType {
  bid,
  autoBid,
  buyNow,
}

int _minIncrementFor(num currentPrice) {
  if (currentPrice <= 99999) {
    return 1000;
  }
  if (currentPrice <= 499999) {
    return 5000;
  }
  if (currentPrice <= 999999) {
    return 10000;
  }
  return 50000;
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
