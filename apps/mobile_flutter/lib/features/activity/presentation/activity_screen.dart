import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('활동')),
      body: ListView(
        children: [
          ListTile(title: const Text('주문/결제'), onTap: () => context.push('/orders')),
          const ListTile(title: Text('내 입찰 현황')),
          const ListTile(title: Text('배송 추적')),
        ],
      ),
    );
  }
}
