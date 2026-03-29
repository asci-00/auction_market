import 'dart:async';

import 'package:event_bus/event_bus.dart';

import 'app_events.dart';

final EventBus _appEventBus = EventBus();

void sendToEventBus<T extends AppEvent>(T event) {
  _appEventBus.fire(event);
}

StreamSubscription<T> listenEvent<T extends AppEvent>({
  required FutureOr<void> Function(T event) onEvent,
  void Function(Object error, StackTrace stackTrace)? onError,
  bool cancelOnError = false,
}) {
  late final StreamSubscription<T> subscription;

  Future<void> handleError(Object error, StackTrace stackTrace) async {
    if (onError != null) {
      onError(error, stackTrace);
    } else {
      Zone.current.handleUncaughtError(error, stackTrace);
    }

    if (cancelOnError) {
      await subscription.cancel();
    }
  }

  subscription = _appEventBus.on<T>().listen(
    (event) {
      try {
        final result = onEvent(event);
        if (result is Future<void>) {
          unawaited(result.catchError(handleError));
        }
      } catch (error, stackTrace) {
        unawaited(handleError(error, stackTrace));
      }
    },
    onError: (Object error, StackTrace stackTrace) {
      if (onError != null) {
        onError(error, stackTrace);
      } else {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
    },
    cancelOnError: cancelOnError,
  );

  return subscription;
}

Stream<T> watchEvent<T extends AppEvent>() {
  return _appEventBus.on<T>();
}
