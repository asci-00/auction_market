import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('ko'),
          child: Text(LocaleKeys.common_korean.tr()),
        ),
        PopupMenuItem(
          value: const Locale('en'),
          child: Text(LocaleKeys.common_english.tr()),
        ),
      ],
    );
  }
}
