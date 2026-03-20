import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications.title'.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, i) => ListTile(
          title: Text('notifications.outbid'.tr(namedArgs: {'id': '$i'})),
          subtitle: Text('notifications.deeplink'.tr()),
        ),
      ),
    );
  }
}
