import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/dev_read_api.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../data/my_profile_summary.dart';

part 'my_view_model.g.dart';

@immutable
class MyViewState {
  const MyViewState({required this.profile});

  final MyProfileSummary? profile;

  MyViewState copyWith({MyProfileSummary? profile}) {
    return MyViewState(profile: profile ?? this.profile);
  }
}

@riverpod
class MyViewModel extends _$MyViewModel {
  StreamSubscription<MyProfileSummary?>? _sub;

  @override
  Future<MyViewState> build(String userId) async {
    final config = ref.watch(appConfigProvider);
    if (config.usesHttpBackend) {
      final api = ref.watch(devReadApiProvider);
      final stream = api.poll(api.fetchMyProfile);
      final first = await stream.first;

      ref.onDispose(() {
        unawaited(_sub?.cancel());
      });

      _sub = stream.listen(
        (profile) {
          state = AsyncData(MyViewState(profile: profile));
        },
        onError: (Object error, StackTrace stackTrace) {
          state = AsyncError(error, stackTrace);
        },
      );

      return MyViewState(profile: first);
    }

    final stream = _myProfileStream(ref, userId);
    final first = await stream.first;

    ref.onDispose(() {
      unawaited(_sub?.cancel());
    });

    _sub = stream.listen(
      (profile) {
        final current = state.valueOrNull ?? MyViewState(profile: profile);
        final nextState = profile == null
            ? const MyViewState(profile: null)
            : current.copyWith(profile: profile);
        state = AsyncData(nextState);
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
