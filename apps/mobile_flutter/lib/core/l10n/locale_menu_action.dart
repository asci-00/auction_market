import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app_localization.dart';

class AppLocaleMenuAction extends StatelessWidget {
  const AppLocaleMenuAction({super.key});

  @override
  Widget build(BuildContext context) {
    if (EasyLocalization.of(context) == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<Locale>(
      tooltip: 'common.language'.tr(),
      icon: const Icon(Icons.language_rounded),
      initialValue: context.locale,
      onSelected: context.setLocale,
      itemBuilder: (context) => supportedAppLocales
          .map(
            (locale) => PopupMenuItem<Locale>(
              value: locale,
              child: Text(_labelKey(locale).tr()),
            ),
          )
          .toList(),
    );
  }

  String _labelKey(Locale locale) {
    return switch (locale.languageCode) {
      'ko' => 'common.korean',
      'en' => 'common.english',
      _ => 'common.language',
    };
  }
}
