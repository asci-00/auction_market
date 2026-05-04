import 'package:auction_market_mobile/core/app_config/app_config.dart';
import 'package:auction_market_mobile/core/backend/backend_gateway.dart';
import 'package:auction_market_mobile/core/logging/app_logger.dart';
import 'package:auction_market_mobile/features/notifications/application/notification_device_token_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deviceTokenIdCacheKey = 'notifications.deviceTokenId';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Auction Market',
      packageName: 'com.example.auction_market',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('encodes token into a stable Firestore-safe document id', () {
    expect(
      NotificationDeviceTokenService.deviceTokenDocumentId('abc/def:ghi'),
      'abc%2Fdef%3Aghi',
    );
  });

  test('maps Firebase authorization states to schema labels', () {
    expect(
      NotificationDeviceTokenService.permissionStatusLabel(
        AuthorizationStatus.authorized,
      ),
      'AUTHORIZED',
    );
    expect(
      NotificationDeviceTokenService.permissionStatusLabel(
        AuthorizationStatus.denied,
      ),
      'DENIED',
    );
    expect(
      NotificationDeviceTokenService.permissionStatusLabel(
        AuthorizationStatus.provisional,
      ),
      'PROVISIONAL',
    );
    expect(
      NotificationDeviceTokenService.permissionStatusLabel(
        AuthorizationStatus.notDetermined,
      ),
      'NOT_DETERMINED',
    );
  });

  test('register payload includes token metadata for the callable', () {
    final payload = NotificationDeviceTokenService.buildRegisterPayload(
      token: 'token-1',
      platform: 'ANDROID',
      appVersion: '1.0.0',
      locale: 'ko',
      timezone: 'KST',
      permissionStatus: 'AUTHORIZED',
    );

    expect(payload['token'], 'token-1');
    expect(payload['platform'], 'ANDROID');
    expect(payload['appVersion'], '1.0.0');
    expect(payload['locale'], 'ko');
    expect(payload['timezone'], 'KST');
    expect(payload['permissionStatus'], 'AUTHORIZED');
  });

  test(
    'deactivate payload only sends token reference and permission state',
    () {
      final payload = NotificationDeviceTokenService.buildDeactivatePayload(
        tokenId: 'abc%2Fdef',
        permissionStatus: 'DENIED',
      );

      expect(payload, {'tokenId': 'abc%2Fdef', 'permissionStatus': 'DENIED'});
    },
  );

  test(
    'permission denied deactivates the cached token without registering',
    () async {
      SharedPreferences.setMockInitialValues({
        _deviceTokenIdCacheKey: 'cached-token-id',
      });
      final sharedPreferences = await SharedPreferences.getInstance();
      final gateway = _RecordingBackendGateway();
      final service = _buildService(
        gateway: gateway,
        messaging: _FakeFirebaseMessaging(
          authorizationStatus: AuthorizationStatus.denied,
          token: 'token-that-should-not-be-read',
        ),
        sharedPreferences: sharedPreferences,
      );

      await service.syncUserDeviceToken('user-1');

      expect(gateway.registerPayloads, isEmpty);
      expect(gateway.deactivatePayloads, [
        {'tokenId': 'cached-token-id', 'permissionStatus': 'DENIED'},
      ]);
    },
  );

  test(
    'token rotation deactivates the old cached token before registering',
    () async {
      SharedPreferences.setMockInitialValues({
        _deviceTokenIdCacheKey: 'old-token-id',
      });
      final sharedPreferences = await SharedPreferences.getInstance();
      final gateway = _RecordingBackendGateway();
      final service = _buildService(
        gateway: gateway,
        messaging: _FakeFirebaseMessaging(token: 'new/token'),
        sharedPreferences: sharedPreferences,
      );

      await service.syncUserDeviceToken('user-1');

      expect(gateway.deactivatePayloads, [
        {'tokenId': 'old-token-id', 'permissionStatus': 'AUTHORIZED'},
      ]);
      expect(gateway.registerPayloads, hasLength(1));
      expect(
        gateway.registerPayloads.single,
        containsPair('token', 'new/token'),
      );
      expect(gateway.registerPayloads.single, containsPair('platform', 'IOS'));
      expect(
        gateway.registerPayloads.single,
        containsPair('appVersion', '1.2.3'),
      );
      expect(
        sharedPreferences.getString(_deviceTokenIdCacheKey),
        'new%2Ftoken',
      );
    },
  );

  test('iOS APNs-not-ready path skips registration and deactivation', () async {
    SharedPreferences.setMockInitialValues({
      _deviceTokenIdCacheKey: 'cached-token-id',
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final gateway = _RecordingBackendGateway();
    final messaging = _FakeFirebaseMessaging(
      getTokenException: FirebaseException(
        plugin: 'firebase_messaging',
        code: 'apns-token-not-set',
      ),
      apnsTokens: const [null, null, null, null, null],
    );
    final service = _buildService(
      gateway: gateway,
      messaging: messaging,
      sharedPreferences: sharedPreferences,
    );

    await service.syncUserDeviceToken('user-1');

    expect(gateway.registerPayloads, isEmpty);
    expect(gateway.deactivatePayloads, isEmpty);
    expect(messaging.getAPNSTokenCallCount, 5);
    expect(
      sharedPreferences.getString(_deviceTokenIdCacheKey),
      'cached-token-id',
    );
  });
}

NotificationDeviceTokenService _buildService({
  required _RecordingBackendGateway gateway,
  required _FakeFirebaseMessaging messaging,
  required SharedPreferences sharedPreferences,
}) {
  return NotificationDeviceTokenService(
    gateway: gateway,
    auth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-1'), signedIn: true),
    messaging: messaging,
    sharedPreferences: sharedPreferences,
    logger: AppLogger.fromConfig(
      const AppConfig(
        environment: AppEnvironment.dev,
        backendTransport: AppBackendTransport.http,
        apiBaseUrl: 'https://api.example.com',
        useFirebaseEmulators: true,
        tossClientKey: 'test_ck_example',
        firebaseEmulatorHostOverride: null,
      ),
    ),
  );
}

NotificationSettings _notificationSettings(AuthorizationStatus status) {
  return NotificationSettings(
    alert: AppleNotificationSetting.disabled,
    announcement: AppleNotificationSetting.disabled,
    authorizationStatus: status,
    badge: AppleNotificationSetting.disabled,
    carPlay: AppleNotificationSetting.disabled,
    lockScreen: AppleNotificationSetting.disabled,
    notificationCenter: AppleNotificationSetting.disabled,
    showPreviews: AppleShowPreviewSetting.never,
    timeSensitive: AppleNotificationSetting.disabled,
    criticalAlert: AppleNotificationSetting.disabled,
    sound: AppleNotificationSetting.disabled,
    providesAppNotificationSettings: AppleNotificationSetting.disabled,
  );
}

class _FakeFirebaseMessaging extends Fake implements FirebaseMessaging {
  _FakeFirebaseMessaging({
    this.authorizationStatus = AuthorizationStatus.authorized,
    this.token,
    this.getTokenException,
    this.apnsTokens = const [],
  });

  final AuthorizationStatus authorizationStatus;
  final String? token;
  final FirebaseException? getTokenException;
  final List<String?> apnsTokens;
  var getTokenCallCount = 0;
  var getAPNSTokenCallCount = 0;

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return _notificationSettings(authorizationStatus);
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    getTokenCallCount += 1;
    final exception = getTokenException;
    if (exception != null) {
      throw exception;
    }
    return token;
  }

  @override
  Future<String?> getAPNSToken() async {
    final index = getAPNSTokenCallCount;
    getAPNSTokenCallCount += 1;
    if (index >= apnsTokens.length) {
      return null;
    }
    return apnsTokens[index];
  }

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
}

class _RecordingBackendGateway extends Fake implements BackendGateway {
  final registerPayloads = <Map<String, Object?>>[];
  final deactivatePayloads = <Map<String, Object?>>[];

  @override
  Future<Map<String, dynamic>> registerDeviceToken({
    required Map<String, Object?> payload,
  }) async {
    registerPayloads.add(payload);
    final token = payload['token'];
    return {
      'tokenId': token is String
          ? NotificationDeviceTokenService.deviceTokenDocumentId(token)
          : 'registered-token-id',
    };
  }

  @override
  Future<void> deactivateDeviceToken({
    required Map<String, Object?> payload,
  }) async {
    deactivatePayloads.add(payload);
  }
}
