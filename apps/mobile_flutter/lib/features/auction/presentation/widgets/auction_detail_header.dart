import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/auction_detail_view_data.dart';

class AuctionDetailHeader extends StatefulWidget {
  const AuctionDetailHeader({super.key, required this.auction, this.heroTag});

  final AuctionDetailViewData auction;
  final String? heroTag;

  @override
  State<AuctionDetailHeader> createState() => _AuctionDetailHeaderState();
}

class _AuctionDetailHeaderState extends State<AuctionDetailHeader> {
  late final PageController _pageController;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AuctionDetailHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLength = _imagesFor(oldWidget.auction).length;
    final newLength = _imagesFor(widget.auction).length;
    if (newLength == oldLength) {
      return;
    }

    final nextIndex = newLength == 0
        ? 0
        : _activeIndex.clamp(0, newLength - 1).toInt();
    if (nextIndex != _activeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _activeIndex = nextIndex;
        });
        if (_pageController.hasClients) {
          _pageController.jumpToPage(nextIndex);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;
    final images = _imagesFor(widget.auction);

    return AppPanel(
      tone: AppPanelTone.dark,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      if (_activeIndex == index) {
                        return;
                      }
                      setState(() {
                        _activeIndex = index;
                      });
                    },
                    itemBuilder: (context, index) => _DetailGalleryImage(
                      imageUrl: images[index],
                      heroTag: index == 0 ? widget.heroTag : null,
                      brightness: brightness,
                    ),
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
                        Row(
                          children: [
                            AppStatusBadge(
                              kind: widget.auction.hasBuyNow
                                  ? AppStatusKind.buyNow
                                  : AppStatusKind.live,
                            ),
                            const Spacer(),
                            if (images.length > 1)
                              _GalleryCounter(
                                currentIndex: _activeIndex + 1,
                                total: images.length,
                              ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          widget.auction.titleSnapshot.isEmpty
                              ? context.l10n.genericUnavailable
                              : widget.auction.titleSnapshot,
                          style: context.textTheme.headlineMedium?.copyWith(
                            color: AppColors.textInverse,
                          ),
                        ),
                        SizedBox(height: tokens.space2),
                        Text(
                          '#${widget.auction.id}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textInverse.withValues(
                              alpha: 0.76,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (images.length > 1)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.space4,
                  tokens.space3,
                  tokens.space4,
                  tokens.space4,
                ),
                child: Row(
                  children: List.generate(
                    images.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        right: index == images.length - 1 ? 0 : tokens.space2,
                      ),
                      child: _GalleryIndicator(isActive: index == _activeIndex),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

List<String?> _imagesFor(AuctionDetailViewData auction) {
  return auction.imageUrls.isNotEmpty
      ? auction.imageUrls
      : <String?>[auction.heroImageUrl];
}

class _DetailGalleryImage extends StatelessWidget {
  const _DetailGalleryImage({
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

class _GalleryCounter extends StatelessWidget {
  const _GalleryCounter({required this.currentIndex, required this.total});

  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space3,
          vertical: tokens.space2,
        ),
        child: Text(
          '$currentIndex / $total',
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.textInverse,
          ),
        ),
      ),
    );
  }
}

class _GalleryIndicator extends StatelessWidget {
  const _GalleryIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: isActive ? tokens.space6 : tokens.space3,
      height: 4,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.textInverse
            : AppColors.textInverse.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
