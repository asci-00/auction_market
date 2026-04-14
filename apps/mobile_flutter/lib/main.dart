import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/app_config/app_config.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/l10n/app_localization.dart';
import 'core/logging/app_logger.dart';
import 'features/settings/application/settings_preferences_service.dart';

Future<void> main() async {
  AppLogger? bootstrapLogger;
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    final sharedPreferences = await SharedPreferences.getInstance();
    final config = AppConfig.fromEnvironment();
    final logger = AppLogger.fromConfig(config);
    bootstrapLogger = logger;

    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      try {
        _logFlutterErrorDetails(details, logger);
      } catch (loggingError, loggingStack) {
        logger.error(
          'Failed to log FlutterErrorDetails: $loggingError',
          domain: AppLogDomain.app,
          source: 'main:flutter_error_logger',
          error: loggingError,
          stackTrace: loggingStack,
        );
      }
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      Zone.current.handleUncaughtError(error, stack);
      return true;
    };

    runApp(
      EasyLocalization(
        supportedLocales: supportedAppLocales,
        fallbackLocale: fallbackAppLocale,
        saveLocale: false,
        path: translationAssetPath,
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            appConfigProvider.overrideWithValue(config),
          ],
          child: const AuctionMarketApp(),
        ),
      ),
    );
  }, (error, stackTrace) => _reportFatalError(error, stackTrace, bootstrapLogger));
}

void _reportFatalError(
  Object error,
  StackTrace stackTrace,
  AppLogger? logger,
) {
  logger?.fatal(
    'Unhandled zone fatal error: $error',
    domain: AppLogDomain.app,
    source: 'main:zone_guard',
    error: error,
    stackTrace: stackTrace,
  );
  FlutterError.dumpErrorToConsole(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'auction_market_mobile',
      context: ErrorDescription('while bootstrapping the application'),
    ),
  );
}

void _logFlutterErrorDetails(FlutterErrorDetails details, AppLogger logger) {
  final buffer = StringBuffer()
    ..writeln('----- FlutterError details -----')
    ..writeln(details.exceptionAsString());

  if (details.context != null) {
    buffer.writeln('Context: ${details.context}');
  }

  if (details.stack != null) {
    buffer.writeln('Stack trace:');
    buffer.writeln(details.stack);
  }

  final collector = details.informationCollector;
  if (collector != null) {
    for (final node in collector()) {
      buffer.writeln(node.toStringDeep());
    }
  }

  buffer.writeln('----- End FlutterError details -----');
  logger.error(
    buffer.toString(),
    domain: AppLogDomain.app,
    source: 'main:flutter_error_details',
    error: details.exception,
    stackTrace: details.stack,
  );
}
