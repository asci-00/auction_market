import 'package:auction_market_mobile/features/notifications/application/notification_push_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPushPayload', () {
    test('normalizes app deeplinks into router paths', () {
      final payload = NotificationPushPayload.fromMessageParts(
        data: const {
          'deeplink': 'app://orders/order-123',
          'notificationId': 'notif-1',
        },
        messageId: 'message-1',
        title: 'Payment confirmed',
        body: 'Open the timeline',
        sentTime: DateTime.utc(2026, 4, 11),
      );

      expect(payload, isNotNull);
      expect(payload!.routePath, '/orders/order-123');
      expect(payload.notificationId, 'notif-1');
      expect(payload.deduplicationKey, 'message-1');
    });

    test('falls back to notifications route when deeplink is missing', () {
      final payload = NotificationPushPayload.fromMessageParts(
        data: const <String, dynamic>{},
        messageId: null,
        title: null,
        body: null,
        sentTime: DateTime.utc(2026, 4, 11, 1),
      );

      expect(payload, isNotNull);
      expect(payload!.routePath, '/notifications');
      expect(payload.notificationId, isNull);
      expect(payload.deduplicationKey, '/notifications:1775869200000');
    });

    test('uses trimmed notification id when message id is unavailable', () {
      final payload = NotificationPushPayload.fromMessageParts(
        data: const {
          'deeplink': 'app://auction/auction-1',
          'notificationId': ' notif-2 ',
        },
        messageId: null,
        title: 'Outbid',
        body: 'Current highest bid changed',
        sentTime: DateTime.utc(2026, 4, 11, 2),
      );

      expect(payload, isNotNull);
      expect(payload!.routePath, '/auction/auction-1');
      expect(payload.notificationId, 'notif-2');
      expect(payload.deduplicationKey, 'notif-2');
    });

    test('falls back to notifications for unsupported app deeplinks', () {
      final payload = NotificationPushPayload.fromMessageParts(
        data: const {
          'deeplink': 'app://unsupported/path',
        },
        messageId: 'message-3',
        title: 'Unknown route',
        body: null,
        sentTime: DateTime.utc(2026, 4, 11, 3),
      );

      expect(payload, isNotNull);
      expect(payload!.routePath, '/notifications');
      expect(payload.deduplicationKey, 'message-3');
    });

    test('falls back to notifications for unsupported slash routes', () {
      final payload = NotificationPushPayload.fromMessageParts(
        data: const {
          'deeplink': '/unknown/path',
        },
        messageId: 'message-4',
        title: 'Unknown route',
        body: null,
        sentTime: DateTime.utc(2026, 4, 11, 4),
      );

      expect(payload, isNotNull);
      expect(payload!.routePath, '/notifications');
      expect(payload.deduplicationKey, 'message-4');
    });
  });

  group('NotificationPushService', () {
    test('marks inbox item read and routes once for opened messages', () async {
      final markedReadIds = <String>[];
      final routedPaths = <String>[];
      final service = NotificationPushService(
        markNotificationRead: ({required notificationId}) async {
          markedReadIds.add(notificationId);
        },
        logInfoMessage: (_) {},
        logErrorMessage: ({required message, error, stackTrace}) {},
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        navigateToRoute: (_, routePath) {
          routedPaths.add(routePath);
        },
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );
      addTearDown(router.dispose);

      final message = RemoteMessage.fromMap({
        'messageId': 'message-open-1',
        'data': {
          'deeplink': 'app://orders/order-123',
          'notificationId': 'notif-open-1',
        },
        'sentTime': DateTime.utc(2026, 4, 11, 5).millisecondsSinceEpoch,
      });

      await service.handleOpenMessage(router, message, source: 'background');
      await service.handleOpenMessage(router, message, source: 'background');

      expect(markedReadIds, ['notif-open-1']);
      expect(routedPaths, ['/orders/order-123']);
    });

    test('falls back to notifications when opened message route is unsupported',
        () async {
      final routedPaths = <String>[];
      final service = NotificationPushService(
        markNotificationRead: ({required notificationId}) async {},
        logInfoMessage: (_) {},
        logErrorMessage: ({required message, error, stackTrace}) {},
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        navigateToRoute: (_, routePath) {
          routedPaths.add(routePath);
        },
      );

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );
      addTearDown(router.dispose);

      final message = RemoteMessage.fromMap({
        'messageId': 'message-open-2',
        'data': {
          'deeplink': '/not-a-real-route',
        },
        'sentTime': DateTime.utc(2026, 4, 11, 6).millisecondsSinceEpoch,
      });

      await service.handleOpenMessage(router, message, source: 'terminated');

      expect(routedPaths, ['/notifications']);
    });
  });
}
