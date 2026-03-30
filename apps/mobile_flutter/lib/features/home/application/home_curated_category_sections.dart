import '../data/home_auction_summary.dart';

class HomeCuratedCategorySections {
  const HomeCuratedCategorySections({
    required this.goods,
    required this.precious,
  });

  final List<HomeAuctionSummary> goods;
  final List<HomeAuctionSummary> precious;
}

HomeCuratedCategorySections buildHomeCuratedCategorySections({
  required Iterable<HomeAuctionSummary> endingSoon,
  required Iterable<HomeAuctionSummary> hot,
}) {
  final combined = <String, HomeAuctionSummary>{};

  for (final auction in hot) {
    combined[auction.id] = auction;
  }
  for (final auction in endingSoon) {
    combined.putIfAbsent(auction.id, () => auction);
  }

  final curated = combined.values.toList(growable: false);

  return HomeCuratedCategorySections(
    goods: curated
        .where((auction) => auction.categoryMain == 'GOODS')
        .take(6)
        .toList(growable: false),
    precious: curated
        .where((auction) => auction.categoryMain == 'PRECIOUS')
        .take(6)
        .toList(growable: false),
  );
}
