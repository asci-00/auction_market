import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sell.title'.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text('sell.step1'.tr())),
          ListTile(title: Text('sell.step2'.tr())),
          ListTile(title: Text('sell.step3'.tr())),
          ListTile(title: Text('sell.step4'.tr())),
          ListTile(title: Text('sell.step5'.tr())),
          ListTile(title: Text('sell.step6'.tr())),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('sell.antiSniping'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
