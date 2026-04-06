import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

import '../../../core/firebase/firebase_providers.dart';
import '../data/settings_preferences.dart';

final settingsPreferencesServiceProvider = Provider<SettingsPreferencesService>(
  (ref) {
    return SettingsPreferencesService(
      firestore: ref.watch(firestoreProvider),
      messaging: ref.watch(firebaseMessagingProvider),
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

final notificationPermissionStatusProvider =
    FutureProvider<AuthorizationStatus>((ref) async {
      final messaging = ref.watch(firebaseMessagingProvider);
      final settings = await messaging.getNotificationSettings();
      return settings.authorizationStatus;
    });

final appPackageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

class SettingsPreferencesService {
  const SettingsPreferencesService({
    required FirebaseFirestore firestore,
    required FirebaseMessaging messaging,
  }) : _firestore = firestore,
       _messaging = messaging;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

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
