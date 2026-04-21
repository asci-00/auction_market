import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/home_auction_summary.dart';

part 'home_view_model.g.dart';

@immutable
class HomeViewState {
  const HomeViewState({required this.endingSoon, required this.hot});

  final List<HomeAuctionSummary> endingSoon;
  final List<HomeAuctionSummary> hot;

  HomeViewState copyWith({
    List<HomeAuctionSummary>? endingSoon,
    List<HomeAuctionSummary>? hot,
  }) {
    return HomeViewState(
      endingSoon: endingSoon ?? this.endingSoon,
      hot: hot ?? this.hot,
    );
  }
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  StreamSubscription<List<HomeAuctionSummary>>? _endingSoonSub;
  StreamSubscription<List<HomeAuctionSummary>>? _hotSub;

  @override
  Future<HomeViewState> build() async {
    ref.onDispose(() {
      unawaited(_endingSoonSub?.cancel());
      unawaited(_hotSub?.cancel());
    });

    final endingSoonStream = _homeEndingSoonStream(ref);
    final hotStream = _homeHotStream(ref);
    final initial = await Future.wait([
      endingSoonStream.first,
      hotStream.first,
    ]);

    _endingSoonSub = endingSoonStream.listen(
      (items) => state = AsyncData(
        (state.valueOrNull ?? HomeViewState(endingSoon: initial[0], hot: initial[1]))
            .copyWith(endingSoon: items),
      ),
    );
    _hotSub = hotStream.listen(
      (items) => state = AsyncData(
        (state.valueOrNull ?? HomeViewState(endingSoon: initial[0], hot: initial[1]))
            .copyWith(hot: items),
      ),
    );

    return HomeViewState(endingSoon: initial[0], hot: initial[1]);
  }
}

Stream<List<HomeAuctionSummary>> _homeEndingSoonStream(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('auctions')
      .where('status', isEqualTo: 'LIVE')
      .orderBy('endAt')
      .limit(8)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(HomeAuctionSummary.fromDocument)
            .toList(growable: false),
      );
}

Stream<List<HomeAuctionSummary>> _homeHotStream(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('auctions')
      .where('status', isEqualTo: 'LIVE')
      .orderBy('bidCount', descending: true)
      .limit(8)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(HomeAuctionSummary.fromDocument)
            .toList(growable: false),
      );
}
