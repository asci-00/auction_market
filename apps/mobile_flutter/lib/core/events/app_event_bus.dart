import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appEventBusProvider = Provider<EventBus>((ref) {
  final bus = EventBus();
  ref.onDispose(bus.destroy);
  return bus;
});

void sendToEventBus<T extends Object>(Ref ref, T event) {
  ref.read(appEventBusProvider).fire(event);
}

StreamSubscription<T> listenEvent<T extends Object>(
  Ref ref, {
  required FutureOr<void> Function(T event) onEvent,
  void Function(Object error, StackTrace stackTrace)? onError,
  bool cancelOnError = false,
}) {
  final subscription = ref.read(appEventBusProvider).on<T>().listen(
    (event) {
      Future.sync(() => onEvent(event)).catchError((Object error, StackTrace st) {
        onError?.call(error, st);
      });
    },
    onError: (Object error, StackTrace stackTrace) {
      onError?.call(error, stackTrace);
    },
    cancelOnError: cancelOnError,
  );

  ref.onDispose(subscription.cancel);
  return subscription;
}

Stream<T> watchEvent<T extends Object>(Ref ref) {
  return ref.read(appEventBusProvider).on<T>();
}
