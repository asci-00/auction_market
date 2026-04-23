import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../data/sell_draft_summary.dart';

part 'sell_view_model.g.dart';

@immutable
class SellViewState {
  const SellViewState({required this.recentDrafts});

  final List<SellDraftSummary> recentDrafts;

  SellViewState copyWith({List<SellDraftSummary>? recentDrafts}) {
    return SellViewState(recentDrafts: recentDrafts ?? this.recentDrafts);
  }
}

@riverpod
class SellViewModel extends _$SellViewModel {
  StreamSubscription<BackendRefreshEvent>? _refreshSub;

  @override
  Future<SellViewState> build(String userId) async {
    _listenForRefreshes();
    return _fetchState(userId);
  }

  Future<SellViewState> _fetchState(String userId) async {
    final authUserId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (authUserId != null && authUserId != userId) {
      return const SellViewState(recentDrafts: <SellDraftSummary>[]);
    }
    final drafts = await ref.read(backendReadApiProvider).fetchSellDrafts();
    return SellViewState(recentDrafts: drafts);
  }

  Future<void> _refreshState() async {
    try {
      state = AsyncData(await _fetchState(userId));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _listenForRefreshes() {
    _refreshSub ??= listenEvent<BackendRefreshEvent>(
      onEvent: (event) async {
        if (event.includes(BackendRefreshArea.sellDrafts)) {
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
