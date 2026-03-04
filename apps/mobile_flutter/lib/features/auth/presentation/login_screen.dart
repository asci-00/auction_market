import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('경마 로그인')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Google 로그인 (MVP)')),
          ElevatedButton(onPressed: () => context.go('/home'), child: const Text('Apple 로그인 (MVP)')),
          const OutlinedButton(onPressed: null, child: Text('카카오 로그인 (Stub)')),
          const OutlinedButton(onPressed: null, child: Text('네이버 로그인 (Stub)')),
        ],
      ),
    );
  }
}
