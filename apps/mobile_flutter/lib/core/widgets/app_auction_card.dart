import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_status_badge.dart';

class AppAuctionCard extends StatelessWidget {
  const AppAuctionCard({
    super.key,
    required this.title,
    required this.priceLabel,
    required this.metaLabel,
    required this.bidCountLabel,
    required this.badgeKind,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String priceLabel;
  final String metaLabel;
  final String bidCountLabel;
  final AppStatusKind badgeKind;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

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
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(tokens.cardRadius),
                border: Border.all(color: AppColors.borderSoft),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlay.withValues(alpha: 0.08),
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
                      badgeKind: badgeKind,
                      layout: layout,
                    ),
                  ),
                  Expanded(
                    flex: layout.detailsFlex,
                    child: _AuctionCardDetails(
                      title: title,
                      metaLabel: metaLabel,
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
    required this.badgeKind,
    required this.layout,
  });

  final String priceLabel;
  final String? imageUrl;
  final AppStatusKind badgeKind;
  final _AuctionCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        _AuctionImage(imageUrl: imageUrl),
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
    required this.bidCountLabel,
    required this.layout,
  });

  final String title;
  final String metaLabel;
  final String bidCountLabel;
  final _AuctionCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(layout.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: layout.titleMaxLines,
            overflow: TextOverflow.ellipsis,
            style: layout.isCompact
                ? theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  )
                : theme.textTheme.titleMedium,
          ),
          SizedBox(height: layout.metaSpacing),
          Text(
            metaLabel,
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
      bidSpacing: compact ? tokens.space2 : tokens.space3,
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
  const _AuctionImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _FallbackImage(),
      );
    }

    return const _FallbackImage();
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage();

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
            AppColors.bgSurface
          ],
        ),
      ),
    );
  }
}
