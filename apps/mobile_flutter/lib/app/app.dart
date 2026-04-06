import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core/error/app_error.dart';
import '../core/error/error_views.dart';
import '../core/firebase/firebase_bootstrap.dart';
import '../core/l10n/app_localization.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/application/settings_preferences_service.dart';
import '../features/settings/data/settings_preferences.dart';

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
    final appSettings = bootstrapState.asData == null
        ? const SettingsPreferences.defaults()
        : (ref.watch(appSettingsPreferencesProvider).valueOrNull ??
              const SettingsPreferences.defaults());
    final resolvedLocale = _resolveAppLocale(appSettings);

    return bootstrapState.when(
      data: (_) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: appSettings.themeMode.materialThemeMode,
        onGenerateTitle: (context) => context.l10n.appTitle,
        locale: resolvedLocale,
        localizationsDelegates: _delegates(context),
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        routerConfig: ref.watch(goRouterProvider),
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        locale: resolveAppLocale(_deviceLocale()),
        localizationsDelegates: _delegates(context),
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        home: const AppBootstrapLoadingScreen(),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        locale: resolveAppLocale(_deviceLocale()),
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

  Locale _resolveAppLocale(SettingsPreferences preferences) {
    final override = preferences.languagePreference.localeOverride;
    if (override != null) {
      return override;
    }

    return resolveAppLocale(_deviceLocale());
  }

  Locale? _deviceLocale() {
    return WidgetsBinding.instance.platformDispatcher.locale;
  }
}
