import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../data/auction_bid_history_entry.dart';
import '../data/auction_detail_http_data_source.dart';
import '../data/auction_detail_stream.dart';
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
  StreamSubscription<AuctionViewState>? _httpPollSub;

  static const _httpPollInterval = Duration(seconds: 4);

  @override
  Future<AuctionViewState> build(String auctionId) async {
    final config = ref.watch(appConfigProvider);
    if (config.usesHttpBackend) {
      final dataSource = AuctionDetailHttpDataSource(
        baseUri: Uri.parse(config.apiBaseUrl!),
      );
      ref.onDispose(dataSource.close);
      final initial = await dataSource.fetchDetail(auctionId);
      _httpPollSub = Stream<void>.periodic(_httpPollInterval)
          .asyncMap((_) => dataSource.fetchDetail(auctionId))
          .map(
            (snapshot) => AuctionViewState(
              detail: snapshot.detail,
              bidHistory: snapshot.bidHistory,
            ),
          )
          .listen(
            (value) => state = AsyncData(value),
            onError: (Object error, StackTrace stackTrace) {
              if (state.valueOrNull != null) {
                FlutterError.reportError(
                  FlutterErrorDetails(
                    exception: error,
                    stack: stackTrace,
                    library: 'auction_view_model',
                    context: ErrorDescription(
                      'while polling HTTP auction detail',
                    ),
                  ),
                );
                return;
              }
              state = AsyncError(error, stackTrace);
            },
          );
      ref.onDispose(() {
        unawaited(_httpPollSub?.cancel());
      });
      return AuctionViewState(
        detail: initial.detail,
        bidHistory: initial.bidHistory,
      );
    }

    final detailStream = _auctionDetailStream(ref, auctionId);
    final historyStream = _auctionBidHistoryStream(ref, auctionId);

    final initial = await Future.wait<dynamic>([
      detailStream.first,
      historyStream.first,
    ]);
    final detail = initial[0] as AuctionDetailViewData?;
    final history = initial[1] as List<AuctionBidHistoryEntry>;

    ref.onDispose(() {
      unawaited(_detailSub?.cancel());
      unawaited(_historySub?.cancel());
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

  return bindAuctionDetailStreams(
    auctionStream: auctions
        .doc(auctionId)
        .snapshots()
        .map(
          (snapshot) => AuctionDetailDocument(
            id: snapshot.id,
            exists: snapshot.exists,
            data: snapshot.data() ?? const <String, dynamic>{},
          ),
        ),
    itemStreamFor: (itemId) => items
        .doc(itemId)
        .snapshots()
        .map(
          (snapshot) => AuctionItemDocument(
            exists: snapshot.exists,
            data: snapshot.data() ?? const <String, dynamic>{},
          ),
        ),
  );
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
