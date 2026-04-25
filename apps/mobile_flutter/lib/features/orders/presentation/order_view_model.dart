import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../data/order_summary.dart';

part 'order_view_model.g.dart';

@immutable
class OrderQuery {
  const OrderQuery({required this.userId, required this.fieldKey});

  final String userId;
  final String fieldKey;

  @override
  bool operator ==(Object other) {
    return other is OrderQuery &&
        other.userId == userId &&
        other.fieldKey == fieldKey;
  }

  @override
  int get hashCode => Object.hash(userId, fieldKey);
}

@immutable
class OrdersViewState {
  const OrdersViewState({required this.orders});

  final List<OrderSummary> orders;

  OrdersViewState copyWith({List<OrderSummary>? orders}) {
    return OrdersViewState(orders: orders ?? this.orders);
  }
}

@riverpod
class OrdersViewModel extends _$OrdersViewModel {
  StreamSubscription<BackendRefreshEvent>? _refreshSub;

  @override
  Future<OrdersViewState> build(OrderQuery query) async {
    _listenForRefreshes();
    return _fetchState(query);
  }

  Future<OrdersViewState> _fetchState(OrderQuery query) async {
    assert(
      query.fieldKey == 'sellerId' || query.fieldKey == 'buyerId',
      'Unexpected OrderQuery.fieldKey: ${query.fieldKey}',
    );
    final authUserId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (authUserId != null && authUserId != query.userId) {
      return const OrdersViewState(orders: <OrderSummary>[]);
    }
    final role = query.fieldKey == 'sellerId' ? 'seller' : 'buyer';
    final orders = await ref
        .read(backendReadApiProvider)
        .fetchOrders(role: role);
    return OrdersViewState(orders: orders);
  }

  Future<void> _refreshState() async {
    try {
      state = AsyncData(await _fetchState(query));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _listenForRefreshes() {
    _refreshSub ??= listenEvent<BackendRefreshEvent>(
      onEvent: (event) async {
        if (event.includes(BackendRefreshArea.orders)) {
          await _refreshState();
        }
      },
    );
    ref.onDispose(() {
      unawaited(_refreshSub?.cancel());
      _refreshSub = null;
    });
  }
}
