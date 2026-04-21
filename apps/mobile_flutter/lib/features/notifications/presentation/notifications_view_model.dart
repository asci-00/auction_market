import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/dev_read_api.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_providers.dart';
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
  StreamSubscription<List<NotificationItem>>? _sub;

  @override
  Future<NotificationsViewState> build(String userId) async {
    final config = ref.watch(appConfigProvider);
    if (config.usesHttpBackend) {
      final api = ref.watch(devReadApiProvider);
      final stream = api.poll(api.fetchNotifications);
      final first = await stream.first;

      ref.onDispose(() {
        unawaited(_sub?.cancel());
      });

      _sub = stream.listen((items) {
        final current =
            state.valueOrNull ?? NotificationsViewState(items: items);
        state = AsyncData(current.copyWith(items: items));
      }, onError: _handleStreamError);

      return NotificationsViewState(items: first);
    }

    final stream = _notificationsStream(ref, userId);
    final first = await stream.first;

    ref.onDispose(() {
      unawaited(_sub?.cancel());
    });

    _sub = stream.listen((items) {
      final current = state.valueOrNull ?? NotificationsViewState(items: items);
      state = AsyncData(current.copyWith(items: items));
    }, onError: _handleStreamError);

    return NotificationsViewState(items: first);
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    state = AsyncError(error, stackTrace);
  }
}

Stream<List<NotificationItem>> _notificationsStream(Ref ref, String userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('notifications')
      .doc(userId)
      .collection('inbox')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map(NotificationItem.fromDocument).toList(),
      );
}
