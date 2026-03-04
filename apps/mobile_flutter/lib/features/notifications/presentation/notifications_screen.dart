import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림센터')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, i) => ListTile(title: Text('OUTBID 알림 #$i'), subtitle: const Text('app://auction/123')),
      ),
    );
  }
}
