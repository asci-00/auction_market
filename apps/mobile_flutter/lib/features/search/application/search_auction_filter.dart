import 'package:flutter/foundation.dart';

import '../data/search_auction_summary.dart';

enum SearchCategoryFilter { all, goods, precious }

enum SearchPriceFilter { all, under50k, between50kAnd200k, over200k }

@immutable
class SearchFilterState {
  const SearchFilterState({
    this.category = SearchCategoryFilter.all,
    this.price = SearchPriceFilter.all,
    this.endingSoonOnly = false,
    this.buyNowOnly = false,
  });

  final SearchCategoryFilter category;
  final SearchPriceFilter price;
  final bool endingSoonOnly;
  final bool buyNowOnly;

  bool get hasActiveSelection =>
      category != SearchCategoryFilter.all ||
      price != SearchPriceFilter.all ||
      endingSoonOnly ||
      buyNowOnly;

  SearchFilterState copyWith({
    SearchCategoryFilter? category,
    SearchPriceFilter? price,
    bool? endingSoonOnly,
    bool? buyNowOnly,
  }) {
    return SearchFilterState(
      category: category ?? this.category,
      price: price ?? this.price,
      endingSoonOnly: endingSoonOnly ?? this.endingSoonOnly,
      buyNowOnly: buyNowOnly ?? this.buyNowOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SearchFilterState &&
        other.category == category &&
        other.price == price &&
        other.endingSoonOnly == endingSoonOnly &&
        other.buyNowOnly == buyNowOnly;
  }

  @override
  int get hashCode => Object.hash(category, price, endingSoonOnly, buyNowOnly);
}

List<SearchAuctionSummary> filterSearchAuctions(
  Iterable<SearchAuctionSummary> auctions, {
  required String query,
  SearchFilterState filters = const SearchFilterState(),
}) {
  return auctions
      .where((auction) => auction.matchesQuery(query))
      .where((auction) => _matchesFilters(auction, filters))
      .toList();
}

List<SearchAuctionSummary> applySearchSelectionFilters(
  Iterable<SearchAuctionSummary> auctions,
  SearchFilterState filters,
) {
  return auctions
      .where((auction) => _matchesFilters(auction, filters))
      .toList();
}

SearchCategoryFilter nextSearchCategoryFilter(SearchCategoryFilter current) {
  return switch (current) {
    SearchCategoryFilter.all => SearchCategoryFilter.goods,
    SearchCategoryFilter.goods => SearchCategoryFilter.precious,
    SearchCategoryFilter.precious => SearchCategoryFilter.all,
  };
}

SearchCategoryFilter parseSearchCategoryFilter(String? value) {
  return switch (value) {
    'goods' => SearchCategoryFilter.goods,
    'precious' => SearchCategoryFilter.precious,
    _ => SearchCategoryFilter.all,
  };
}

SearchPriceFilter nextSearchPriceFilter(SearchPriceFilter current) {
  return switch (current) {
    SearchPriceFilter.all => SearchPriceFilter.under50k,
    SearchPriceFilter.under50k => SearchPriceFilter.between50kAnd200k,
    SearchPriceFilter.between50kAnd200k => SearchPriceFilter.over200k,
    SearchPriceFilter.over200k => SearchPriceFilter.all,
  };
}

bool _matchesFilters(SearchAuctionSummary auction, SearchFilterState filters) {
  if (!_matchesCategory(auction, filters.category)) {
    return false;
  }
  if (!_matchesPrice(auction, filters.price)) {
    return false;
  }
  if (filters.buyNowOnly && auction.buyNowPrice == null) {
    return false;
  }
  if (filters.endingSoonOnly && !_isEndingSoon(auction.endAt)) {
    return false;
  }
  return true;
}

bool _matchesCategory(
  SearchAuctionSummary auction,
  SearchCategoryFilter filter,
) {
  return switch (filter) {
    SearchCategoryFilter.all => true,
    SearchCategoryFilter.goods => auction.categoryMain == 'GOODS',
    SearchCategoryFilter.precious => auction.categoryMain == 'PRECIOUS',
  };
}

bool _matchesPrice(SearchAuctionSummary auction, SearchPriceFilter filter) {
  final price = auction.currentPrice;
  return switch (filter) {
    SearchPriceFilter.all => true,
    SearchPriceFilter.under50k => price < 50000,
    SearchPriceFilter.between50kAnd200k => price >= 50000 && price <= 200000,
    SearchPriceFilter.over200k => price > 200000,
  };
}

bool _isEndingSoon(DateTime? endAt) {
  if (endAt == null) {
    return false;
  }

  final now = DateTime.now();
  return endAt.isAfter(now) &&
      endAt.isBefore(now.add(const Duration(hours: 24)));
}
