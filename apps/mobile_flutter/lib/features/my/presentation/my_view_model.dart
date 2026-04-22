import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
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
  StreamSubscription<BackendRefreshEvent>? _refreshSub;

  @override
  Future<MyViewState> build(String userId) async {
    _listenForRefreshes();
    return _fetchState();
  }

  Future<MyViewState> _fetchState() async {
    final profile = await ref.read(backendReadApiProvider).fetchMyProfile();
    return MyViewState(profile: profile);
  }

  Future<void> _refreshState() async {
    try {
      state = AsyncData(await _fetchState());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void _listenForRefreshes() {
    _refreshSub ??= listenEvent<BackendRefreshEvent>(
      onEvent: (event) async {
        if (event.includes(BackendRefreshArea.myProfile)) {
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
