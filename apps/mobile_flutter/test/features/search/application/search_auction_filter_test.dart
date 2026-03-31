import 'package:auction_market_mobile/features/search/application/search_auction_filter.dart';
import 'package:auction_market_mobile/features/search/data/search_auction_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final auctions = <SearchAuctionSummary>[
    SearchAuctionSummary(
      id: 'goods-ending-soon',
      title: 'Limited photocard set',
      categoryMain: 'GOODS',
      categorySub: 'PHOTO_CARD',
      currentPrice: 32000,
      bidCount: 4,
      heroImageUrl: null,
      buyNowPrice: 45000,
      endAt: DateTime.now().add(const Duration(hours: 4)),
    ),
    SearchAuctionSummary(
      id: 'precious-open',
      title: 'Gold ring lot',
      categoryMain: 'PRECIOUS',
      categorySub: 'JEWELRY',
      currentPrice: 240000,
      bidCount: 2,
      heroImageUrl: null,
      buyNowPrice: null,
      endAt: DateTime.now().add(const Duration(hours: 48)),
    ),
  ];

  test('filters by query and selected chips together', () {
    const filters = SearchFilterState(
      category: SearchCategoryFilter.goods,
      buyNowOnly: true,
      endingSoonOnly: true,
    );

    final results = filterSearchAuctions(
      auctions,
      query: 'photo',
      filters: filters,
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'goods-ending-soon');
  });

  test('price cycling helper loops back to all after final band', () {
    expect(
      nextSearchPriceFilter(SearchPriceFilter.all),
      SearchPriceFilter.under50k,
    );
    expect(
      nextSearchPriceFilter(SearchPriceFilter.under50k),
      SearchPriceFilter.between50kAnd200k,
    );
    expect(
      nextSearchPriceFilter(SearchPriceFilter.between50kAnd200k),
      SearchPriceFilter.over200k,
    );
    expect(
      nextSearchPriceFilter(SearchPriceFilter.over200k),
      SearchPriceFilter.all,
    );
  });

  test('category parser maps supported query values and defaults to all', () {
    expect(parseSearchCategoryFilter('goods'), SearchCategoryFilter.goods);
    expect(
      parseSearchCategoryFilter('precious'),
      SearchCategoryFilter.precious,
    );
    expect(parseSearchCategoryFilter('unknown'), SearchCategoryFilter.all);
    expect(parseSearchCategoryFilter(null), SearchCategoryFilter.all);
  });

  test('selection-only filtering keeps query result set stable', () {
    const filters = SearchFilterState(price: SearchPriceFilter.over200k);

    final results = applySearchSelectionFilters(auctions, filters);

    expect(results, hasLength(1));
    expect(results.single.id, 'precious-open');
  });
}
