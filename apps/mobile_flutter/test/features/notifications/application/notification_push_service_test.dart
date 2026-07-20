import 'package:auction_market_mobile/features/notifications/application/notification_push_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

GoRouter _buildTestRouter() {
  return GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
    ],
  );
}

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
        data: const {'deeplink': 'app://unsupported/path'},
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
        data: const {'deeplink': '/unknown/path'},
        messageId: 'message-4',
        title: 'Unknown route',
        body: null,
        sentTime: DateTime.utc(2026, 4, 11, 4),
      );

      expect(payload, isNotNull);
      expect(payload!.routePath, '/notifications');
      expect(payload.deduplicationKey, 'message-4');
    });

    test('round-trips local notification payloads for tap routing', () {
      const originalPayload = NotificationPushPayload(
        deduplicationKey: 'message-local-1',
        routePath: '/orders/order-123',
        title: 'Payment confirmed',
        body: 'Open the timeline',
        notificationId: 'notif-local-1',
      );

      final restoredPayload =
          NotificationPushPayload.fromLocalNotificationPayload(
            originalPayload.toLocalNotificationPayload(),
          );

      expect(restoredPayload, isNotNull);
      expect(restoredPayload!.deduplicationKey, 'message-local-1');
      expect(restoredPayload.routePath, '/orders/order-123');
      expect(restoredPayload.title, 'Payment confirmed');
      expect(restoredPayload.body, 'Open the timeline');
      expect(restoredPayload.notificationId, 'notif-local-1');
    });

    test('rejects unsupported local notification routes', () {
      final payload = NotificationPushPayload.fromLocalNotificationPayload(
        '{"deduplicationKey":"message-local-2","routePath":"/unknown"}',
      );

      expect(payload, isNull);
    });
  });

  group('ForegroundLocalNotificationBridge', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test(
      'forwards the launch notification payload after initialization',
      () async {
        final plugin = _FakeLocalNotificationsPlugin(
          launchDetails: const NotificationAppLaunchDetails(
            true,
            notificationResponse: NotificationResponse(
              notificationResponseType:
                  NotificationResponseType.selectedNotification,
              payload: 'launch-payload',
            ),
          ),
        );
        final payloads = <String?>[];
        final bridge = ForegroundLocalNotificationBridge(plugin: plugin);

        final initialized = await bridge.initialize(onPayload: payloads.add);

        expect(initialized, isTrue);
        expect(plugin.initializeCalls, 1);
        expect(plugin.launchDetailsCalls, 1);
        expect(payloads, ['launch-payload']);
      },
    );

    test('keeps initialization when launch detail lookup fails', () async {
      final plugin = _FakeLocalNotificationsPlugin(
        launchDetailsError: PlatformException(code: 'launch-details'),
      );
      final bridge = ForegroundLocalNotificationBridge(plugin: plugin);

      final initialized = await bridge.initialize(onPayload: (_) {});
      final shown = await bridge.show(_testLocalNotificationPayload);

      expect(initialized, isTrue);
      expect(shown, isTrue);
      expect(plugin.showCalls, 1);
    });

    test('clears initialization when showing a notification fails', () async {
      final plugin = _FakeLocalNotificationsPlugin(
        showError: PlatformException(code: 'show'),
      );
      final bridge = ForegroundLocalNotificationBridge(plugin: plugin);
      await bridge.initialize(onPayload: (_) {});

      final firstResult = await bridge.show(_testLocalNotificationPayload);
      final secondResult = await bridge.show(_testLocalNotificationPayload);

      expect(firstResult, isFalse);
      expect(secondResult, isFalse);
      expect(plugin.showCalls, 1);
    });
  });

  group('NotificationPushService', () {
    test('presents foreground pushes through system notifications', () async {
      final presentedPayloads = <NotificationPushPayload>[];
      final service = NotificationPushService(
        markNotificationRead: ({required notificationId}) async {},
        logInfoMessage: (_) {},
        logErrorMessage: ({required message, error, stackTrace}) {},
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        resolveCurrentRoutePath: (_) => '/orders/order-999',
        showForegroundSystemNotification: (payload) async {
          presentedPayloads.add(payload);
          return true;
        },
      );

      final router = _buildTestRouter();
      addTearDown(router.dispose);

      final message = RemoteMessage.fromMap({
        'messageId': 'message-foreground-system-1',
        'data': {
          'deeplink': 'app://orders/order-123',
          'notificationId': 'notif-system-1',
        },
        'sentTime': DateTime.utc(2026, 4, 11, 4).millisecondsSinceEpoch,
      });

      await service.handleForegroundMessage(router, message);

      expect(presentedPayloads, hasLength(1));
      expect(presentedPayloads.single.deduplicationKey, message.messageId);
      expect(presentedPayloads.single.routePath, '/orders/order-123');
      expect(presentedPayloads.single.notificationId, 'notif-system-1');
    });

    test(
      'refreshes foreground route state when current route matches',
      () async {
        final refreshedRoutes = <String>[];
        final service = NotificationPushService(
          markNotificationRead: ({required notificationId}) async {},
          logInfoMessage: (_) {},
          logErrorMessage: ({required message, error, stackTrace}) {},
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
          resolveCurrentRoutePath: (_) => '/orders/order-123',
          refreshRouteStateForPath: refreshedRoutes.add,
        );

        final router = _buildTestRouter();
        addTearDown(router.dispose);

        final message = RemoteMessage.fromMap({
          'messageId': 'message-foreground-1',
          'data': {'deeplink': 'app://orders/order-123'},
          'sentTime': DateTime.utc(2026, 4, 11, 5).millisecondsSinceEpoch,
        });

        await service.handleForegroundMessage(router, message);

        expect(refreshedRoutes, ['/orders/order-123']);
      },
    );

    test(
      'does not refresh foreground route state when route does not match',
      () async {
        final refreshedRoutes = <String>[];
        final service = NotificationPushService(
          markNotificationRead: ({required notificationId}) async {},
          logInfoMessage: (_) {},
          logErrorMessage: ({required message, error, stackTrace}) {},
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
          resolveCurrentRoutePath: (_) => '/orders/order-999',
          refreshRouteStateForPath: refreshedRoutes.add,
        );

        final router = _buildTestRouter();
        addTearDown(router.dispose);

        final message = RemoteMessage.fromMap({
          'messageId': 'message-foreground-2',
          'data': {'deeplink': 'app://orders/order-123'},
          'sentTime': DateTime.utc(2026, 4, 11, 6).millisecondsSinceEpoch,
        });

        await service.handleForegroundMessage(router, message);

        expect(refreshedRoutes, isEmpty);
      },
    );

    test(
      'refreshes orders list when payload targets an order detail route',
      () async {
        final refreshedRoutes = <String>[];
        final service = NotificationPushService(
          markNotificationRead: ({required notificationId}) async {},
          logInfoMessage: (_) {},
          logErrorMessage: ({required message, error, stackTrace}) {},
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
          resolveCurrentRoutePath: (_) => '/orders',
          refreshRouteStateForPath: refreshedRoutes.add,
        );

        final router = _buildTestRouter();
        addTearDown(router.dispose);

        final message = RemoteMessage.fromMap({
          'messageId': 'message-foreground-3',
          'data': {'deeplink': 'app://orders/order-123'},
          'sentTime': DateTime.utc(2026, 4, 11, 7).millisecondsSinceEpoch,
        });

        await service.handleForegroundMessage(router, message);

        expect(refreshedRoutes, ['/orders/order-123']);
      },
    );

    test('skips SnackBar fallback on iOS foreground native alerts', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final logMessages = <String>[];
      final service = NotificationPushService(
        markNotificationRead: ({required notificationId}) async {},
        logInfoMessage: logMessages.add,
        logErrorMessage: ({required message, error, stackTrace}) {},
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        resolveCurrentRoutePath: (_) => '/orders/order-999',
        showForegroundSystemNotification: (_) async => false,
      );

      final router = _buildTestRouter();
      addTearDown(router.dispose);

      final message = RemoteMessage.fromMap({
        'messageId': 'message-foreground-ios-1',
        'data': {'deeplink': 'app://orders/order-123'},
        'sentTime': DateTime.utc(2026, 4, 11, 8).millisecondsSinceEpoch,
      });

      await service.handleForegroundMessage(router, message);

      expect(
        logMessages,
        contains(
          contains('skip foreground SnackBar presentation: iOS native alert'),
        ),
      );
    });

    test('keeps opened-message dedupe for mark-read and routing', () async {
      final markedReadIds = <String>[];
      final routedPaths = <String>[];
      var foregroundRefreshed = false;
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
        refreshRouteStateForPath: (_) {
          foregroundRefreshed = true;
        },
      );

      final router = _buildTestRouter();
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
      expect(foregroundRefreshed, isFalse);
    });

    test('routes local notification taps through mark-read dedupe', () async {
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

      final router = _buildTestRouter();
      addTearDown(router.dispose);

      const payload = NotificationPushPayload(
        deduplicationKey: 'message-local-open-1',
        routePath: '/auction/auction-1',
        title: 'Auction updated',
        body: 'Open the auction',
        notificationId: 'notif-local-open-1',
      );

      await service.handleLocalNotificationPayload(
        router,
        payload.toLocalNotificationPayload(),
        source: 'foreground-local',
      );
      await service.handleLocalNotificationPayload(
        router,
        payload.toLocalNotificationPayload(),
        source: 'foreground-local',
      );

      expect(markedReadIds, ['notif-local-open-1']);
      expect(routedPaths, ['/auction/auction-1']);
    });

    test(
      'falls back to notifications when opened message route is unsupported',
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

        final router = _buildTestRouter();
        addTearDown(router.dispose);

        final message = RemoteMessage.fromMap({
          'messageId': 'message-open-2',
          'data': {'deeplink': '/not-a-real-route'},
          'sentTime': DateTime.utc(2026, 4, 11, 6).millisecondsSinceEpoch,
        });

        await service.handleOpenMessage(router, message, source: 'terminated');

        expect(routedPaths, ['/notifications']);
      },
    );
  });
}

const _testLocalNotificationPayload = NotificationPushPayload(
  deduplicationKey: 'local-test',
  routePath: '/notifications',
  title: 'Notification title',
  body: 'Notification body',
  notificationId: 'notification-test',
);

class _FakeLocalNotificationsPlugin implements LocalNotificationsPlugin {
  _FakeLocalNotificationsPlugin({
    this.launchDetails,
    this.launchDetailsError,
    this.showError,
  });

  final NotificationAppLaunchDetails? launchDetails;
  final Object? launchDetailsError;
  final Object? showError;
  int initializeCalls = 0;
  int launchDetailsCalls = 0;
  int showCalls = 0;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  }) async {
    initializeCalls += 1;
    return true;
  }

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async {
    launchDetailsCalls += 1;
    final error = launchDetailsError;
    if (error != null) {
      throw error;
    }
    return launchDetails;
  }

  @override
  Future<void> show({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    showCalls += 1;
    final error = showError;
    if (error != null) {
      throw error;
    }
  }
}
