import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/settings_preferences.dart';

const _themeModeCacheKey = 'settings.themeMode';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences override is required.');
});

final settingsPreferencesServiceProvider = Provider<SettingsPreferencesService>(
  (ref) {
    return SettingsPreferencesService(
      firestore: ref.watch(firestoreProvider),
      messaging: ref.watch(firebaseMessagingProvider),
      sharedPreferences: ref.watch(sharedPreferencesProvider),
    );
  },
);

final settingsPreferencesProvider =
    StreamProvider.family<SettingsPreferences, String>((ref, userId) {
      final firestore = ref.watch(firestoreProvider);
      return firestore.collection('users').doc(userId).snapshots().map((snap) {
        if (!snap.exists) {
          return const SettingsPreferences.defaults();
        }
        return SettingsPreferences.fromDocument(snap);
      });
    });

final appSettingsPreferencesProvider = StreamProvider<SettingsPreferences>((
  ref,
) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);

  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) {
      return Stream.value(const SettingsPreferences.defaults());
    }

    return firestore.collection('users').doc(user.uid).snapshots().map((snap) {
      if (!snap.exists) {
        return const SettingsPreferences.defaults();
      }
      return SettingsPreferences.fromDocument(snap);
    });
  });
});

final themeModePreferenceProvider = StateProvider<SettingsThemeModePreference>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsThemeModePreference.parse(prefs.getString(_themeModeCacheKey));
});

final notificationPermissionStatusProvider =
    FutureProvider<AuthorizationStatus>((ref) async {
      final messaging = defaultTargetPlatform == TargetPlatform.android
          ? null
          : ref.watch(firebaseMessagingProvider);
      return resolveNotificationPermissionStatus(messaging: messaging);
    });

final appPackageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsPreferencesService {
  const SettingsPreferencesService({
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
    required SharedPreferences sharedPreferences,
  }) : _firestore = firestore,
       _messaging = messaging,
       _sharedPreferences = sharedPreferences;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final SharedPreferences _sharedPreferences;

  Future<void> setPushEnabled({required String userId, required bool enabled}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .set(pushEnabledPayload(enabled), SetOptions(merge: true));
  }

  Future<void> setCategoryEnabled({
    required String userId,
    required SettingsNotificationCategory category,
    required bool enabled,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .set(
          categoryEnabledPayload(category, enabled),
          SetOptions(merge: true),
        );
  }

  Future<void> setThemeMode(SettingsThemeModePreference themeMode) {
    return _sharedPreferences.setString(
      _themeModeCacheKey,
      themeMode.firestoreValue,
    );
  }

  @visibleForTesting
  static Map<String, Object?> pushEnabledPayload(bool enabled) {
    return {
      'preferences': {'pushEnabled': enabled},
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @visibleForTesting
  static Map<String, Object?> categoryEnabledPayload(
    SettingsNotificationCategory category,
    bool enabled,
  ) {
    return {
      'preferences': {
        'notificationCategories': {category.firestoreKey: enabled},
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );
    return settings.authorizationStatus;
  }

  Future<bool> openSystemSettings() {
    return permission.openAppSettings();
  }
}

Future<AuthorizationStatus> resolveNotificationPermissionStatus({
  FirebaseMessaging? messaging,
}) async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    final status = await permission.Permission.notification.status;
    if (status.isGranted || status.isProvisional) {
      return AuthorizationStatus.authorized;
    }
    if (status.isPermanentlyDenied) {
      return AuthorizationStatus.denied;
    }
    if (status.isDenied) {
      return AuthorizationStatus.notDetermined;
    }
    return AuthorizationStatus.denied;
  }

  final settings = await (messaging ?? FirebaseMessaging.instance)
      .getNotificationSettings();
  return settings.authorizationStatus;
}

bool isRemoteNotificationStatusActive(AuthorizationStatus? status) {
  return status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}
