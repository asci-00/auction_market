import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/activity_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auction/presentation/auction_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/my/presentation/my_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/orders/presentation/order_payment_return_screen.dart';
import '../../features/search/application/search_auction_filter.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/sell/presentation/sell_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../firebase/firebase_providers.dart';
import '../widgets/app_shell.dart';
import 'app_deeplink.dart';

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
        pageBuilder: (_, state) => _buildTransitionPage(
          state: state,
          child: LoginScreen(returnTo: state.uri.queryParameters['from']),
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
                pageBuilder: (_, state) => NoTransitionPage(
                  child: SearchScreen(
                    initialCategory: parseSearchCategoryFilter(
                      state.uri.queryParameters['category'],
                    ),
                  ),
                ),
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
        pageBuilder: (_, state) => _buildTransitionPage(
          state: state,
          child: AuctionDetailScreen(
            auctionId: state.pathParameters['id']!,
            heroTag: state.uri.queryParameters['heroTag'],
          ),
        ),
      ),
      GoRoute(
        path: '/orders',
        pageBuilder: (_, state) =>
            _buildTransitionPage(state: state, child: const OrdersScreen()),
      ),
      GoRoute(
        path: '/orders/:orderId',
        pageBuilder: (_, state) => _buildTransitionPage(
          state: state,
          child: OrdersScreen(
            highlightedOrderId: state.pathParameters['orderId'],
          ),
        ),
      ),
      GoRoute(
        path: '/payments/success',
        pageBuilder: (_, state) => _buildTransitionPage(
          state: state,
          child: OrderPaymentReturnScreen.success(
            orderId: state.uri.queryParameters['orderId'],
            paymentKey: state.uri.queryParameters['paymentKey'],
            amount: int.tryParse(state.uri.queryParameters['amount'] ?? ''),
          ),
        ),
      ),
      GoRoute(
        path: '/payments/fail',
        pageBuilder: (_, state) => _buildTransitionPage(
          state: state,
          child: OrderPaymentReturnScreen.fail(
            orderId: state.uri.queryParameters['orderId'],
            failureCode: state.uri.queryParameters['code'],
            failureMessage: state.uri.queryParameters['message'],
          ),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (_, state) => _buildTransitionPage(
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (_, state) =>
            _buildTransitionPage(state: state, child: const SettingsScreen()),
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
  final normalizedDeepLink = normalizeAppDeepLink(state.uri);
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

CustomTransitionPage<void> _buildTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
