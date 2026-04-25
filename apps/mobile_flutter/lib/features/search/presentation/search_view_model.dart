import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
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
  StreamSubscription<BackendRefreshEvent>? _refreshSub;

  @override
  Future<SearchViewState> build(String query) async {
    _listenForRefreshes();
    return _fetchState(query);
  }

  Future<SearchViewState> _fetchState(String query) async {
    final auctions = await ref
        .read(backendReadApiProvider)
        .fetchSearchAuctions();
    return SearchViewState(
      results: filterSearchAuctions(auctions, query: query),
    );
  }

  Future<void> _refreshState() async {
    try {
      state = AsyncData(await _fetchState(query));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _listenForRefreshes() {
    _refreshSub ??= listenEvent<BackendRefreshEvent>(
      onEvent: (event) async {
        if (event.includes(BackendRefreshArea.search)) {
          await _refreshState();
        }
      },
    );
    ref.onDispose(() {
      unawaited(_refreshSub?.cancel());
      _refreshSub = null;
    });
  }
}
