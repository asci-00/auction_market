import 'package:cloud_firestore/cloud_firestore.dart';

class SearchAuctionSummary {
  const SearchAuctionSummary({
    required this.id,
    required this.title,
    required this.categorySub,
    required this.currentPrice,
    required this.bidCount,
    required this.heroImageUrl,
    required this.buyNowPrice,
    required this.endAt,
  });

  final String id;
  final String title;
  final String categorySub;
  final num currentPrice;
  final int bidCount;
  final String? heroImageUrl;
  final num? buyNowPrice;
  final DateTime? endAt;

  factory SearchAuctionSummary.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    return SearchAuctionSummary(
      id: document.id,
      title: (data['titleSnapshot'] as String?) ?? '',
      categorySub: (data['categorySub'] as String?) ?? '',
      currentPrice: (data['currentPrice'] as num?) ?? 0,
      bidCount: ((data['bidCount'] as num?) ?? 0).toInt(),
      heroImageUrl: data['heroImageUrl'] as String?,
      buyNowPrice: data['buyNowPrice'] as num?,
      endAt: (data['endAt'] as Timestamp?)?.toDate(),
    );
  }

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    return title.toLowerCase().contains(normalizedQuery) ||
        categorySub.toLowerCase().contains(normalizedQuery);
  }
}
