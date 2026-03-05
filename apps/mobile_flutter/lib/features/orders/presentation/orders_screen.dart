import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주문/결제 (Mock)')),
      body: ListView(
        children: const [
          ListTile(title: Text('AWAITING_PAYMENT → PAID_ESCROW_HOLD')),
          ListTile(title: Text('SHIPPED → CONFIRMED_RECEIPT → SETTLED')),
        ],
      ),
    );
  }
}
