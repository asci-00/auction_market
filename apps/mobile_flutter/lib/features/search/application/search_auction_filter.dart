import '../data/search_auction_summary.dart';

List<SearchAuctionSummary> filterSearchAuctions(
  Iterable<SearchAuctionSummary> auctions,
  String query,
) {
  return auctions.where((auction) => auction.matchesQuery(query)).toList();
}
