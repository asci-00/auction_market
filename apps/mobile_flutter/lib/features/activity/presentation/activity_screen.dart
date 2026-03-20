import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_menu_action.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('activity.title'.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('activity.orders'.tr()),
            onTap: () => context.push('/orders'),
          ),
          ListTile(title: Text('activity.bids'.tr())),
          ListTile(title: Text('activity.tracking'.tr())),
        ],
      ),
    );
  }
}
