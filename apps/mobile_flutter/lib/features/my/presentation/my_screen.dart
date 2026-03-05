import 'package:flutter/material.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My')),
      body: const ListTile(
        title: Text('본인인증/귀중품 판매자 인증 상태'),
        subtitle: Text('phone: VERIFIED / id: PENDING / precious: UNVERIFIED'),
      ),
    );
  }
}
