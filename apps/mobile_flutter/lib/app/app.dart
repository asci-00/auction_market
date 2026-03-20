import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/error/app_error.dart';
import '../core/error/error_views.dart';
import '../core/firebase/firebase_bootstrap.dart';
import '../core/l10n/app_localization.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

class AuctionMarketApp extends ConsumerWidget {
  const AuctionMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.light();
    final bootstrapState = ref.watch(appBootstrapProvider);

    return bootstrapState.when(
      data: (_) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: theme,
        onGenerateTitle: (context) => context.l10n.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        routerConfig: ref.watch(goRouterProvider),
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: const AppBootstrapLoadingScreen(),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: StartupFailureView(
          error: AppError.from(error),
          onRetry: () => ref.invalidate(appBootstrapProvider),
        ),
      ),
    );
  }
}
