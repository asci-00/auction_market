import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/backend/backend_read_api.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../data/settings_preferences.dart';

const _themeModeCacheKey = 'settings.themeMode';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences override is required.');
});

final settingsPreferencesServiceProvider = Provider<SettingsPreferencesService>(
  (ref) {
    return SettingsPreferencesService(
      backendReadApi: ref.watch(backendReadApiProvider),
      messaging: ref.watch(firebaseMessagingProvider),
      sharedPreferences: ref.watch(sharedPreferencesProvider),
    );
  },
);

final settingsPreferencesProvider = StreamProvider<SettingsPreferences>((ref) {
  final api = ref.watch(backendReadApiProvider);
  return _settingsPreferencesEvents(api);
});

final appSettingsPreferencesProvider = StreamProvider<SettingsPreferences>((
  ref,
) {
  final auth = ref.watch(firebaseAuthProvider);
  final api = ref.watch(backendReadApiProvider);
  return _appSettingsPreferencesEvents(auth: auth, api: api);
});

Stream<SettingsPreferences> _settingsPreferencesEvents(BackendReadApi api) {
  return (() async* {
    yield await api.fetchSettingsPreferences();
    await for (final event in watchEvent<BackendRefreshEvent>()) {
      if (event.includes(BackendRefreshArea.settingsPreferences)) {
        yield await api.fetchSettingsPreferences();
      }
    }
  })();
}

Stream<SettingsPreferences> _appSettingsPreferencesEvents({
  required FirebaseAuth auth,
  required BackendReadApi api,
}) {
  final controller = StreamController<SettingsPreferences>();
  StreamSubscription<User?>? authSub;
  StreamSubscription<SettingsPreferences>? settingsSub;

  Future<void> bindForUser(User? user) async {
    await settingsSub?.cancel();
    settingsSub = null;
    if (user == null) {
      controller.add(const SettingsPreferences.defaults());
      return;
    }
    settingsSub = _settingsPreferencesEvents(
      api,
    ).listen(controller.add, onError: controller.addError);
  }

  authSub = auth.authStateChanges().listen((user) {
    unawaited(bindForUser(user));
  }, onError: controller.addError);

  controller.onCancel = () async {
    await settingsSub?.cancel();
    await authSub?.cancel();
  };

  return controller.stream;
}

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
    required BackendReadApi backendReadApi,
    required FirebaseMessaging messaging,
    required SharedPreferences sharedPreferences,
  }) : _backendReadApi = backendReadApi,
       _messaging = messaging,
       _sharedPreferences = sharedPreferences;

  final BackendReadApi _backendReadApi;
  final FirebaseMessaging _messaging;
  final SharedPreferences _sharedPreferences;

  Future<void> setPushEnabled({required bool enabled}) {
    return _backendReadApi.setPushEnabled(enabled: enabled).then((_) {
      sendToEventBus(BackendRefreshEvent.settingsChanged);
    });
  }

  Future<void> setCategoryEnabled({
    required SettingsNotificationCategory category,
    required bool enabled,
  }) {
    return _backendReadApi
        .setCategoryEnabled(category: category, enabled: enabled)
        .then((_) {
          sendToEventBus(BackendRefreshEvent.settingsChanged);
        });
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
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
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
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
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
