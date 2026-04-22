import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../data/activity_hub_summary.dart';

part 'activity_view_model.g.dart';

@immutable
class ActivityViewState {
  const ActivityViewState({
    required this.buyerSummary,
    required this.sellerSummary,
    required this.notificationsSummary,
  });

  final ActivityHubSummary buyerSummary;
  final ActivityHubSummary sellerSummary;
  final ActivityHubSummary notificationsSummary;

  ActivityViewState copyWith({
    ActivityHubSummary? buyerSummary,
    ActivityHubSummary? sellerSummary,
    ActivityHubSummary? notificationsSummary,
  }) {
    return ActivityViewState(
      buyerSummary: buyerSummary ?? this.buyerSummary,
      sellerSummary: sellerSummary ?? this.sellerSummary,
      notificationsSummary: notificationsSummary ?? this.notificationsSummary,
    );
  }
}

@riverpod
class ActivityViewModel extends _$ActivityViewModel {
  StreamSubscription<BackendRefreshEvent>? _refreshSub;

  @override
  Future<ActivityViewState> build(String userId) async {
    _listenForRefreshes();
    return _fetchState();
  }

  Future<ActivityViewState> _fetchState() async {
    final payload = await ref.read(backendReadApiProvider).fetchActivity();
    return ActivityViewState(
      buyerSummary: payload.buyerSummary,
      sellerSummary: payload.sellerSummary,
      notificationsSummary: payload.notificationsSummary,
    );
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
        if (event.includes(BackendRefreshArea.activity)) {
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
