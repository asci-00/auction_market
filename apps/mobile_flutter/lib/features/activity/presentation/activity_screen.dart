import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_menu_action.dart';
import '../../../generated/locale_keys.g.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.activity_title.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(LocaleKeys.activity_orders.tr()),
            onTap: () => context.push('/orders'),
          ),
          ListTile(title: Text(LocaleKeys.activity_bids.tr())),
          ListTile(title: Text(LocaleKeys.activity_tracking.tr())),
        ],
      ),
    );
  }
}
