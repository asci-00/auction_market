import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  final AuctionDetailViewData? detail;
  final List<AuctionBidHistoryEntry> bidHistory;

  AuctionViewState copyWith({
    AuctionDetailViewData? detail,
    List<AuctionBidHistoryEntry>? bidHistory,
  }) {
    return AuctionViewState(
      detail: detail ?? this.detail,
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

    final initial = await Future.wait<dynamic>([
      detailStream.first,
      historyStream.first,
    ]);
    final detail = initial[0] as AuctionDetailViewData?;
    final history = initial[1] as List<AuctionBidHistoryEntry>;

    ref.onDispose(() {
      _detailSub?.cancel();
      _historySub?.cancel();
    });

    _detailSub = detailStream.listen(
      (value) {
        final current =
            state.valueOrNull ??
            AuctionViewState(detail: value, bidHistory: history);
        final nextState = value == null
            ? AuctionViewState(detail: null, bidHistory: current.bidHistory)
            : current.copyWith(detail: value);
        state = AsyncData(nextState);
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );

    _historySub = historyStream.listen(
      (value) {
        final current =
            state.valueOrNull ??
            AuctionViewState(detail: detail, bidHistory: value);
        state = AsyncData(current.copyWith(bidHistory: value));
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );

    return AuctionViewState(detail: detail, bidHistory: history);
  }
}

Stream<AuctionDetailViewData?> _auctionDetailStream(Ref ref, String auctionId) {
  final firestore = ref.watch(firestoreProvider);
  final auctions = firestore.collection('auctions');
  final items = firestore.collection('items');

  return Stream<AuctionDetailViewData?>.multi((controller) {
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? itemSub;
    DocumentSnapshot<Map<String, dynamic>>? latestAuction;
    DocumentSnapshot<Map<String, dynamic>>? latestItem;
    String? currentItemId;

    void emitCombined() {
      final auctionSnapshot = latestAuction;
      if (auctionSnapshot == null || !auctionSnapshot.exists) {
        controller.add(null);
        return;
      }

      controller.add(
        AuctionDetailViewData.fromDocuments(
          auctionDocument: auctionSnapshot,
          itemDocument: latestItem?.exists == true ? latestItem : null,
        ),
      );
    }

    final auctionSub = auctions.doc(auctionId).snapshots().listen((
      auctionSnapshot,
    ) {
      latestAuction = auctionSnapshot;
      if (!auctionSnapshot.exists) {
        currentItemId = null;
        latestItem = null;
        itemSub?.cancel();
        itemSub = null;
        controller.add(null);
        return;
      }

      final auctionData = auctionSnapshot.data() ?? const <String, dynamic>{};
      final nextItemId = (auctionData['itemId'] as String?)?.trim() ?? '';

      if (nextItemId.isEmpty) {
        currentItemId = null;
        latestItem = null;
        itemSub?.cancel();
        itemSub = null;
        emitCombined();
        return;
      }

      if (currentItemId != nextItemId) {
        currentItemId = nextItemId;
        latestItem = null;
        itemSub?.cancel();
        itemSub = items.doc(nextItemId).snapshots().listen((itemSnapshot) {
          latestItem = itemSnapshot;
          emitCombined();
        }, onError: controller.addError);
      }

      emitCombined();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await auctionSub.cancel();
      await itemSub?.cancel();
    };
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
