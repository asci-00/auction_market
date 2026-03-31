import 'package:cloud_firestore/cloud_firestore.dart';

class AuctionBidHistoryEntry {
  const AuctionBidHistoryEntry({required this.amount, required this.createdAt});

  final num amount;
  final DateTime? createdAt;

  factory AuctionBidHistoryEntry.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return AuctionBidHistoryEntry(
      amount: (data['amount'] as num?) ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
