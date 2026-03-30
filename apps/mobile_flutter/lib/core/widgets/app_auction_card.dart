import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_status_badge.dart';

class AppAuctionCard extends StatelessWidget {
  const AppAuctionCard({
    super.key,
    required this.title,
    required this.priceLabel,
    required this.bidCountLabel,
    required this.badgeKind,
    this.metaLabel,
    this.meta,
    this.imageUrl,
    this.heroTag,
    this.onTap,
  }) : assert(
         metaLabel != null || meta != null,
         'Either metaLabel or meta must be provided.',
       );

  final String title;
  final String priceLabel;
  final String? metaLabel;
  final Widget? meta;
  final String bidCountLabel;
  final AppStatusKind badgeKind;
  final String? imageUrl;
  final String? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _AuctionCardLayout.fromConstraints(
          constraints,
          tokens: tokens,
        );

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.cardRadius),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurfaceFor(brightness),
                borderRadius: BorderRadius.circular(tokens.cardRadius),
                border: Border.all(color: AppColors.borderSoftFor(brightness)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlayFor(brightness).withValues(
                      alpha: brightness == Brightness.dark ? 0.24 : 0.08,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: layout.mediaFlex,
                    child: _AuctionCardMedia(
                      priceLabel: priceLabel,
                      imageUrl: imageUrl,
                      heroTag: heroTag,
                      badgeKind: badgeKind,
                      layout: layout,
                    ),
                  ),
                  Expanded(
                    flex: layout.detailsFlex,
                    child: _AuctionCardDetails(
                      title: title,
                      metaLabel: metaLabel,
                      meta: meta,
                      bidCountLabel: bidCountLabel,
                      layout: layout,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuctionCardMedia extends StatelessWidget {
  const _AuctionCardMedia({
    required this.priceLabel,
    required this.imageUrl,
    required this.heroTag,
    required this.badgeKind,
    required this.layout,
  });

  final String priceLabel;
  final String? imageUrl;
  final String? heroTag;
  final AppStatusKind badgeKind;
  final _AuctionCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        _AuctionImage(imageUrl: imageUrl, heroTag: heroTag),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xAA1E1C1A)],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(layout.badgePadding),
          child: Align(
            alignment: Alignment.topLeft,
            child: AppStatusBadge(kind: badgeKind),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(layout.contentPadding),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              priceLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.textInverse,
                fontSize: layout.priceFontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuctionCardDetails extends StatelessWidget {
  const _AuctionCardDetails({
    required this.title,
    required this.metaLabel,
    required this.meta,
    required this.bidCountLabel,
    required this.layout,
  });

  final String title;
  final String? metaLabel;
  final Widget? meta;
  final String bidCountLabel;
  final _AuctionCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final titleTextStyle = layout.isCompact
        ? theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimaryFor(brightness),
          )
        : theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimaryFor(brightness),
          );

    return Padding(
      padding: EdgeInsets.all(layout.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              title,
              maxLines: layout.titleMaxLines,
              overflow: TextOverflow.ellipsis,
              style: titleTextStyle,
            ),
          ),
          SizedBox(height: layout.metaSpacing),
          if (meta != null)
            meta!
          else
            Text(
              metaLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          SizedBox(height: layout.bidSpacing),
          Text(
            bidCountLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.accentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionCardLayout {
  const _AuctionCardLayout({
    required this.mediaFlex,
    required this.detailsFlex,
    required this.contentPadding,
    required this.badgePadding,
    required this.metaSpacing,
    required this.bidSpacing,
    required this.titleMaxLines,
    required this.priceFontSize,
    required this.isCompact,
  });

  factory _AuctionCardLayout.fromConstraints(
    BoxConstraints constraints, {
    required AppThemeTokens tokens,
  }) {
    final maxHeight = constraints.maxHeight;
    final compact = maxHeight.isFinite && maxHeight < 300;

    return _AuctionCardLayout(
      mediaFlex: compact ? 57 : 62,
      detailsFlex: compact ? 43 : 38,
      contentPadding: compact ? tokens.space3 : tokens.space4,
      badgePadding: compact ? tokens.space2 : tokens.space3,
      metaSpacing: compact ? tokens.space1 : tokens.space2,
      // Keep vertical rhythm tighter to avoid text overflow near breakpoints.
      bidSpacing: compact ? tokens.space1 : tokens.space2,
      titleMaxLines: compact ? 1 : 2,
      priceFontSize: compact ? 24 : 28,
      isCompact: compact,
    );
  }

  final int mediaFlex;
  final int detailsFlex;
  final double contentPadding;
  final double badgePadding;
  final double metaSpacing;
  final double bidSpacing;
  final int titleMaxLines;
  final double priceFontSize;
  final bool isCompact;
}

class _AuctionImage extends StatelessWidget {
  const _AuctionImage({this.imageUrl, this.heroTag});

  final String? imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = imageUrl != null && imageUrl!.isNotEmpty
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _FallbackImage(),
          )
        : const _FallbackImage();

    if (heroTag == null) {
      return image;
    }

    return Hero(tag: heroTag!, child: image);
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            brightness == Brightness.dark
                ? AppColors.bgElevatedDark
                : AppColors.sand,
            AppColors.accentPrimarySoftFor(brightness),
            AppColors.bgSurfaceFor(brightness),
          ],
        ),
      ),
    );
  }
}
