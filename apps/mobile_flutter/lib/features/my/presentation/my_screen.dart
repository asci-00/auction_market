import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my.title'.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListTile(
        title: Text('my.verificationTitle'.tr()),
        subtitle: Text('my.verificationStatus'.tr()),
      ),
    );
  }
}
