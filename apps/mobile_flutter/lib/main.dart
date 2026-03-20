import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      Zone.current.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.current,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Zone.current.handleUncaughtError(error, stack);
      return true;
    };

    runApp(const ProviderScope(child: AuctionMarketApp()));
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
