import 'package:cloud_firestore/cloud_firestore.dart';

class HomeAuctionSummary {
  const HomeAuctionSummary({
    required this.id,
    required this.title,
    required this.categoryMain,
    required this.currentPrice,
    required this.bidCount,
    required this.heroImageUrl,
    required this.buyNowPrice,
    required this.endAt,
  });

  final String id;
  final String title;
  final String categoryMain;
  final num currentPrice;
  final int bidCount;
  final String? heroImageUrl;
  final num? buyNowPrice;
  final DateTime? endAt;

  factory HomeAuctionSummary.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return HomeAuctionSummary.fromMap({'id': document.id, ...document.data()});
  }

  factory HomeAuctionSummary.fromMap(Map<String, dynamic> data) {
    return HomeAuctionSummary(
      id: data['id'] as String? ?? '',
      title: data['titleSnapshot'] as String? ?? '',
      categoryMain: data['categoryMain'] as String? ?? 'GOODS',
      currentPrice: data['currentPrice'] as num? ?? 0,
      bidCount: (data['bidCount'] as num?)?.toInt() ?? 0,
      heroImageUrl: data['heroImageUrl'] as String?,
      buyNowPrice: data['buyNowPrice'] as num?,
      endAt: _dateTimeFromPayload(data['endAt']),
    );
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
