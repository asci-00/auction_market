import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/l10n/app_localization.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.dumpErrorToConsole(details);
      if (!kReleaseMode) {
        try {
          _logFlutterErrorDetails(details);
        } catch (loggingError, loggingStack) {
          debugPrint('Failed to log FlutterErrorDetails: $loggingError');
          debugPrint('$loggingStack');
        }
      }
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Zone.current.handleUncaughtError(error, stack);
      return true;
    };

    runApp(
      EasyLocalization(
        supportedLocales: supportedAppLocales,
        fallbackLocale: fallbackAppLocale,
        saveLocale: true,
        path: translationAssetPath,
        child: const ProviderScope(child: AuctionMarketApp()),
      ),
    );
  }, _reportFatalError);
}

void _reportFatalError(Object error, StackTrace stackTrace) {
  FlutterError.dumpErrorToConsole(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'auction_market_mobile',
      context: ErrorDescription('while bootstrapping the application'),
    ),
  );
}

void _logFlutterErrorDetails(FlutterErrorDetails details) {
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
  debugPrint(buffer.toString());
}
