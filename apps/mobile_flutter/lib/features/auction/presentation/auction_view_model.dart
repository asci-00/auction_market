import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/auction_bid_history_entry.dart';
import '../data/auction_detail_view_data.dart';

part 'auction_view_model.g.dart';

@immutable
class AuctionViewState {
  const AuctionViewState({required this.detail, required this.bidHistory});

  static const _detailSentinel = Object();

  final AuctionDetailViewData? detail;
  final List<AuctionBidHistoryEntry> bidHistory;

  AuctionViewState copyWith({
    Object? detail = _detailSentinel,
    List<AuctionBidHistoryEntry>? bidHistory,
  }) {
    return AuctionViewState(
      detail: detail == _detailSentinel
          ? this.detail
          : detail as AuctionDetailViewData?,
      bidHistory: bidHistory ?? this.bidHistory,
    );
  }
}

@riverpod
class AuctionViewModel extends _$AuctionViewModel {
  StreamSubscription<AuctionDetailViewData?>? _detailSub;
  StreamSubscription<List<AuctionBidHistoryEntry>>? _historySub;

  @override
  Future<AuctionViewState> build(String auctionId) async {
    final detailStream = _auctionDetailStream(ref, auctionId);
    final historyStream = _auctionBidHistoryStream(ref, auctionId);

    final detail = await detailStream.first;
    final history = await historyStream.first;

    ref.onDispose(() {
      _detailSub?.cancel();
      _historySub?.cancel();
    });

    _detailSub = detailStream.listen((value) {
      final current =
          state.valueOrNull ??
          AuctionViewState(detail: value, bidHistory: history);
      state = AsyncData(current.copyWith(detail: value));
    });

    _historySub = historyStream.listen((value) {
      final current =
          state.valueOrNull ??
          AuctionViewState(detail: detail, bidHistory: value);
      state = AsyncData(current.copyWith(bidHistory: value));
    });

    return AuctionViewState(detail: detail, bidHistory: history);
  }
}

Stream<AuctionDetailViewData?> _auctionDetailStream(Ref ref, String auctionId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('auctions').doc(auctionId).snapshots().map((
    snapshot,
  ) {
    if (!snapshot.exists) {
      return null;
    }
    return AuctionDetailViewData.fromDocument(snapshot);
  });
}

Stream<List<AuctionBidHistoryEntry>> _auctionBidHistoryStream(
  Ref ref,
  String auctionId,
) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('auctions')
      .doc(auctionId)
      .collection('bids')
      .orderBy('createdAt')
      .limitToLast(6)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(AuctionBidHistoryEntry.fromDocument).toList(),
      );
}
