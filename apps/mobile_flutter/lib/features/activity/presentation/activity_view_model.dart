import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/activity_hub_summary.dart';

part 'activity_view_model.g.dart';

@immutable
class ActivityViewState {
  const ActivityViewState({
    required this.buyerSummary,
    required this.sellerSummary,
    required this.notificationsSummary,
  });

  final ActivityHubSummary buyerSummary;
  final ActivityHubSummary sellerSummary;
  final ActivityHubSummary notificationsSummary;

  ActivityViewState copyWith({
    ActivityHubSummary? buyerSummary,
    ActivityHubSummary? sellerSummary,
    ActivityHubSummary? notificationsSummary,
  }) {
    return ActivityViewState(
      buyerSummary: buyerSummary ?? this.buyerSummary,
      sellerSummary: sellerSummary ?? this.sellerSummary,
      notificationsSummary: notificationsSummary ?? this.notificationsSummary,
    );
  }
}

@riverpod
class ActivityViewModel extends _$ActivityViewModel {
  StreamSubscription<ActivityHubSummary>? _buyerSub;
  StreamSubscription<ActivityHubSummary>? _sellerSub;
  StreamSubscription<ActivityHubSummary>? _notificationsSub;

  @override
  Future<ActivityViewState> build(String userId) async {
    final buyerStream = _buyerSummaryStream(ref, userId);
    final sellerStream = _sellerSummaryStream(ref, userId);
    final notificationsStream = _notificationsSummaryStream(ref, userId);

    final buyer = await buyerStream.first;
    final seller = await sellerStream.first;
    final notifications = await notificationsStream.first;

    ref.onDispose(() {
      _buyerSub?.cancel();
      _sellerSub?.cancel();
      _notificationsSub?.cancel();
    });

    _buyerSub = buyerStream.listen((value) {
      final current = state.valueOrNull ??
          ActivityViewState(
            buyerSummary: value,
            sellerSummary: seller,
            notificationsSummary: notifications,
          );
      state = AsyncData(current.copyWith(buyerSummary: value));
    });

    _sellerSub = sellerStream.listen((value) {
      final current = state.valueOrNull ??
          ActivityViewState(
            buyerSummary: buyer,
            sellerSummary: value,
            notificationsSummary: notifications,
          );
      state = AsyncData(current.copyWith(sellerSummary: value));
    });

    _notificationsSub = notificationsStream.listen((value) {
      final current = state.valueOrNull ??
          ActivityViewState(
            buyerSummary: buyer,
            sellerSummary: seller,
            notificationsSummary: value,
          );
      state = AsyncData(current.copyWith(notificationsSummary: value));
    });

    return ActivityViewState(
      buyerSummary: buyer,
      sellerSummary: seller,
      notificationsSummary: notifications,
    );
  }
}

Stream<ActivityHubSummary> _buyerSummaryStream(Ref ref, String userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('orders')
      .where('buyerId', isEqualTo: userId)
      .limit(20)
      .snapshots()
      .map((snapshot) => ActivityHubSummary.fromBuyerOrders(snapshot.docs));
}

Stream<ActivityHubSummary> _sellerSummaryStream(Ref ref, String userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('orders')
      .where('sellerId', isEqualTo: userId)
      .limit(20)
      .snapshots()
      .map((snapshot) => ActivityHubSummary.fromSellerOrders(snapshot.docs));
}

Stream<ActivityHubSummary> _notificationsSummaryStream(
  Ref ref,
  String userId,
) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('notifications')
      .doc(userId)
      .collection('inbox')
      .limit(20)
      .snapshots()
      .map((snapshot) => ActivityHubSummary.fromNotifications(snapshot.docs));
}
