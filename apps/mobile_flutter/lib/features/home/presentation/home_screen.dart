import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마감임박 / 인기 경매'),
        actions: [
          IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications)),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, i) => ListTile(
          title: Text('Auction #$i'),
          subtitle: const Text('현재가: 100,000원 / 즉시구매 가능'),
          trailing: const Text('00:12:08'),
          onTap: () => context.push('/auction/$i'),
        ),
      ),
    );
  }
}
