import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/dev_read_api.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
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
  StreamSubscription<List<OrderSummary>>? _sub;

  @override
  Future<OrdersViewState> build(OrderQuery query) async {
    final config = ref.watch(appConfigProvider);
    if (config.usesHttpBackend) {
      final api = ref.watch(devReadApiProvider);
      final role = query.fieldKey == 'sellerId' ? 'seller' : 'buyer';
      final stream = api.poll(() => api.fetchOrders(role: role));
      final first = await stream.first;

      ref.onDispose(() {
        unawaited(_sub?.cancel());
      });

      _sub = stream.listen((orders) {
        final current = state.valueOrNull ?? OrdersViewState(orders: orders);
        state = AsyncData(current.copyWith(orders: orders));
      }, onError: _handleStreamError);

      return OrdersViewState(orders: first);
    }

    final stream = _ordersStream(ref, query);
    final first = await stream.first;

    ref.onDispose(() {
      unawaited(_sub?.cancel());
    });

    _sub = stream.listen((orders) {
      final current = state.valueOrNull ?? OrdersViewState(orders: orders);
      state = AsyncData(current.copyWith(orders: orders));
    }, onError: _handleStreamError);

    return OrdersViewState(orders: first);
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    state = AsyncError(error, stackTrace);
  }
}

Stream<List<OrderSummary>> _ordersStream(Ref ref, OrderQuery query) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('orders')
      .where(query.fieldKey, isEqualTo: query.userId)
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(OrderSummary.fromDocument).toList());
}
