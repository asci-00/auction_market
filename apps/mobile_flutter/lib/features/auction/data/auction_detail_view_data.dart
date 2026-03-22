import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionDetailViewData {
  const AuctionDetailViewData({
    required this.id,
    required this.titleSnapshot,
    required this.heroImageUrl,
    required this.sellerId,
    required this.status,
    required this.currentPrice,
    required this.buyNowPrice,
    required this.orderId,
    required this.endAt,
  });

  final String id;
  final String titleSnapshot;
  final String? heroImageUrl;
  final String? sellerId;
  final String status;
  final num currentPrice;
  final num? buyNowPrice;
  final String? orderId;
  final DateTime? endAt;

  factory AuctionDetailViewData.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};

    return AuctionDetailViewData(
      id: document.id,
      titleSnapshot:
          (data['titleSnapshot'] as String?)?.trim().isNotEmpty == true
              ? data['titleSnapshot'] as String
              : '',
      heroImageUrl: data['heroImageUrl'] as String?,
      sellerId: data['sellerId'] as String?,
      status: (data['status'] as String?) ?? 'DRAFT',
      currentPrice: (data['currentPrice'] as num?) ?? 0,
      buyNowPrice: data['buyNowPrice'] as num?,
      orderId: data['orderId'] as String?,
      endAt: (data['endAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isLive => status == 'LIVE';
  bool get hasOrder => orderId != null && orderId!.isNotEmpty;
  bool get hasBuyNow => buyNowPrice != null;
  int get minimumBid => (currentPrice + _minIncrementFor(currentPrice)).toInt();
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
