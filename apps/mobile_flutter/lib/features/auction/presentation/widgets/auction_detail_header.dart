import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/auction_detail_view_data.dart';

class AuctionDetailHeader extends StatelessWidget {
  const AuctionDetailHeader({
    super.key,
    required this.auction,
  });

  final AuctionDetailViewData auction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

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
              if (auction.heroImageUrl != null &&
                  auction.heroImageUrl!.isNotEmpty)
                Image.network(
                  auction.heroImageUrl!,
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
                    colors: [Colors.transparent, AppColors.panelOverlay],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(tokens.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStatusBadge(
                      kind: auction.hasBuyNow
                          ? AppStatusKind.buyNow
                          : AppStatusKind.live,
                    ),
                    const Spacer(),
                    Text(
                      auction.titleSnapshot.isEmpty
                          ? context.l10n.genericUnavailable
                          : auction.titleSnapshot,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                    SizedBox(height: tokens.space2),
                    Text(
                      '#${auction.id}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textInverse.withValues(alpha: 0.76),
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
            AppColors.panel,
          ],
        ),
      ),
    );
  }
}
