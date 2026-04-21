import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/backend/backend_gateway.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/routing/app_deeplink.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/widgets/app_global_keys.dart';
import '../../auction/presentation/auction_view_model.dart';
import '../../orders/presentation/order_view_model.dart';
import '../presentation/notifications_view_model.dart';
import '../../settings/application/settings_preferences_service.dart';

const _buyerOrderFieldKey = 'buyerId';
const _sellerOrderFieldKey = 'sellerId';

final notificationPushServiceProvider = Provider<NotificationPushService>((
  ref,
) {
  return NotificationPushService(
    markNotificationRead: ({required String notificationId}) {
      return ref
          .read(backendGatewayProvider)
          .markNotificationRead(notificationId: notificationId);
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
    refreshRouteStateForPath: (routePath) {
      _refreshForegroundRouteState(ref, routePath);
    },
  );
});

String _defaultResolveCurrentRoutePath(GoRouter router) {
  return router.state.uri.toString();
}

void _refreshForegroundRouteState(Ref ref, String routePath) {
  final routeUri = Uri.tryParse(routePath);
  if (routeUri == null) {
    return;
  }

  if (routeUri.path == '/notifications') {
    final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      return;
    }
    ref.invalidate(notificationsViewModelProvider(userId));
    return;
  }

  final pathSegments = routeUri.pathSegments;
  if (pathSegments.length == 2 &&
      pathSegments.first == 'auction' &&
      pathSegments.last.isNotEmpty) {
    ref.invalidate(auctionViewModelProvider(pathSegments.last));
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

  final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
  if (userId == null || userId.isEmpty) {
    return;
  }

  ref.invalidate(
    ordersViewModelProvider(
      OrderQuery(userId: userId, fieldKey: _buyerOrderFieldKey),
    ),
  );
  ref.invalidate(
    ordersViewModelProvider(
      OrderQuery(userId: userId, fieldKey: _sellerOrderFieldKey),
    ),
  );
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
  }) : _markNotificationRead = markNotificationRead,
       _logInfoMessage = logInfoMessage,
       _logErrorMessage = logErrorMessage,
       _scaffoldMessengerKey = scaffoldMessengerKey,
       _navigateToRoute = navigateToRoute ?? _defaultNavigateToRoute,
       _resolveCurrentRoutePath =
           resolveCurrentRoutePath ?? _defaultResolveCurrentRoutePath,
       _refreshRouteStateForPath =
           refreshRouteStateForPath ?? _defaultRefreshRouteStateForPath;

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
    return _normalizeRoutePath(currentRoutePath) ==
        _normalizeRoutePath(routePath);
  }

  static String _normalizeRoutePath(String routePath) {
    final uri = Uri.tryParse(routePath);
    if (uri == null) {
      return routePath;
    }
    return uri.path;
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

  static NotificationPushPayload? fromRemoteMessage(RemoteMessage message) {
    return fromMessageParts(
      data: message.data,
      messageId: message.messageId,
      title: message.notification?.title,
      body: message.notification?.body,
      sentTime: message.sentTime,
    );
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
