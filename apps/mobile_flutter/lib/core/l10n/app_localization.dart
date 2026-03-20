import 'package:flutter/material.dart';

const supportedAppLocales = [Locale('ko'), Locale('en')];

const fallbackAppLocale = Locale('ko');

const translationAssetPath = 'assets/translations';

Locale resolveAppLocale(Locale? deviceLocale) {
  if (deviceLocale == null) {
    return fallbackAppLocale;
  }

  for (final locale in supportedAppLocales) {
    if (locale.languageCode == deviceLocale.languageCode) {
      return locale;
    }
  }

  return fallbackAppLocale;
}
