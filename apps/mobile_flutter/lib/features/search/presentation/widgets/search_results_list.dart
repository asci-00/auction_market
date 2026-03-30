import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_live_countdown_text.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/search_auction_summary.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key, required this.results});

  final List<SearchAuctionSummary> results;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => SizedBox(height: tokens.space3),
      itemBuilder: (context, index) {
        final auction = results[index];

        return AppStaggeredReveal(
          index: index,
          child: _SearchResultListTile(auction: auction),
        );
      },
    );
  }
}

class _SearchResultListTile extends StatelessWidget {
  const _SearchResultListTile({required this.auction});

  final SearchAuctionSummary auction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        onTap: () =>
            context.push('/auction/${auction.id}?heroTag=search-${auction.id}'),
        child: AppPanel(
          padding: EdgeInsets.all(tokens.space3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchResultListMedia(auction: auction),
              SizedBox(width: tokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction.title.isNotEmpty
                          ? auction.title
                          : context.l10n.genericUnavailable,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: tokens.space2),
                    Text(
                      formatKrw(context, auction.currentPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: tokens.space1),
                    _SearchResultMeta(auction: auction),
                    SizedBox(height: tokens.space2),
                    Wrap(
                      spacing: tokens.space2,
                      runSpacing: tokens.space2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          context.l10n.genericCountBids(auction.bidCount),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.accentPrimary),
                        ),
                        Text(
                          auction.categorySub.replaceAll('_', ' '),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondaryFor(brightness),
                              ),
                        ),
                      ],
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

class _SearchResultListMedia extends StatelessWidget {
  const _SearchResultListMedia({required this.auction});

  final SearchAuctionSummary auction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      width: 108,
      height: 128,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _SearchResultImage(
              imageUrl: auction.heroImageUrl,
              heroTag: 'search-${auction.id}',
            ),
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
              padding: EdgeInsets.all(tokens.space2),
              child: Align(
                alignment: Alignment.topLeft,
                child: AppStatusBadge(
                  kind: auction.buyNowPrice != null
                      ? AppStatusKind.buyNow
                      : AppStatusKind.live,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.cardRadius),
                border: Border.all(color: AppColors.borderSoftFor(brightness)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultImage extends StatelessWidget {
  const _SearchResultImage({required this.imageUrl, required this.heroTag});

  final String? imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? const [Color(0xFF4A443F), Color(0xFF241F1B)]
              : const [Color(0xFFE8DDD2), Color(0xFFC58C5C)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white70),
      ),
    );

    final image = imageUrl != null && imageUrl!.isNotEmpty
        ? Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          )
        : fallback;

    return Hero(tag: heroTag, child: image);
  }
}

class _SearchResultMeta extends StatelessWidget {
  const _SearchResultMeta({required this.auction});

  final SearchAuctionSummary auction;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;

    if (auction.endAt == null) {
      return Text(
        context.l10n.genericUnavailable,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }

    return AppLiveCountdownText(
      targetTime: auction.endAt!,
      builder: (context, label) => Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
      expiredBuilder: (context) => Text(
        context.l10n.genericUnavailable,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      ),
    );
  }
}
