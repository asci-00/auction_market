import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/backend/backend_gateway.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/routing/app_deeplink.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/app_global_keys.dart';
import '../../settings/application/settings_preferences_service.dart';

const _defaultNotificationChannelId = 'auction_market_updates';
const _defaultNotificationChannelName = 'Auction updates';
const _defaultNotificationChannelDescription =
    'Auction, order, and shipment activity updates.';
const _localNotificationFallbackTitle = 'Auction Market';

final foregroundLocalNotificationBridgeProvider =
    Provider<ForegroundLocalNotificationBridge>((ref) {
      return ForegroundLocalNotificationBridge();
    });

final notificationPushServiceProvider = Provider<NotificationPushService>((
  ref,
) {
  final foregroundLocalNotificationBridge = ref.watch(
    foregroundLocalNotificationBridgeProvider,
  );
  return NotificationPushService(
    markNotificationRead: ({required String notificationId}) async {
      await ref
          .read(backendGatewayProvider)
          .markNotificationRead(notificationId: notificationId);
      sendToEventBus(BackendRefreshEvent.notificationsChanged);
    },
    logInfoMessage: (message) {
      try {
        ref
            .read(appLoggerProvider)
            .info(
              message,
              domain: AppLogDomain.notifications,
              source: 'notification_push_service',
            );
      } catch (_) {
        if (!kReleaseMode) {
          debugPrint('[notification-push] $message');
        }
      }
    },
    logErrorMessage:
        ({required String message, Object? error, StackTrace? stackTrace}) {
          try {
            ref
                .read(appLoggerProvider)
                .error(
                  message,
                  domain: AppLogDomain.notifications,
                  source: 'notification_push_service',
                  error: error,
                  stackTrace: stackTrace,
                );
          } catch (_) {
            if (!kReleaseMode) {
              debugPrint('[notification-push] $message error=$error');
            }
          }
        },
    scaffoldMessengerKey: ref.watch(rootScaffoldMessengerKeyProvider),
    resolveCurrentRoutePath: _defaultResolveCurrentRoutePath,
    refreshRouteStateForPath: _refreshForegroundRouteState,
    showForegroundSystemNotification: foregroundLocalNotificationBridge.show,
  );
});

String _defaultResolveCurrentRoutePath(GoRouter router) {
  return router.state.uri.toString();
}

void _refreshForegroundRouteState(String routePath) {
  final routeUri = Uri.tryParse(routePath);
  if (routeUri == null) {
    return;
  }

  if (routeUri.path == '/notifications') {
    sendToEventBus(BackendRefreshEvent.notificationsChanged);
    return;
  }

  final pathSegments = routeUri.pathSegments;
  if (pathSegments.length == 2 &&
      pathSegments.first == 'auction' &&
      pathSegments.last.isNotEmpty) {
    sendToEventBus(BackendRefreshEvent.auctionChanged(pathSegments.last));
    return;
  }

  final isOrdersRoute =
      routeUri.path == '/orders' ||
      (pathSegments.length == 2 &&
          pathSegments.first == 'orders' &&
          pathSegments.last.isNotEmpty);
  if (!isOrdersRoute) {
    return;
  }

  sendToEventBus(BackendRefreshEvent.ordersChanged());
}

final notificationPushLifecycleProvider = Provider<void>((ref) {
  final service = ref.watch(notificationPushServiceProvider);
  if (Firebase.apps.isEmpty) {
    service.logInfo('skip push lifecycle: Firebase app is not initialized');
    return;
  }

  final permissionStatus = ref
      .watch(notificationPermissionStatusProvider)
      .valueOrNull;
  if (!isRemoteNotificationStatusActive(permissionStatus)) {
    return;
  }

  final messaging = ref.watch(firebaseMessagingProvider);
  final router = ref.watch(goRouterProvider);
  final foregroundLocalNotificationBridge = ref.watch(
    foregroundLocalNotificationBridgeProvider,
  );

  Future<void> runLifecycleTask(
    Future<void> Function() operation, {
    required String context,
  }) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      service.logError(
        'push lifecycle task failed: $context',
        error: error,
        stackTrace: stackTrace,
      );
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'notification_push_service',
          context: ErrorDescription(context),
        ),
      );
    }
  }

  unawaited(
    runLifecycleTask(() async {
      await foregroundLocalNotificationBridge.initialize(
        onPayload: (payload) {
          unawaited(
            runLifecycleTask(
              () => service.handleLocalNotificationPayload(
                router,
                payload,
                source: 'foreground-local',
              ),
              context: 'while routing a foreground local notification tap',
            ),
          );
        },
      );
    }, context: 'while initializing foreground local notifications'),
  );

  final foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
    unawaited(
      runLifecycleTask(
        () => service.handleForegroundMessage(router, message),
        context: 'while presenting a foreground notification message',
      ),
    );
  });

  final openSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
    message,
  ) {
    unawaited(
      runLifecycleTask(
        () => service.handleOpenMessage(router, message, source: 'background'),
        context: 'while routing a notification opened from background state',
      ),
    );
  });

  unawaited(
    runLifecycleTask(() async {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage == null) {
        return;
      }
      await service.handleOpenMessage(
        router,
        initialMessage,
        source: 'terminated',
      );
    }, context: 'while routing the initial notification message'),
  );

  ref.onDispose(() {
    foregroundSubscription.cancel();
    openSubscription.cancel();
  });
});

typedef ForegroundSystemNotificationPresenter =
    Future<bool> Function(NotificationPushPayload payload);

class ForegroundLocalNotificationBridge {
  ForegroundLocalNotificationBridge({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<bool> initialize({
    required void Function(String? payload) onPayload,
  }) async {
    if (_initialized) {
      return true;
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    final bool? initialized;
    try {
      initialized = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_notification'),
        ),
        onDidReceiveNotificationResponse: (response) {
          onPayload(response.payload);
        },
      );
    } on MissingPluginException {
      _initialized = false;
      return false;
    } on PlatformException {
      _initialized = false;
      return false;
    }
    _initialized = initialized ?? true;
    if (_initialized) {
      try {
        final launchDetails = await _plugin.getNotificationAppLaunchDetails();
        if (launchDetails?.didNotificationLaunchApp ?? false) {
          onPayload(launchDetails?.notificationResponse?.payload);
        }
      } on MissingPluginException {
        _initialized = false;
        return false;
      } on PlatformException {
        _initialized = false;
        return false;
      }
    }
    return _initialized;
  }

  Future<bool> show(NotificationPushPayload payload) async {
    if (!_initialized) {
      return false;
    }

    try {
      await _plugin.show(
        id: payload.localNotificationId,
        title: payload.title ?? _localNotificationFallbackTitle,
        body: payload.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _defaultNotificationChannelId,
            _defaultNotificationChannelName,
            channelDescription: _defaultNotificationChannelDescription,
            icon: 'ic_stat_notification',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.status,
            visibility: NotificationVisibility.public,
          ),
        ),
        payload: payload.toLocalNotificationPayload(),
      );
    } on MissingPluginException {
      _initialized = false;
      return false;
    } on PlatformException {
      _initialized = false;
      return false;
    }
    return true;
  }
}

class NotificationPushService {
  NotificationPushService({
    required Future<void> Function({required String notificationId})
    markNotificationRead,
    required void Function(String message) logInfoMessage,
    required void Function({
      required String message,
      Object? error,
      StackTrace? stackTrace,
    })
    logErrorMessage,
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    void Function(GoRouter router, String routePath)? navigateToRoute,
    String Function(GoRouter router)? resolveCurrentRoutePath,
    void Function(String routePath)? refreshRouteStateForPath,
    ForegroundSystemNotificationPresenter? showForegroundSystemNotification,
  }) : _markNotificationRead = markNotificationRead,
       _logInfoMessage = logInfoMessage,
       _logErrorMessage = logErrorMessage,
       _scaffoldMessengerKey = scaffoldMessengerKey,
       _navigateToRoute = navigateToRoute ?? _defaultNavigateToRoute,
       _resolveCurrentRoutePath =
           resolveCurrentRoutePath ?? _defaultResolveCurrentRoutePath,
       _refreshRouteStateForPath =
           refreshRouteStateForPath ?? _defaultRefreshRouteStateForPath,
       _showForegroundSystemNotification = showForegroundSystemNotification;

  final Future<void> Function({required String notificationId})
  _markNotificationRead;
  final void Function(String message) _logInfoMessage;
  final void Function({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  })
  _logErrorMessage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final void Function(GoRouter router, String routePath) _navigateToRoute;
  final String Function(GoRouter router) _resolveCurrentRoutePath;
  final void Function(String routePath) _refreshRouteStateForPath;
  final ForegroundSystemNotificationPresenter?
  _showForegroundSystemNotification;
  final Set<String> _handledOpenKeys = <String>{};

  Future<void> handleForegroundMessage(
    GoRouter router,
    RemoteMessage message,
  ) async {
    final payload = NotificationPushPayload.fromRemoteMessage(message);
    if (payload == null) {
      logInfo('skip foreground push presentation: payload missing');
      return;
    }

    logInfo(
      'foreground push received key=${payload.deduplicationKey} route=${payload.routePath}',
    );
    _refreshRouteStateIfCurrentRouteMatches(router, payload);

    if (await _showForegroundSystemNotificationIfAvailable(payload)) {
      return;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      logInfo(
        'skip foreground SnackBar presentation: iOS native alert enabled key=${payload.deduplicationKey}',
      );
      return;
    }

    _showForegroundSnackBar(router, payload);
  }

  void _showForegroundSnackBar(
    GoRouter router,
    NotificationPushPayload payload,
  ) {
    final messenger = _scaffoldMessengerKey.currentState;
    final context = _scaffoldMessengerKey.currentContext;
    if (messenger == null || context == null) {
      logInfo('skip foreground push presentation: messenger not ready');
      return;
    }

    final l10n = context.l10n;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(payload.formatForBanner(l10n)),
          action: SnackBarAction(
            label: l10n.notificationsOpenAction,
            onPressed: () {
              unawaited(_openPayload(router, payload, source: 'foreground'));
            },
          ),
        ),
      );
  }

  Future<void> handleLocalNotificationPayload(
    GoRouter router,
    String? localNotificationPayload, {
    required String source,
  }) async {
    final payload = NotificationPushPayload.fromLocalNotificationPayload(
      localNotificationPayload,
    );
    if (payload == null) {
      logInfo(
        'skip local notification routing: payload missing source=$source',
      );
      return;
    }
    await _openPayload(router, payload, source: source);
  }

  Future<void> handleOpenMessage(
    GoRouter router,
    RemoteMessage message, {
    required String source,
  }) async {
    final payload = NotificationPushPayload.fromRemoteMessage(message);
    if (payload == null) {
      logInfo('skip opened push routing: payload missing source=$source');
      return;
    }
    await _openPayload(router, payload, source: source);
  }

  Future<void> _openPayload(
    GoRouter router,
    NotificationPushPayload payload, {
    required String source,
  }) async {
    if (!_handledOpenKeys.add(payload.deduplicationKey)) {
      logInfo(
        'skip duplicate opened push routing key=${payload.deduplicationKey} source=$source',
      );
      return;
    }

    logInfo(
      'opened push routing route=${payload.routePath} notificationId=${payload.notificationId} source=$source',
    );
    if (payload.notificationId != null) {
      try {
        await _markNotificationRead(notificationId: payload.notificationId!);
        logInfo(
          'markNotificationRead succeeded notificationId=${payload.notificationId}',
        );
      } catch (error, stackTrace) {
        logError(
          'markNotificationRead failed notificationId=${payload.notificationId}',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    _navigateToRoute(router, payload.routePath);
  }

  Future<bool> _showForegroundSystemNotificationIfAvailable(
    NotificationPushPayload payload,
  ) async {
    final showForegroundSystemNotification = _showForegroundSystemNotification;
    if (showForegroundSystemNotification == null) {
      return false;
    }

    try {
      final shown = await showForegroundSystemNotification(payload);
      if (shown) {
        logInfo(
          'foreground push presented as system notification key=${payload.deduplicationKey}',
        );
        return true;
      }
      logInfo(
        'foreground system notification unavailable key=${payload.deduplicationKey}',
      );
      return false;
    } catch (error, stackTrace) {
      logError(
        'foreground system notification failed key=${payload.deduplicationKey}',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void logInfo(String message) {
    _logInfoMessage(message);
  }

  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    _logErrorMessage(message: message, error: error, stackTrace: stackTrace);
  }

  void _refreshRouteStateIfCurrentRouteMatches(
    GoRouter router,
    NotificationPushPayload payload,
  ) {
    final currentRoutePath = _resolveCurrentRoutePath(router);
    if (!_routePathsMatch(currentRoutePath, payload.routePath)) {
      logInfo(
        'skip foreground push refresh: route mismatch current=$currentRoutePath route=${payload.routePath}',
      );
      return;
    }

    logInfo(
      'foreground push route matched: refresh route=${payload.routePath}',
    );
    try {
      _refreshRouteStateForPath(payload.routePath);
    } catch (error, stackTrace) {
      logError(
        'foreground route refresh failed route=${payload.routePath}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static bool _routePathsMatch(String currentRoutePath, String routePath) {
    final normalizedCurrent = _normalizeRoutePath(currentRoutePath);
    final normalizedTarget = _normalizeRoutePath(routePath);
    if (normalizedCurrent == normalizedTarget) {
      return true;
    }

    final currentUri = Uri.tryParse(normalizedCurrent);
    final targetUri = Uri.tryParse(normalizedTarget);
    if (currentUri == null || targetUri == null) {
      return false;
    }

    if (_isOrdersListOrDetailPath(currentUri.path) &&
        _isOrdersListOrDetailPath(targetUri.path)) {
      return currentUri.path == '/orders' || targetUri.path == '/orders';
    }
    return false;
  }

  static String _normalizeRoutePath(String routePath) {
    final uri = Uri.tryParse(routePath);
    if (uri == null) {
      return routePath;
    }
    return uri.path;
  }

  static bool _isOrdersListOrDetailPath(String path) {
    if (path == '/orders') {
      return true;
    }
    final segments = Uri.parse(path).pathSegments;
    return segments.length == 2 &&
        segments.first == 'orders' &&
        segments.last.isNotEmpty;
  }

  static void _defaultNavigateToRoute(GoRouter router, String routePath) {
    router.push(routePath);
  }

  static void _defaultRefreshRouteStateForPath(String routePath) {}
}

@immutable
class NotificationPushPayload {
  const NotificationPushPayload({
    required this.deduplicationKey,
    required this.routePath,
    required this.title,
    required this.body,
    required this.notificationId,
  });

  final String deduplicationKey;
  final String routePath;
  final String? title;
  final String? body;
  final String? notificationId;

  int get localNotificationId => _positiveHash(deduplicationKey);

  static NotificationPushPayload? fromRemoteMessage(RemoteMessage message) {
    return fromMessageParts(
      data: message.data,
      messageId: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      sentTime: message.sentTime,
    );
  }

  static NotificationPushPayload? fromLocalNotificationPayload(
    String? payload,
  ) {
    final trimmedPayload = _meaningfulString(payload);
    if (trimmedPayload == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmedPayload);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final routePath = _meaningfulString(decoded['routePath'] as String?);
      if (!_isSupportedRoutePath(routePath)) {
        return null;
      }

      final deduplicationKey =
          _meaningfulString(decoded['deduplicationKey'] as String?) ??
          _meaningfulString(decoded['notificationId'] as String?) ??
          routePath!;
      return NotificationPushPayload(
        deduplicationKey: deduplicationKey,
        routePath: routePath!,
        title: _meaningfulString(decoded['title'] as String?),
        body: _meaningfulString(decoded['body'] as String?),
        notificationId: _meaningfulString(decoded['notificationId'] as String?),
      );
    } catch (_) {
      return null;
    }
  }

  String toLocalNotificationPayload() {
    return jsonEncode(<String, String?>{
      'deduplicationKey': deduplicationKey,
      'routePath': routePath,
      'title': title,
      'body': body,
      'notificationId': notificationId,
    });
  }

  static NotificationPushPayload? fromMessageParts({
    required Map<String, dynamic> data,
    required String? messageId,
    required String? title,
    required String? body,
    required DateTime? sentTime,
  }) {
    final deeplink = data['deeplink'];
    final rawDeepLink = deeplink is String && deeplink.trim().isNotEmpty
        ? deeplink.trim()
        : 'app://notifications';
    final routePath = _resolveNotificationRoutePath(rawDeepLink);

    final notificationId = data['notificationId'];
    final resolvedNotificationId =
        notificationId is String && notificationId.trim().isNotEmpty
        ? notificationId.trim()
        : null;
    final deduplicationKey =
        messageId ??
        resolvedNotificationId ??
        '$routePath:${sentTime?.millisecondsSinceEpoch ?? 'unknown'}';

    return NotificationPushPayload(
      deduplicationKey: deduplicationKey,
      routePath: routePath,
      title: _meaningfulString(title),
      body: _meaningfulString(body),
      notificationId: resolvedNotificationId,
    );
  }

  static String _resolveNotificationRoutePath(String rawDeepLink) {
    final uri = Uri.tryParse(rawDeepLink);
    if (uri == null) {
      return '/notifications';
    }

    if (uri.scheme == 'app') {
      final normalized = normalizeAppDeepLink(uri);
      if (!_isSupportedRoutePath(normalized)) {
        return '/notifications';
      }
      return normalized!;
    }

    if (rawDeepLink.startsWith('/') && _isSupportedRoutePath(rawDeepLink)) {
      return rawDeepLink;
    }

    return '/notifications';
  }

  String formatForBanner(AppLocalizations l10n) {
    final resolvedTitle = title ?? l10n.notificationsForegroundFallbackTitle;
    final resolvedBody = body;
    if (resolvedBody == null || resolvedBody.isEmpty) {
      return resolvedTitle;
    }
    return '$resolvedTitle\n$resolvedBody';
  }

  static String? _meaningfulString(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int _positiveHash(String value) {
    var hash = 0;
    for (final codeUnit in value.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  static bool _isSupportedRoutePath(String? routePath) {
    if (routePath == null || !routePath.startsWith('/')) {
      return false;
    }

    final uri = Uri.tryParse(routePath);
    if (uri == null) {
      return false;
    }

    final path = uri.path;
    if (path == '/notifications' ||
        path == '/orders' ||
        path == '/settings' ||
        path == '/payments/success' ||
        path == '/payments/fail') {
      return true;
    }

    final segments = uri.pathSegments;
    if (segments.length == 2 && segments.first == 'auction') {
      return segments.last.isNotEmpty;
    }

    if (segments.length == 2 && segments.first == 'orders') {
      return segments.last.isNotEmpty;
    }

    return false;
  }
}
