import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/sell_draft_summary.dart';

part 'sell_view_model.g.dart';

@immutable
class SellViewState {
  const SellViewState({required this.recentDrafts});

  final List<SellDraftSummary> recentDrafts;

  SellViewState copyWith({List<SellDraftSummary>? recentDrafts}) {
    return SellViewState(recentDrafts: recentDrafts ?? this.recentDrafts);
  }
}

@riverpod
class SellViewModel extends _$SellViewModel {
  StreamSubscription<List<SellDraftSummary>>? _sub;

  @override
  Future<SellViewState> build(String userId) async {
    final stream = _recentDraftsStream(ref, userId);
    final first = await stream.first;

    ref.onDispose(() {
      _sub?.cancel();
    });

    _sub = stream.listen((drafts) {
      final current = state.valueOrNull ?? SellViewState(recentDrafts: drafts);
      state = AsyncData(current.copyWith(recentDrafts: drafts));
    }, onError: _handleStreamError);

    return SellViewState(recentDrafts: first);
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    state = AsyncError(error, stackTrace);
  }
}

Stream<List<SellDraftSummary>> _recentDraftsStream(Ref ref, String userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('items')
      .where('sellerId', isEqualTo: userId)
      .where('status', isEqualTo: 'DRAFT')
      .orderBy('updatedAt', descending: true)
      .limit(8)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map(SellDraftSummary.fromDocument).toList(),
      );
}
