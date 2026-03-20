import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';
import '../../../generated/locale_keys.g.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.sell_title.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text(LocaleKeys.sell_step1.tr())),
          ListTile(title: Text(LocaleKeys.sell_step2.tr())),
          ListTile(title: Text(LocaleKeys.sell_step3.tr())),
          ListTile(title: Text(LocaleKeys.sell_step4.tr())),
          ListTile(title: Text(LocaleKeys.sell_step5.tr())),
          ListTile(title: Text(LocaleKeys.sell_step6.tr())),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(LocaleKeys.sell_antiSniping.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
