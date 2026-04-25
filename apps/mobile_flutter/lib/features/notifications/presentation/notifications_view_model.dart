import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../data/notification_item.dart';

part 'notifications_view_model.g.dart';

@immutable
class NotificationsViewState {
  const NotificationsViewState({required this.items});

  final List<NotificationItem> items;

  NotificationsViewState copyWith({List<NotificationItem>? items}) {
    return NotificationsViewState(items: items ?? this.items);
  }
}

@riverpod
class NotificationsViewModel extends _$NotificationsViewModel {
  StreamSubscription<BackendRefreshEvent>? _refreshSub;

  @override
  Future<NotificationsViewState> build(String userId) async {
    _listenForRefreshes();
    return _fetchState();
  }

  Future<NotificationsViewState> _fetchState() async {
    final items = await ref.read(backendReadApiProvider).fetchNotifications();
    return NotificationsViewState(items: items);
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
        if (event.includes(BackendRefreshArea.notifications)) {
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
