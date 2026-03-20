import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_menu_action.dart';
import '../../../generated/locale_keys.g.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.home_title.tr()),
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications),
          ),
          const AppLocaleMenuAction(),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, i) => ListTile(
          title: Text(LocaleKeys.home_auctionTitle.tr(namedArgs: {'id': '$i'})),
          subtitle: Text(
            LocaleKeys.home_priceSummary.tr(
              namedArgs: {'price': '100,000원'},
            ),
          ),
          trailing: Text(
            LocaleKeys.home_timer.tr(
              namedArgs: {'time': '00:12:08'},
            ),
          ),
          onTap: () => context.push('/auction/$i'),
        ),
      ),
    );
  }
}
