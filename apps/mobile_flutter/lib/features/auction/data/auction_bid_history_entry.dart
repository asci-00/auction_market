import 'package:cloud_firestore/cloud_firestore.dart';

import 'auction_detail_view_data.dart';

class AuctionBidHistoryEntry {
  const AuctionBidHistoryEntry({required this.amount, required this.createdAt});

  final num amount;
  final DateTime? createdAt;

  factory AuctionBidHistoryEntry.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return AuctionBidHistoryEntry.fromMap(document.data());
  }

  factory AuctionBidHistoryEntry.fromMap(Map<String, dynamic> data) {
    return AuctionBidHistoryEntry(
      amount: (data['amount'] as num?) ?? 0,
      createdAt: dateTimeFromPayload(data['createdAt']),
    );
  }
}
