import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/l10n/app_localization.dart';
import 'generated/codegen_loader.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: supportedAppLocales,
      fallbackLocale: fallbackAppLocale,
      saveLocale: true,
      path: translationAssetPath,
      assetLoader: const CodegenLoader(),
      child: const ProviderScope(child: AuctionMarketApp()),
    ),
  );
}
