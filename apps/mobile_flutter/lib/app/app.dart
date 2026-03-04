import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/presentation/activity_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auction/presentation/auction_detail_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/my/presentation/my_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/sell/presentation/sell_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    ShellRoute(
      builder: (_, __, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/sell', builder: (_, __) => const SellScreen()),
        GoRoute(path: '/activity', builder: (_, __) => const ActivityScreen()),
        GoRoute(path: '/my', builder: (_, __) => const MyScreen()),
      ],
    ),
    GoRoute(path: '/auction/:id', builder: (_, s) => AuctionDetailScreen(auctionId: s.pathParameters['id']!)),
    GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
  ],
);

class AuctionMarketApp extends StatelessWidget {
  const AuctionMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '경마',
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: _router,
    );
  }
}

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  static const _tabs = ['/home', '/search', '/sell', '/activity', '/my'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (i) => context.go(_tabs[i]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.sell), label: 'Sell'),
          NavigationDestination(icon: Icon(Icons.local_activity), label: 'Activity'),
          NavigationDestination(icon: Icon(Icons.person), label: 'My'),
        ],
      ),
    );
  }
}
