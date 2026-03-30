import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_auction_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_live_countdown_text.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../application/search_auction_filter.dart';
import '../search_view_model.dart';

class SearchResultsGrid extends ConsumerWidget {
  const SearchResultsGrid({
    super.key,
    required this.query,
    required this.filters,
    required this.onResetQuery,
    required this.onResetFilters,
  });

  final String query;
  final SearchFilterState filters;
  final VoidCallback onResetQuery;
  final VoidCallback onResetFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchViewModelProvider(query));

    return searchAsync.when(
      error: (_, __) => AppEmptyState(
        icon: Icons.search_off_rounded,
        title: context.l10n.genericUnavailable,
        description: context.l10n.searchErrorDescription,
      ),
      loading: () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.64,
        ),
        itemBuilder: (_, __) =>
            const AppShimmerCardPlaceholder(height: double.infinity),
      ),
      data: (state) {
        final filtered = applySearchSelectionFilters(state.results, filters);
        if (filtered.isEmpty) {
          final hasQuery = query.trim().isNotEmpty;
          final hasFilters = filters.hasActiveSelection;

          return AppEmptyState(
            icon: Icons.grid_view_rounded,
            title: context.l10n.searchEmptyTitle,
            description: context.l10n.searchEmptyDescription,
            action: hasQuery || hasFilters
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (hasFilters)
                        TextButton(
                          onPressed: onResetFilters,
                          child: Text(context.l10n.searchResetFiltersAction),
                        ),
                      if (hasQuery)
                        TextButton(
                          onPressed: onResetQuery,
                          child: Text(context.l10n.searchResetAction),
                        ),
                    ],
                  )
                : null,
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.64,
          ),
          itemBuilder: (context, index) {
            final auction = filtered[index];

            return AppStaggeredReveal(
              index: index,
              child: AppAuctionCard(
                title: auction.title.isNotEmpty
                    ? auction.title
                    : context.l10n.genericUnavailable,
                priceLabel: formatKrw(context, auction.currentPrice),
                meta: auction.endAt != null
                    ? AppLiveCountdownText(
                        targetTime: auction.endAt!,
                        builder: (context, label) => Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        expiredBuilder: (context) => Text(
                          context.l10n.genericUnavailable,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    : Text(
                        context.l10n.genericUnavailable,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                bidCountLabel: context.l10n.genericCountBids(auction.bidCount),
                imageUrl: auction.heroImageUrl,
                heroTag: 'search-${auction.id}',
                badgeKind: auction.buyNowPrice != null
                    ? AppStatusKind.buyNow
                    : AppStatusKind.live,
                onTap: () => context.push(
                  '/auction/${auction.id}?heroTag=search-${auction.id}',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
