import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('orders.title'.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: ListView(
        children: [
          ListTile(title: Text('orders.paymentFlow'.tr())),
          ListTile(title: Text('orders.shippingFlow'.tr())),
        ],
      ),
    );
  }
}
