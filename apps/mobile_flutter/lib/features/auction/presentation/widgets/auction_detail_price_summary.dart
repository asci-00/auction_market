import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../data/auction_detail_view_data.dart';

class AuctionDetailPriceSummary extends StatelessWidget {
  const AuctionDetailPriceSummary({super.key, required this.auction});

  final AuctionDetailViewData auction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: AppPanel(
            tone: AppPanelTone.surface,
            child: _MetricBlock(
              label: context.l10n.auctionDetailCurrentBid,
              value: formatKrw(context, auction.currentPrice),
            ),
          ),
        ),
        SizedBox(width: tokens.space3),
        Expanded(
          child: AppPanel(
            tone: AppPanelTone.elevated,
            child: _MetricBlock(
              label: context.l10n.auctionDetailBuyNow,
              value: auction.buyNowPrice != null
                  ? formatKrw(context, auction.buyNowPrice!)
                  : context.l10n.genericUnavailable,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.bodySmall),
        SizedBox(height: tokens.space2),
        Text(value, style: context.textTheme.titleLarge),
      ],
    );
  }
}
