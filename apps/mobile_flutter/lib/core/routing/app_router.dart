import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/activity_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auction/presentation/auction_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/my/presentation/my_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/sell/presentation/sell_screen.dart';
import '../firebase/firebase_providers.dart';
import '../widgets/app_shell.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refreshListenable = ref.watch(authRefreshListenableProvider);

  final router = GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshListenable,
    redirect: (_, state) => _redirect(auth, state),
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          returnTo: state.uri.queryParameters['from'],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: SearchScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sell',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: SellScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/activity',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ActivityScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: MyScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/auction/:id',
        builder: (_, state) =>
            AuctionDetailScreen(auctionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/orders',
        builder: (_, __) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (_, state) => OrdersScreen(
          highlightedOrderId: state.pathParameters['orderId'],
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

final authRefreshListenableProvider = Provider<AuthRefreshListenable>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final listenable = AuthRefreshListenable(auth);
  ref.onDispose(listenable.dispose);
  return listenable;
});

class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(FirebaseAuth auth) : _auth = auth {
    _subscription = auth.idTokenChanges().listen((_) => notifyListeners());
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _subscription;

  User? get currentUser => _auth.currentUser;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

String? _redirect(FirebaseAuth auth, GoRouterState state) {
  final normalizedDeepLink = _normalizeDeepLink(state.uri);
  if (normalizedDeepLink != null) {
    if (auth.currentUser == null) {
      return '/login?from=${Uri.encodeComponent(normalizedDeepLink)}';
    }
    return normalizedDeepLink;
  }

  final isAuthenticated = auth.currentUser != null;
  final isLoginRoute = state.matchedLocation == '/login';

  if (!isAuthenticated && !isLoginRoute) {
    final destination = state.uri.path.isEmpty ? '/home' : state.uri.toString();
    return '/login?from=${Uri.encodeComponent(destination)}';
  }

  if (isAuthenticated && isLoginRoute) {
    final returnTo = state.uri.queryParameters['from'];
    if (returnTo != null && returnTo.startsWith('/')) {
      return returnTo;
    }
    return '/home';
  }

  return null;
}

String? _normalizeDeepLink(Uri uri) {
  if (uri.scheme != 'app') {
    return null;
  }

  switch (uri.host) {
    case 'auction':
      if (uri.pathSegments.isNotEmpty) {
        return '/auction/${uri.pathSegments.first}';
      }
      return '/home';
    case 'orders':
      if (uri.pathSegments.isNotEmpty) {
        return '/orders/${uri.pathSegments.first}';
      }
      return '/orders';
    case 'notifications':
      return '/notifications';
    default:
      return '/home';
  }
}
