import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/dev_read_api.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../application/search_auction_filter.dart';
import '../data/search_auction_summary.dart';

part 'search_view_model.g.dart';

@immutable
class SearchViewState {
  const SearchViewState({required this.results});

  final List<SearchAuctionSummary> results;

  SearchViewState copyWith({List<SearchAuctionSummary>? results}) {
    return SearchViewState(results: results ?? this.results);
  }
}

@riverpod
class SearchViewModel extends _$SearchViewModel {
  StreamSubscription<List<SearchAuctionSummary>>? _sub;

  @override
  Future<SearchViewState> build(String query) async {
    final config = ref.watch(appConfigProvider);
    if (config.usesHttpBackend) {
      final api = ref.watch(devReadApiProvider);
      final stream = api.poll(api.fetchSearchAuctions);
      final first = await stream.first;
      final initial = filterSearchAuctions(first, query: query);

      ref.onDispose(() {
        unawaited(_sub?.cancel());
      });

      _sub = stream.listen((auctions) {
        final filtered = filterSearchAuctions(auctions, query: query);
        final current = state.valueOrNull ?? SearchViewState(results: filtered);
        state = AsyncData(current.copyWith(results: filtered));
      }, onError: _handleStreamError);

      return SearchViewState(results: initial);
    }

    final stream = _searchAuctionsStream(ref);
    final first = await stream.first;
    final initial = filterSearchAuctions(first, query: query);

    ref.onDispose(() {
      unawaited(_sub?.cancel());
    });

    _sub = stream.listen((auctions) {
      final filtered = filterSearchAuctions(auctions, query: query);
      final current = state.valueOrNull ?? SearchViewState(results: filtered);
      state = AsyncData(current.copyWith(results: filtered));
    }, onError: _handleStreamError);

    return SearchViewState(results: initial);
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    state = AsyncError(error, stackTrace);
  }
}

Stream<List<SearchAuctionSummary>> _searchAuctionsStream(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('auctions')
      .where('status', isEqualTo: 'LIVE')
      .orderBy('endAt')
      .limit(24)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map(SearchAuctionSummary.fromDocument).toList(),
      );
}
