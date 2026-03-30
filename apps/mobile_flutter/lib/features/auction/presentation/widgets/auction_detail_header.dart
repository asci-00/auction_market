import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/auction_detail_view_data.dart';

class AuctionDetailHeader extends StatelessWidget {
  const AuctionDetailHeader({super.key, required this.auction, this.heroTag});

  final AuctionDetailViewData auction;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

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
              _DetailHeroImage(
                imageUrl: auction.heroImageUrl,
                heroTag: heroTag,
                brightness: brightness,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.panelOverlayFor(brightness),
                    ],
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

class _DetailHeroImage extends StatelessWidget {
  const _DetailHeroImage({
    required this.imageUrl,
    required this.heroTag,
    required this.brightness,
  });

  final String? imageUrl;
  final String? heroTag;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final image = imageUrl != null && imageUrl!.isNotEmpty
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _DetailFallbackImage(brightness: brightness),
          )
        : _DetailFallbackImage(brightness: brightness);

    if (heroTag == null) {
      return image;
    }

    return Hero(tag: heroTag!, child: image);
  }
}

class _DetailFallbackImage extends StatelessWidget {
  const _DetailFallbackImage({required this.brightness});

  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bgMutedFor(brightness),
            AppColors.accentPrimarySoftFor(brightness),
            AppColors.panelFor(brightness),
          ],
        ),
      ),
    );
  }
}
