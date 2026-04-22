import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../data/home_auction_summary.dart';

part 'home_view_model.g.dart';

@immutable
class HomeViewState {
  const HomeViewState({required this.endingSoon, required this.hot});

  final List<HomeAuctionSummary> endingSoon;
  final List<HomeAuctionSummary> hot;

  HomeViewState copyWith({
    List<HomeAuctionSummary>? endingSoon,
    List<HomeAuctionSummary>? hot,
  }) {
    return HomeViewState(
      endingSoon: endingSoon ?? this.endingSoon,
      hot: hot ?? this.hot,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  StreamSubscription<BackendRefreshEvent>? _refreshSub;

  @override
  Future<HomeViewState> build() async {
    _listenForRefreshes();
    return _fetchState();
  }

  Future<HomeViewState> _fetchState() async {
    final payload = await ref.read(backendReadApiProvider).fetchHome();
    return HomeViewState(endingSoon: payload.endingSoon, hot: payload.hot);
  }

  Future<void> _refreshState() async {
    try {
      state = AsyncData(await _fetchState());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _listenForRefreshes() {
    _refreshSub ??= listenEvent<BackendRefreshEvent>(
      onEvent: (event) async {
        if (event.includes(BackendRefreshArea.home)) {
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
