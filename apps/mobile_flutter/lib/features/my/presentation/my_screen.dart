import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';
import '../../../generated/locale_keys.g.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.my_title.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListTile(
        title: Text(LocaleKeys.my_verificationTitle.tr()),
        subtitle: Text(LocaleKeys.my_verificationStatus.tr()),
      ),
    );
  }
}
