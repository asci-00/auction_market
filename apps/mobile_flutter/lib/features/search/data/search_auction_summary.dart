import 'package:cloud_firestore/cloud_firestore.dart';

class SearchAuctionSummary {
  const SearchAuctionSummary({
    required this.id,
    required this.title,
    required this.categoryMain,
    required this.categorySub,
    required this.currentPrice,
    required this.bidCount,
    required this.heroImageUrl,
    required this.buyNowPrice,
    required this.endAt,
  });

  final String id;
  final String title;
  final String categoryMain;
  final String categorySub;
  final num currentPrice;
  final int bidCount;
  final String? heroImageUrl;
  final num? buyNowPrice;
  final DateTime? endAt;

  factory SearchAuctionSummary.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return SearchAuctionSummary.fromMap({
      'id': document.id,
      ...document.data(),
    });
  }

  factory SearchAuctionSummary.fromMap(Map<String, dynamic> data) {
    return SearchAuctionSummary(
      id: data['id'] as String? ?? '',
      title: (data['titleSnapshot'] as String?) ?? '',
      categoryMain: (data['categoryMain'] as String?) ?? 'GOODS',
      categorySub: (data['categorySub'] as String?) ?? '',
      currentPrice: (data['currentPrice'] as num?) ?? 0,
      bidCount: ((data['bidCount'] as num?) ?? 0).toInt(),
      heroImageUrl: data['heroImageUrl'] as String?,
      buyNowPrice: data['buyNowPrice'] as num?,
      endAt: _dateTimeFromPayload(data['endAt']),
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

DateTime? _dateTimeFromPayload(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  return null;
}
