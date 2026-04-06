import 'package:auction_market_mobile/features/notifications/application/notification_device_token_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

      expect(payload['tokenId'], 'abc%2Fdef');
      expect(payload['permissionStatus'], 'DENIED');
    },
  );
}
