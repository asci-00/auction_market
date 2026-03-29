import 'dart:async';

class Debouncer {
  Debouncer(this.duration);

  final Duration duration;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    cancel();
  }
}

class Throttler {
  Throttler(this.duration);

  final Duration duration;
  DateTime? _lastRunAt;

  bool shouldRun() {
    final now = DateTime.now();
    final last = _lastRunAt;
    if (last != null && now.difference(last) < duration) {
      return false;
    }
    _lastRunAt = now;
    return true;
  }
}
