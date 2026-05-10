import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/search_auction_filter.dart';

class SearchFilterChips extends StatelessWidget {
  const SearchFilterChips({
    super.key,
    required this.filters,
    required this.onCycleCategory,
    required this.onCyclePrice,
    required this.onToggleEndingSoon,
    required this.onToggleBuyNow,
    this.onReset,
    this.scrollable = false,
  });

  final SearchFilterState filters;
  final VoidCallback onCycleCategory;
  final VoidCallback onCyclePrice;
  final ValueChanged<bool> onToggleEndingSoon;
  final ValueChanged<bool> onToggleBuyNow;
  final VoidCallback? onReset;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final chips = <Widget>[
      FilterChip(
        label: Text(_categoryLabel(context)),
        selected: filters.category != SearchCategoryFilter.all,
        onSelected: (_) => onCycleCategory(),
      ),
      FilterChip(
        label: Text(_priceLabel(context)),
        selected: filters.price != SearchPriceFilter.all,
        onSelected: (_) => onCyclePrice(),
      ),
      FilterChip(
        label: Text(context.l10n.searchFilterEndingSoon),
        selected: filters.endingSoonOnly,
        onSelected: onToggleEndingSoon,
      ),
      FilterChip(
        label: Text(context.l10n.searchFilterBuyNow),
        selected: filters.buyNowOnly,
        onSelected: onToggleBuyNow,
      ),
      if (onReset != null)
        ActionChip(
          avatar: const Icon(Icons.refresh_rounded, size: 18),
          label: Text(context.l10n.searchResetFiltersAction),
          onPressed: onReset,
        ),
    ];

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final chip in chips) ...[
              chip,
              if (chip != chips.last) SizedBox(width: tokens.space2),
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: tokens.space2,
      runSpacing: tokens.space2,
      children: chips,
    );
  }

  String _categoryLabel(BuildContext context) {
    return switch (filters.category) {
      SearchCategoryFilter.all => context.l10n.searchFilterCategory,
      SearchCategoryFilter.goods => context.l10n.searchFilterCategoryGoods,
      SearchCategoryFilter.precious =>
        context.l10n.searchFilterCategoryPrecious,
    };
  }

  String _priceLabel(BuildContext context) {
    return switch (filters.price) {
      SearchPriceFilter.all => context.l10n.searchFilterPrice,
      SearchPriceFilter.under50k => context.l10n.searchFilterPriceUnder50k,
      SearchPriceFilter.between50kAnd200k =>
        context.l10n.searchFilterPrice50kTo200k,
      SearchPriceFilter.over200k => context.l10n.searchFilterPriceOver200k,
    };
  }
}
