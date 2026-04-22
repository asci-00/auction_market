import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/activity/data/activity_hub_summary.dart';
import '../../features/auction/data/auction_bid_history_entry.dart';
import '../../features/auction/data/auction_detail_view_data.dart';
import '../../features/home/data/home_auction_summary.dart';
import '../../features/my/data/my_profile_summary.dart';
import '../../features/notifications/data/notification_item.dart';
import '../../features/orders/data/order_summary.dart';
import '../../features/search/data/search_auction_summary.dart';
import '../../features/sell/data/sell_draft_summary.dart';
import '../../features/settings/data/settings_preferences.dart';
import '../firebase/firebase_bootstrap.dart';
import '../firebase/firebase_providers.dart';

final backendReadApiProvider = Provider<BackendReadApi>((ref) {
  final config = ref.watch(appConfigProvider);
  return BackendReadApi(
    baseUri: Uri.parse(config.apiBaseUrl!),
    auth: ref.watch(firebaseAuthProvider),
  );
});

class BackendReadApi {
  BackendReadApi({
    required Uri baseUri,
    required FirebaseAuth auth,
    HttpClient? client,
  }) : _baseUri = baseUri,
       _auth = auth,
       _client = client ?? HttpClient();

  final Uri _baseUri;
  final FirebaseAuth _auth;
  final HttpClient _client;

  static const _requestTimeout = Duration(seconds: 15);

  Future<HomePayload> fetchHome() async {
    final payload = await _get('/api/auctions/home');
    return HomePayload(
      endingSoon: _list(
        payload['endingSoon'],
      ).map(HomeAuctionSummary.fromMap).toList(growable: false),
      hot: _list(
        payload['hot'],
      ).map(HomeAuctionSummary.fromMap).toList(growable: false),
    );
  }

  Future<List<SearchAuctionSummary>> fetchSearchAuctions() async {
    final payload = await _get('/api/auctions/search');
    return _list(
      payload['results'],
    ).map(SearchAuctionSummary.fromMap).toList(growable: false);
  }

  Future<AuctionDetailHttpSnapshot> fetchAuctionDetail(String auctionId) async {
    final payload = await _get('/api/auctions/$auctionId/detail');
    final detailPayload = payload['detail'];
    final bidHistoryPayload = payload['bidHistory'];
    return AuctionDetailHttpSnapshot(
      detail: detailPayload is Map<String, dynamic>
          ? AuctionDetailViewData.fromMaps(
              auctionId: detailPayload['id'] as String? ?? auctionId,
              auctionData: detailPayload,
              itemData: detailPayload,
            )
          : null,
      bidHistory: _list(
        bidHistoryPayload,
      ).map(AuctionBidHistoryEntry.fromMap).toList(growable: false),
    );
  }

  Future<List<OrderSummary>> fetchOrders({required String role}) async {
    final payload = await _get(
      '/api/orders',
      query: {'role': role},
      authenticated: true,
    );
    return _list(
      payload['orders'],
    ).map(OrderSummary.fromMap).toList(growable: false);
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final payload = await _get('/api/notifications', authenticated: true);
    return _list(
      payload['items'],
    ).map(NotificationItem.fromMap).toList(growable: false);
  }

  Future<ActivityViewPayload> fetchActivity() async {
    final payload = await _get('/api/activity', authenticated: true);
    return ActivityViewPayload(
      buyerSummary: ActivityHubSummary.fromMap(_map(payload['buyerSummary'])),
      sellerSummary: ActivityHubSummary.fromMap(_map(payload['sellerSummary'])),
      notificationsSummary: ActivityHubSummary.fromMap(
        _map(payload['notificationsSummary']),
      ),
    );
  }

  Future<MyProfileSummary?> fetchMyProfile() async {
    final payload = await _get('/api/users/me', authenticated: true);
    final profile = payload['profile'];
    return profile is Map<String, dynamic>
        ? MyProfileSummary.fromMap(profile)
        : null;
  }

  Future<List<SellDraftSummary>> fetchSellDrafts() async {
    final payload = await _get('/api/sell/drafts', authenticated: true);
    return _list(
      payload['drafts'],
    ).map(SellDraftSummary.fromMap).toList(growable: false);
  }

  Future<SettingsPreferences> fetchSettingsPreferences() async {
    final payload = await _get(
      '/api/settings/preferences',
      authenticated: true,
    );
    return SettingsPreferences.fromMap(payload);
  }

  Future<void> setPushEnabled({required bool enabled}) {
    return _post(
      '/api/settings/preferences',
      authenticated: true,
      payload: {
        'preferences': {'pushEnabled': enabled},
      },
    );
  }

  Future<void> setCategoryEnabled({
    required SettingsNotificationCategory category,
    required bool enabled,
  }) {
    return _post(
      '/api/settings/preferences',
      authenticated: true,
      payload: {
        'preferences': {
          'notificationCategories': {category.firestoreKey: enabled},
        },
      },
    );
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
    bool authenticated = false,
  }) async {
    final uri = _baseUri.resolve(path).replace(queryParameters: query);
    final request = await _client.getUrl(uri).timeout(_requestTimeout);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (authenticated) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${await _idToken()}',
      );
    }
    return _decode(await request.close().timeout(_requestTimeout));
  }

  Future<void> _post(
    String path, {
    required Map<String, Object?> payload,
    bool authenticated = false,
  }) async {
    final request = await _client
        .postUrl(_baseUri.resolve(path))
        .timeout(_requestTimeout);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (authenticated) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${await _idToken()}',
      );
    }
    request.write(jsonEncode(payload));
    await _decode(await request.close().timeout(_requestTimeout));
  }

  Future<String> _idToken() async {
    final token = await _auth.currentUser?.getIdToken(false);
    if (token == null || token.isEmpty) {
      throw FirebaseFunctionsException(
        code: 'unauthenticated',
        message: 'Sign-in is required.',
      );
    }
    return token;
  }

  Future<Map<String, dynamic>> _decode(HttpClientResponse response) async {
    final rawBody = await response
        .transform(utf8.decoder)
        .join()
        .timeout(_requestTimeout);
    final trimmed = rawBody.trim();
    Map<String, dynamic> payload;
    if (trimmed.isEmpty) {
      payload = const <String, dynamic>{};
    } else {
      try {
        payload = jsonDecode(trimmed) as Map<String, dynamic>;
      } on FormatException {
        payload = <String, dynamic>{
          'code': 'unknown',
          'message': 'HTTP ${response.statusCode}: $trimmed',
        };
      }
    }
    if (response.statusCode >= 400) {
      throw FirebaseFunctionsException(
        code: payload['code']?.toString() ?? 'unknown',
        message: payload['message']?.toString() ?? 'Request failed.',
      );
    }
    return payload;
  }
}

class HomePayload {
  const HomePayload({required this.endingSoon, required this.hot});

  final List<HomeAuctionSummary> endingSoon;
  final List<HomeAuctionSummary> hot;
}

class AuctionDetailHttpSnapshot {
  const AuctionDetailHttpSnapshot({
    required this.detail,
    required this.bidHistory,
  });

  final AuctionDetailViewData? detail;
  final List<AuctionBidHistoryEntry> bidHistory;
}

class ActivityViewPayload {
  const ActivityViewPayload({
    required this.buyerSummary,
    required this.sellerSummary,
    required this.notificationsSummary,
  });

  final ActivityHubSummary buyerSummary;
  final ActivityHubSummary sellerSummary;
  final ActivityHubSummary notificationsSummary;
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List<Object?>) {
    return const [];
  }
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}

Map<String, dynamic> _map(Object? value) {
  return value is Map<String, dynamic> ? value : const <String, dynamic>{};
}
