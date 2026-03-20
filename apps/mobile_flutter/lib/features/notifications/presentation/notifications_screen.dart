import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';
import '../../../generated/locale_keys.g.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.notifications_title.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, i) => ListTile(
          title: Text(
            LocaleKeys.notifications_outbid.tr(namedArgs: {'id': '$i'}),
          ),
          subtitle: Text('app://auction/$i'),
        ),
      ),
    );
  }
}
