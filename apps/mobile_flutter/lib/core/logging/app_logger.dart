import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

import '../app_config/app_config.dart';
import '../firebase/firebase_bootstrap.dart';

enum AppLogDomain {
  app,
  auth,
  auction,
  sell,
  orders,
  payment,
  notifications,
  settings,
  network,
}

final appLoggerProvider = Provider<AppLogger>((ref) {
  return AppLogger.fromConfig(ref.watch(appConfigProvider));
});

class AppLogger {
  AppLogger._(this._logger);

  factory AppLogger.fromConfig(AppConfig config) {
    final policy = AppLoggerPolicy.fromConfig(
      config,
      isReleaseMode: kReleaseMode,
    );
    return AppLogger._(
      Logger(
        level: policy.level,
        filter: ProductionFilter(),
        printer: AppLogPrinter(redactSensitiveData: policy.redactSensitiveData),
      ),
    );
  }

  final Logger _logger;

  void trace(
    String message, {
    required AppLogDomain domain,
    String? source,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.t(
      _entry(message: message, domain: domain, source: source),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void debug(
    String message, {
    required AppLogDomain domain,
    String? source,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d(
      _entry(message: message, domain: domain, source: source),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void info(
    String message, {
    required AppLogDomain domain,
    String? source,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(
      _entry(message: message, domain: domain, source: source),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void warning(
    String message, {
    required AppLogDomain domain,
    String? source,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(
      _entry(message: message, domain: domain, source: source),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void error(
    String message, {
    required AppLogDomain domain,
    String? source,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      _entry(message: message, domain: domain, source: source),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void fatal(
    String message, {
    required AppLogDomain domain,
    String? source,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(
      _entry(message: message, domain: domain, source: source),
      error: error,
      stackTrace: stackTrace,
    );
  }

  AppLogEntry _entry({
    required String message,
    required AppLogDomain domain,
    String? source,
  }) {
    return AppLogEntry(
      domain: domain,
      message: message,
      source: source ?? AppLogSource.fromStackTrace(StackTrace.current),
    );
  }
}

class AppLoggerPolicy {
  const AppLoggerPolicy({
    required this.level,
    required this.redactSensitiveData,
  });

  factory AppLoggerPolicy.fromConfig(
    AppConfig config, {
    required bool isReleaseMode,
  }) {
    final safeProductionMode = config.isProd || isReleaseMode;
    return AppLoggerPolicy(
      level: safeProductionMode ? Level.info : Level.trace,
      redactSensitiveData: safeProductionMode,
    );
  }

  final Level level;
  final bool redactSensitiveData;
}

class AppLogPrinter extends LogPrinter {
  AppLogPrinter({required this.redactSensitiveData});

  final bool redactSensitiveData;

  @override
  List<String> log(LogEvent event) {
    final now = DateTime.now().toIso8601String();
    final entry = event.message is AppLogEntry
        ? event.message as AppLogEntry
        : AppLogEntry(
            domain: AppLogDomain.app,
            message: event.message.toString(),
            source: AppLogSource.fromStackTrace(StackTrace.current),
          );
    final message = redactSensitiveData
        ? _redact(entry.message)
        : entry.message.trim();
    final line =
        '$now | ${event.level.name.toUpperCase()} | ${entry.domain.name} | ${entry.source} | $message';
    final lines = <String>[line];

    if (event.error != null) {
      lines.add('error=${_redact(event.error.toString())}');
    }
    if (event.stackTrace != null && !redactSensitiveData) {
      lines.add(event.stackTrace.toString());
    }

    return lines;
  }

  String _redact(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    final patterns = <RegExp>[
      RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      RegExp(r'(?<=token=)[^&\s]+', caseSensitive: false),
      RegExp(r'(?<=paymentKey=)[^&\s]+', caseSensitive: false),
      RegExp(r'(?<=clientKey=)[^&\s]+', caseSensitive: false),
    ];

    return patterns.fold<String>(
      normalized,
      (value, pattern) => value.replaceAll(pattern, '<redacted>'),
    );
  }
}

class AppLogEntry {
  const AppLogEntry({
    required this.domain,
    required this.message,
    required this.source,
  });

  final AppLogDomain domain;
  final String message;
  final String source;
}

class AppLogSource {
  static String fromStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    for (final line in lines) {
      if (line.contains('package:auction_market_mobile/')) {
        final packageStart = line.indexOf('package:auction_market_mobile/');
        final packagePath = line.substring(packageStart).trim();
        return packagePath
            .replaceFirst('package:auction_market_mobile/', '')
            .split(')')
            .first;
      }
    }

    return lines
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => 'unknown')
        .trim();
  }
}
