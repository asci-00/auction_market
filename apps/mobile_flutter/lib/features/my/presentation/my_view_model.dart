import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/my_profile_summary.dart';

part 'my_view_model.g.dart';

@immutable
class MyViewState {
  const MyViewState({required this.profile});

  static const _profileSentinel = Object();

  final MyProfileSummary? profile;

  MyViewState copyWith({Object? profile = _profileSentinel}) {
    return MyViewState(
      profile: profile == _profileSentinel
          ? this.profile
          : profile as MyProfileSummary?,
    );
  }
}

@riverpod
class MyViewModel extends _$MyViewModel {
  StreamSubscription<MyProfileSummary?>? _sub;

  @override
  Future<MyViewState> build(String userId) async {
    final stream = _myProfileStream(ref, userId);
    final first = await stream.first;

    ref.onDispose(() {
      _sub?.cancel();
    });

    _sub = stream.listen(
      (profile) {
        final current = state.valueOrNull ?? MyViewState(profile: profile);
        state = AsyncData(current.copyWith(profile: profile));
      },
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );

    return MyViewState(profile: first);
  }
}

Stream<MyProfileSummary?> _myProfileStream(Ref ref, String userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users').doc(userId).snapshots().map((snapshot) {
    if (!snapshot.exists) {
      return null;
    }
    return MyProfileSummary.fromDocument(snapshot);
  });
}
