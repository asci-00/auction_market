import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../settings/application/settings_preferences_service.dart';

const _deviceTokenIdCacheKey = 'notifications.deviceTokenId';

final notificationDeviceTokenServiceProvider =
    Provider<NotificationDeviceTokenService>((ref) {
      return NotificationDeviceTokenService(
        functions: ref.watch(functionsProvider),
        auth: ref.watch(firebaseAuthProvider),
        messaging: ref.watch(firebaseMessagingProvider),
        sharedPreferences: ref.watch(sharedPreferencesProvider),
      );
    });

final notificationDeviceTokenLifecycleProvider = Provider<void>((ref) {
  final service = ref.watch(notificationDeviceTokenServiceProvider);
  String? previousUserId = ref.watch(firebaseAuthProvider).currentUser?.uid;

  Future<void> runLifecycleTask(
    Future<void> Function() operation, {
    required String context,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'notification_device_token_service',
          context: ErrorDescription(context),
        ),
      );
    }
  }

  Future<void> syncCurrentUser() async {
    await runLifecycleTask(() async {
      final currentUser = ref.read(firebaseAuthProvider).currentUser;
      if (currentUser == null) {
        return;
      }
      await service.syncUserDeviceToken(currentUser.uid);
    }, context: 'while synchronizing the current notification device token');
  }

  final authSubscription = ref
      .read(firebaseAuthProvider)
      .authStateChanges()
      .listen((user) async {
        await runLifecycleTask(() async {
          final currentUserId = user?.uid;
          if (previousUserId != null && currentUserId != previousUserId) {
            await service.clearCachedTokenReference();
          }
          previousUserId = currentUserId;
          if (currentUserId != null) {
            await service.syncUserDeviceToken(currentUserId);
          }
        }, context: 'while responding to Firebase Auth session changes');
      });

  final tokenRefreshSubscription = ref
      .read(firebaseMessagingProvider)
      .onTokenRefresh
      .listen((token) async {
        await runLifecycleTask(() async {
          final currentUser = ref.read(firebaseAuthProvider).currentUser;
          if (currentUser == null) {
            return;
          }
          await service.syncUserDeviceToken(
            currentUser.uid,
            tokenOverride: token,
          );
        }, context: 'while handling Firebase Messaging token rotation');
      });

  final appLifecycleListener = AppLifecycleListener(
    onResume: () async {
      await syncCurrentUser();
      ref.invalidate(notificationPermissionStatusProvider);
    },
  );

  unawaited(syncCurrentUser());

  ref.onDispose(() {
    authSubscription.cancel();
    tokenRefreshSubscription.cancel();
    appLifecycleListener.dispose();
  });
});

class NotificationDeviceTokenService {
  const NotificationDeviceTokenService({
    required FirebaseFunctions functions,
    required FirebaseAuth auth,
    required FirebaseMessaging messaging,
    required SharedPreferences sharedPreferences,
  }) : _functions = functions,
       _auth = auth,
       _messaging = messaging,
       _sharedPreferences = sharedPreferences;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;
  final SharedPreferences _sharedPreferences;

  Future<void> syncUserDeviceToken(
    String userId, {
    String? tokenOverride,
  }) async {
    if (_auth.currentUser?.uid != userId) {
      return;
    }

    final permissionStatus = await _currentPermissionStatus();
    final activeStatuses = {
      AuthorizationStatus.authorized,
      AuthorizationStatus.provisional,
    };

    if (!activeStatuses.contains(permissionStatus)) {
      await deactivateTokenForUser(userId, permissionStatus: permissionStatus);
      return;
    }

    final token = tokenOverride ?? await _messaging.getToken();
    if (token == null || token.isEmpty) {
      await deactivateTokenForUser(userId, permissionStatus: permissionStatus);
      return;
    }

    final tokenId = deviceTokenDocumentId(token);
    final cachedTokenId = _sharedPreferences.getString(_deviceTokenIdCacheKey);
    if (cachedTokenId != null && cachedTokenId != tokenId) {
      await _deactivateToken(
        tokenId: cachedTokenId,
        permissionStatus: permissionStatus,
      );
    }

    final appVersion = (await PackageInfo.fromPlatform()).version;
    final result = await _functions
        .httpsCallable('registerDeviceToken')
        .call<dynamic>(
          buildRegisterPayload(
            token: token,
            appVersion: appVersion,
            locale: WidgetsBinding.instance.platformDispatcher.locale
                .toLanguageTag(),
            timezone: DateTime.now().timeZoneName,
            platform: currentDevicePlatform(),
            permissionStatus: permissionStatusLabel(permissionStatus),
          ),
        );
    final data = result.data;
    if (data is! Map<dynamic, dynamic>) {
      throw StateError('registerDeviceToken returned invalid payload: $data');
    }
    final returnedTokenId = data['tokenId'];
    if (returnedTokenId is! String || returnedTokenId.isEmpty) {
      throw StateError(
        'registerDeviceToken returned invalid tokenId: $returnedTokenId',
      );
    }

    await _sharedPreferences.setString(_deviceTokenIdCacheKey, returnedTokenId);
  }

  Future<void> deactivateCurrentUserTokenBeforeSignOut() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }
    final permissionStatus = await _currentPermissionStatus();
    await deactivateTokenForUser(userId, permissionStatus: permissionStatus);
  }

  Future<void> deactivateTokenForUser(
    String userId, {
    AuthorizationStatus? permissionStatus,
  }) async {
    if (_auth.currentUser?.uid != userId) {
      return;
    }

    final tokenId = _sharedPreferences.getString(_deviceTokenIdCacheKey);
    if (tokenId == null || tokenId.isEmpty) {
      return;
    }

    await _deactivateToken(
      tokenId: tokenId,
      permissionStatus: permissionStatus ?? await _currentPermissionStatus(),
    );
  }

  Future<void> clearCachedTokenReference() async {
    await _sharedPreferences.remove(_deviceTokenIdCacheKey);
  }

  Future<AuthorizationStatus> _currentPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<void> _deactivateToken({
    required String tokenId,
    required AuthorizationStatus permissionStatus,
  }) async {
    await _functions
        .httpsCallable('deactivateDeviceToken')
        .call<void>(
          buildDeactivatePayload(
            tokenId: tokenId,
            permissionStatus: permissionStatusLabel(permissionStatus),
          ),
        );
  }

  @visibleForTesting
  static String currentDevicePlatform() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'IOS',
      _ => 'ANDROID',
    };
  }

  @visibleForTesting
  static String deviceTokenDocumentId(String token) {
    return Uri.encodeComponent(token);
  }

  @visibleForTesting
  static String permissionStatusLabel(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => 'AUTHORIZED',
      AuthorizationStatus.denied => 'DENIED',
      AuthorizationStatus.provisional => 'PROVISIONAL',
      AuthorizationStatus.notDetermined => 'NOT_DETERMINED',
    };
  }

  @visibleForTesting
  static Map<String, Object?> buildRegisterPayload({
    required String token,
    required String platform,
    required String appVersion,
    required String locale,
    required String timezone,
    required String permissionStatus,
  }) {
    return {
      'token': token,
      'platform': platform,
      'appVersion': appVersion,
      'locale': locale,
      'timezone': timezone,
      'permissionStatus': permissionStatus,
    };
  }

  @visibleForTesting
  static Map<String, Object?> buildDeactivatePayload({
    required String tokenId,
    required String permissionStatus,
  }) {
    return {'tokenId': tokenId, 'permissionStatus': permissionStatus};
  }
}
