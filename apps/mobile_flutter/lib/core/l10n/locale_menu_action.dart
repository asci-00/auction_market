import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_localization.dart';
import '../../generated/locale_keys.g.dart';

class AppLocaleMenuAction extends StatelessWidget {
  const AppLocaleMenuAction({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      tooltip: LocaleKeys.common_language.tr(),
      icon: const Icon(Icons.language),
      initialValue: context.locale,
      onSelected: context.setLocale,
      itemBuilder: (context) => supportedAppLocales
          .map(
            (locale) => PopupMenuItem(
              value: locale,
              child: Text(_labelForLocale(locale).tr()),
            ),
          )
          .toList(),
    );
  }

  String _labelForLocale(Locale locale) {
    return switch (locale.languageCode) {
      'ko' => LocaleKeys.common_korean,
      'en' => LocaleKeys.common_english,
      _ => LocaleKeys.common_language,
    };
  }
}
