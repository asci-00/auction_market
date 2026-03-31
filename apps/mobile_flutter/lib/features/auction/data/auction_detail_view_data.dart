import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionDetailViewData {
  const AuctionDetailViewData({
    required this.id,
    required this.itemId,
    required this.titleSnapshot,
    required this.heroImageUrl,
    required this.imageUrls,
    required this.description,
    required this.categorySub,
    required this.condition,
    required this.sellerId,
    required this.status,
    required this.currentPrice,
    required this.buyNowPrice,
    required this.orderId,
    required this.endAt,
  });

  final String id;
  final String itemId;
  final String titleSnapshot;
  final String? heroImageUrl;
  final List<String> imageUrls;
  final String description;
  final String categorySub;
  final String condition;
  final String? sellerId;
  final String status;
  final num currentPrice;
  final num? buyNowPrice;
  final String? orderId;
  final DateTime? endAt;

  factory AuctionDetailViewData.fromDocuments({
    required DocumentSnapshot<Map<String, dynamic>> auctionDocument,
    DocumentSnapshot<Map<String, dynamic>>? itemDocument,
  }) {
    return AuctionDetailViewData.fromMaps(
      auctionId: auctionDocument.id,
      auctionData: auctionDocument.data() ?? const <String, dynamic>{},
      itemData: itemDocument?.data(),
    );
  }

  factory AuctionDetailViewData.fromMaps({
    required String auctionId,
    required Map<String, dynamic> auctionData,
    Map<String, dynamic>? itemData,
  }) {
    final itemPayload = itemData ?? const <String, dynamic>{};
    final heroImageUrl = auctionData['heroImageUrl'] as String?;
    final galleryImages = {
      if (heroImageUrl != null && heroImageUrl.trim().isNotEmpty) heroImageUrl,
      ..._stringList(itemPayload['imageUrls']),
    }.toList(growable: false);

    return AuctionDetailViewData(
      id: auctionId,
      itemId: (auctionData['itemId'] as String?) ?? '',
      titleSnapshot:
          (auctionData['titleSnapshot'] as String?)?.trim().isNotEmpty == true
          ? auctionData['titleSnapshot'] as String
          : '',
      heroImageUrl: heroImageUrl,
      imageUrls: galleryImages,
      description: (itemPayload['description'] as String?)?.trim() ?? '',
      categorySub:
          (itemPayload['categorySub'] as String?) ??
          (auctionData['categorySub'] as String?) ??
          '',
      condition: (itemPayload['condition'] as String?) ?? '',
      sellerId: auctionData['sellerId'] as String?,
      status: (auctionData['status'] as String?) ?? 'DRAFT',
      currentPrice: (auctionData['currentPrice'] as num?) ?? 0,
      buyNowPrice: auctionData['buyNowPrice'] as num?,
      orderId: auctionData['orderId'] as String?,
      endAt: (auctionData['endAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isLive => status == 'LIVE';
  bool get hasOrder => orderId != null && orderId!.isNotEmpty;
  bool get hasBuyNow => buyNowPrice != null;
  int get minimumBid => (currentPrice + _minIncrementFor(currentPrice)).toInt();
}

List<String> _stringList(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }

  return value
      .whereType<String>()
      .map((entry) => entry.trim())
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
}

int _minIncrementFor(num currentPrice) {
  if (currentPrice <= 99999) {
    return 1000;
  }
  if (currentPrice <= 499999) {
    return 5000;
  }
  if (currentPrice <= 999999) {
    return 10000;
  }
  return 50000;
}
