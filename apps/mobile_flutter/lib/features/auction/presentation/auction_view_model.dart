import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
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
  StreamSubscription<BackendRefreshEvent>? _refreshSub;
  StreamSubscription<AuctionDetailHttpSnapshot>? _pollSub;

  @override
  Future<AuctionViewState> build(String auctionId) async {
    _listenForRefreshes();
    _listenForPassiveRefreshes();
    return _fetchState(auctionId);
  }

  Future<AuctionViewState> _fetchState(String auctionId) async {
    final snapshot = await ref
        .read(backendReadApiProvider)
        .fetchAuctionDetail(auctionId);
    return AuctionViewState(
      detail: snapshot.detail,
      bidHistory: snapshot.bidHistory,
    );
  }

  Future<void> _refreshState() async {
    try {
      state = AsyncData(await _fetchState(auctionId));
    } catch (error, stackTrace) {
      if (state.valueOrNull != null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'auction_view_model',
            context: ErrorDescription('while refreshing auction detail event'),
          ),
        );
        return;
      }
      state = AsyncError(error, stackTrace);
    }
  }

  void _listenForRefreshes() {
    _refreshSub ??= listenEvent<BackendRefreshEvent>(
      onEvent: (event) async {
        if (event.matchesAuction(auctionId)) {
          await _refreshState();
        }
      },
    );
    ref.onDispose(() {
      unawaited(_refreshSub?.cancel());
      _refreshSub = null;
    });
  }

  void _listenForPassiveRefreshes() {
    if (_pollSub != null) {
      return;
    }

    final api = ref.read(backendReadApiProvider);
    final stream = api.poll(() => api.fetchAuctionDetail(auctionId));
    _pollSub = stream.listen(
      (snapshot) {
        state = AsyncData(
          AuctionViewState(
            detail: snapshot.detail,
            bidHistory: snapshot.bidHistory,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (state.valueOrNull != null) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'auction_view_model',
              context: ErrorDescription('while passive polling auction detail'),
            ),
          );
          return;
        }
        state = AsyncError(error, stackTrace);
      },
    );

    ref.onDispose(() {
      unawaited(_pollSub?.cancel());
      _pollSub = null;
    });
  }
}
