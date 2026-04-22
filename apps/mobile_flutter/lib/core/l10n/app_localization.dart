import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

const supportedAppLocales = <Locale>[Locale('ko'), Locale('en')];

const fallbackAppLocale = Locale('ko');

const translationAssetPath = 'assets/translations';

Locale resolveAppLocale(
  Locale? deviceLocale, [
  Iterable<Locale> supportedLocales = supportedAppLocales,
]) {
  if (deviceLocale != null) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }
  }

  return fallbackAppLocale;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
