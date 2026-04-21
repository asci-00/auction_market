import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/error/app_error.dart';
import '../core/error/error_views.dart';
import '../core/firebase/firebase_bootstrap.dart';
import '../core/l10n/app_localization.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/notifications/application/notification_device_token_service.dart';
import '../features/notifications/application/notification_push_service.dart';
import '../features/settings/application/settings_preferences_service.dart';
import '../core/widgets/app_global_keys.dart';

class AuctionMarketApp extends ConsumerWidget {
  const AuctionMarketApp({super.key});

  List<LocalizationsDelegate<dynamic>> _delegates(BuildContext context) {
    return [...context.localizationDelegates, AppLocalizations.delegate];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightTheme = AppTheme.light();
    final darkTheme = AppTheme.dark();
    final bootstrapState = ref.watch(appBootstrapProvider);
    final themeMode = ref.watch(themeModePreferenceProvider);
    final resolvedLocale = resolveAppLocale(_deviceLocale());
    final scaffoldMessengerKey = ref.watch(rootScaffoldMessengerKeyProvider);

    return bootstrapState.when(
      data: (_) {
        ref.watch(notificationDeviceTokenLifecycleProvider);
        ref.watch(notificationPushLifecycleProvider);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode.materialThemeMode,
          onGenerateTitle: (context) => context.l10n.appTitle,
          locale: resolvedLocale,
          localizationsDelegates: _delegates(context),
          supportedLocales: supportedAppLocales,
          localeResolutionCallback: resolveAppLocale,
          routerConfig: ref.watch(goRouterProvider),
        );
      },
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode.materialThemeMode,
        locale: resolvedLocale,
        localizationsDelegates: _delegates(context),
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: const AppBootstrapLoadingScreen(),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode.materialThemeMode,
        locale: resolvedLocale,
        localizationsDelegates: _delegates(context),
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: StartupFailureView(
          error: AppError.from(error),
          onRetry: () => ref.invalidate(appBootstrapProvider),
        ),
      ),
    );
  }

  Locale? _deviceLocale() {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    for (final locale in dispatcher.locales) {
      final supported = supportedAppLocales.any(
        (candidate) => candidate.languageCode == locale.languageCode,
      );
      if (supported) {
        return locale;
      }
    }

    if (dispatcher.locales.isNotEmpty) {
      return dispatcher.locales.first;
    }

    return dispatcher.locale;
  }
}
