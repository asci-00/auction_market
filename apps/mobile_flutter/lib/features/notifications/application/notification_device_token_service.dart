import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backend/backend_gateway.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/logging/app_logger.dart';
import '../../settings/application/settings_preferences_service.dart';

const _deviceTokenIdCacheKey = 'notifications.deviceTokenId';

final notificationDeviceTokenServiceProvider =
    Provider<NotificationDeviceTokenService>((ref) {
      return NotificationDeviceTokenService(
        gateway: ref.watch(backendGatewayProvider),
        auth: ref.watch(firebaseAuthProvider),
        messaging: ref.watch(firebaseMessagingProvider),
        sharedPreferences: ref.watch(sharedPreferencesProvider),
        logger: ref.watch(appLoggerProvider),
      );
    });

final notificationDeviceTokenLifecycleProvider = Provider<void>((ref) {
  final permissionStatus = ref
      .watch(notificationPermissionStatusProvider)
      .valueOrNull;
  if (!isRemoteNotificationStatusActive(permissionStatus)) {
    final appLifecycleListener = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationPermissionStatusProvider),
    );
    ref.onDispose(appLifecycleListener.dispose);
    return;
  }

  final service = ref.watch(notificationDeviceTokenServiceProvider);
  String? previousUserId = ref.watch(firebaseAuthProvider).currentUser?.uid;

  Future<void> runLifecycleTask(
    Future<void> Function() operation, {
    required String context,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      if (_isTransientBackendError(error)) {
        service.logDiagnostic(
          'lifecycle task transient failure: $context -> $error',
          level: AppLogLevel.info,
          error: error,
          stackTrace: stackTrace,
        );
        return;
      }
      service.logDiagnostic(
        'lifecycle task failed: $context -> $error',
        level: AppLogLevel.error,
        error: error,
        stackTrace: stackTrace,
      );
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

  ref.onDispose(() {
    authSubscription.cancel();
    tokenRefreshSubscription.cancel();
    appLifecycleListener.dispose();
  });
});

bool _isTransientBackendError(Object error) {
  if (error is! FirebaseFunctionsException) {
    return false;
  }
  return error.code == 'deadline-exceeded' || error.code == 'unavailable';
}

class NotificationDeviceTokenService {
  const NotificationDeviceTokenService({
    required BackendGateway gateway,
    required FirebaseAuth auth,
    required FirebaseMessaging messaging,
    required SharedPreferences sharedPreferences,
    required AppLogger logger,
  }) : _gateway = gateway,
       _auth = auth,
       _messaging = messaging,
       _sharedPreferences = sharedPreferences,
       _logger = logger;

  final BackendGateway _gateway;
  final FirebaseAuth _auth;
  final FirebaseMessaging _messaging;
  final SharedPreferences _sharedPreferences;
  final AppLogger _logger;

  Future<void> syncUserDeviceToken(
    String userId, {
    String? tokenOverride,
  }) async {
    if (_auth.currentUser?.uid != userId) {
      logDiagnostic(
        'skip sync: auth session userId=${_auth.currentUser?.uid} requested=$userId',
      );
      return;
    }

    final permissionStatus = await _currentPermissionStatus();
    logDiagnostic(
      'sync start userId=$userId permission=${permissionStatusLabel(permissionStatus)} tokenOverride=${tokenOverride != null}',
    );
    final activeStatuses = {
      AuthorizationStatus.authorized,
      AuthorizationStatus.provisional,
    };

    if (!activeStatuses.contains(permissionStatus)) {
      logDiagnostic(
        'permission not active; deactivating cached token if present',
      );
      await deactivateTokenForUser(userId, permissionStatus: permissionStatus);
      return;
    }

    final tokenResolution = tokenOverride == null
        ? await _resolveMessagingToken()
        : _ResolvedMessagingToken.ready(tokenOverride);
    if (tokenResolution.isPendingApnsToken) {
      // iOS can emit auth/session events before APNS registration completes.
      // In that case, skip sync and wait for next resume/token-refresh.
      logDiagnostic('skip sync: APNS token is not ready yet');
      return;
    }
    final token = tokenResolution.token;
    if (token == null || token.isEmpty) {
      logDiagnostic(
        'messaging token is empty; deactivating cached token if present',
      );
      await deactivateTokenForUser(userId, permissionStatus: permissionStatus);
      return;
    }

    final tokenId = deviceTokenDocumentId(token);
    final cachedTokenId = _sharedPreferences.getString(_deviceTokenIdCacheKey);
    logDiagnostic(
      'resolved messaging token tokenId=$tokenId cachedTokenId=$cachedTokenId',
    );
    if (cachedTokenId != null && cachedTokenId != tokenId) {
      logDiagnostic('token rotated; deactivating previous cached token');
      await _deactivateToken(
        tokenId: cachedTokenId,
        permissionStatus: permissionStatus,
      );
    }

    final appVersion = (await PackageInfo.fromPlatform()).version;
    final result = await _gateway.registerDeviceToken(
      payload: buildRegisterPayload(
        token: token,
        appVersion: appVersion,
        locale: WidgetsBinding.instance.platformDispatcher.locale
            .toLanguageTag(),
        timezone: DateTime.now().timeZoneName,
        platform: currentDevicePlatform(),
        permissionStatus: permissionStatusLabel(permissionStatus),
      ),
    );
    final data = result;
    final returnedTokenId = data['tokenId'];
    if (returnedTokenId is! String || returnedTokenId.isEmpty) {
      throw StateError(
        'registerDeviceToken returned invalid tokenId: $returnedTokenId',
      );
    }

    await _sharedPreferences.setString(_deviceTokenIdCacheKey, returnedTokenId);
    logDiagnostic('registerDeviceToken succeeded tokenId=$returnedTokenId');
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
      logDiagnostic(
        'skip deactivate: auth session userId=${_auth.currentUser?.uid} requested=$userId',
      );
      return;
    }

    final tokenId = _sharedPreferences.getString(_deviceTokenIdCacheKey);
    if (tokenId == null || tokenId.isEmpty) {
      logDiagnostic('skip deactivate: no cached token id');
      return;
    }

    final resolvedPermissionStatus =
        permissionStatus ?? await _currentPermissionStatus();
    logDiagnostic(
      'deactivate start tokenId=$tokenId permission=${permissionStatusLabel(resolvedPermissionStatus)}',
    );
    await _deactivateToken(
      tokenId: tokenId,
      permissionStatus: resolvedPermissionStatus,
    );
  }

  Future<void> clearCachedTokenReference() async {
    logDiagnostic('clearing cached token reference');
    await _sharedPreferences.remove(_deviceTokenIdCacheKey);
  }

  Future<AuthorizationStatus> _currentPermissionStatus() async {
    return resolveNotificationPermissionStatus(messaging: _messaging);
  }

  Future<void> _deactivateToken({
    required String tokenId,
    required AuthorizationStatus permissionStatus,
  }) async {
    await _gateway.deactivateDeviceToken(
      payload: buildDeactivatePayload(
        tokenId: tokenId,
        permissionStatus: permissionStatusLabel(permissionStatus),
      ),
    );
    logDiagnostic(
      'deactivateDeviceToken succeeded tokenId=$tokenId permission=${permissionStatusLabel(permissionStatus)}',
    );
  }

  Future<_ResolvedMessagingToken> _resolveMessagingToken() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      final token = await _messaging.getToken();
      logDiagnostic(
        'FirebaseMessaging.getToken resolved platform=${currentDevicePlatform()} tokenPresent=${token != null && token.isNotEmpty}',
      );
      return _ResolvedMessagingToken.ready(token);
    }

    try {
      final token = await _messaging.getToken();
      logDiagnostic(
        'FirebaseMessaging.getToken resolved on iOS tokenPresent=${token != null && token.isNotEmpty}',
      );
      return _ResolvedMessagingToken.ready(token);
    } on FirebaseException catch (error) {
      if (error.code != 'apns-token-not-set') {
        logDiagnostic(
          'FirebaseMessaging.getToken failed on iOS code=${error.code}',
        );
        rethrow;
      }
      logDiagnostic('APNS token not ready yet; entering retry window $error');
    }

    for (var attempt = 0; attempt < 5; attempt++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        final token = await _messaging.getToken();
        logDiagnostic(
          'APNS token became available retry=${attempt + 1} tokenPresent=${token != null && token.isNotEmpty}',
        );
        return _ResolvedMessagingToken.ready(token);
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    logDiagnostic('APNS token still unavailable after retry window');
    return const _ResolvedMessagingToken.pendingApnsToken();
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

  void logDiagnostic(
    String message, {
    AppLogLevel level = AppLogLevel.debug,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode && level == AppLogLevel.debug) {
      return;
    }

    switch (level) {
      case AppLogLevel.debug:
        _logger.debug(
          message,
          domain: AppLogDomain.notifications,
          source: 'notification_device_token_service',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      case AppLogLevel.info:
        _logger.info(
          message,
          domain: AppLogDomain.notifications,
          source: 'notification_device_token_service',
          error: error,
          stackTrace: stackTrace,
        );
        return;
      case AppLogLevel.error:
        _logger.error(
          message,
          domain: AppLogDomain.notifications,
          source: 'notification_device_token_service',
          error: error,
          stackTrace: stackTrace,
        );
        return;
    }
  }
}

enum AppLogLevel { debug, info, error }

class _ResolvedMessagingToken {
  const _ResolvedMessagingToken.ready(this.token) : isPendingApnsToken = false;
  const _ResolvedMessagingToken.pendingApnsToken()
    : token = null,
      isPendingApnsToken = true;

  final String? token;
  final bool isPendingApnsToken;
}
