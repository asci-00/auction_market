import 'package:auction_market_mobile/features/home/application/home_curated_category_sections.dart';
import 'package:auction_market_mobile/features/home/data/home_auction_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  HomeAuctionSummary auction({
    required String id,
    required String categoryMain,
  }) {
    return HomeAuctionSummary(
      id: id,
      title: id,
      categoryMain: categoryMain,
      currentPrice: 1000,
      bidCount: 1,
      heroImageUrl: null,
      buyNowPrice: null,
      endAt: null,
    );
  }

  test('builds goods and precious rows from hot and ending-soon lists', () {
    final sections = buildHomeCuratedCategorySections(
      endingSoon: [
        auction(id: 'goods-2', categoryMain: 'GOODS'),
        auction(id: 'precious-2', categoryMain: 'PRECIOUS'),
      ],
      hot: [
        auction(id: 'goods-1', categoryMain: 'GOODS'),
        auction(id: 'precious-1', categoryMain: 'PRECIOUS'),
      ],
    );

    expect(sections.goods.map((item) => item.id), ['goods-1', 'goods-2']);
    expect(sections.precious.map((item) => item.id), [
      'precious-1',
      'precious-2',
    ]);
  });

  test('keeps unique ids when the same auction appears in both feeds', () {
    final shared = auction(id: 'shared-goods', categoryMain: 'GOODS');

    final sections = buildHomeCuratedCategorySections(
      endingSoon: [shared],
      hot: [shared],
    );

    expect(sections.goods, hasLength(1));
    expect(sections.goods.single.id, 'shared-goods');
  });

  test('limits each curated category to six auctions', () {
    final sections = buildHomeCuratedCategorySections(
      endingSoon: List.generate(
        10,
        (index) => auction(id: 'goods-$index', categoryMain: 'GOODS'),
      ),
      hot: const [],
    );

    expect(sections.goods, hasLength(6));
  });

  test('returns empty category sections when inputs are empty', () {
    final sections = buildHomeCuratedCategorySections(
      endingSoon: const [],
      hot: const [],
    );

    expect(sections.goods, isEmpty);
    expect(sections.precious, isEmpty);
  });
}
