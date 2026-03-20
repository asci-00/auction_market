import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/locale_menu_action.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
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
          title: Text('home.auctionTitle'.tr(namedArgs: {'id': '$i'})),
          subtitle: Text('home.priceSummary'.tr()),
          trailing: Text('home.timer'.tr()),
          onTap: () => context.push('/auction/$i'),
        ),
      ),
    );
  }
}
