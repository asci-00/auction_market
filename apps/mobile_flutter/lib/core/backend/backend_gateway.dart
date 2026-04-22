import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_bootstrap.dart';
import '../firebase/firebase_providers.dart';

final backendGatewayProvider = Provider<BackendGateway>((ref) {
  final config = ref.watch(appConfigProvider);
  return HttpBackendGateway(
    auth: ref.watch(firebaseAuthProvider),
    baseUri: Uri.parse(config.apiBaseUrl!),
  );
});

abstract class BackendGateway {
  Future<Map<String, dynamic>> createPaymentSession({required String orderId});

  Future<void> confirmOrderPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  });

  Future<void> shipmentUpdate({
    required String orderId,
    required String carrierName,
    required String trackingNumber,
  });

  Future<void> confirmReceipt({required String orderId});

  Future<void> placeBid({required String auctionId, required int amount});

  Future<void> setAutoBid({required String auctionId, required int maxAmount});

  Future<String?> buyNow({required String auctionId});

  Future<void> createOrUpdateItem({required Map<String, Object?> payload});

  Future<String> createAuctionFromItem({required Map<String, Object?> payload});

  Future<void> markNotificationRead({required String notificationId});

  Future<Map<String, dynamic>> registerDeviceToken({
    required Map<String, Object?> payload,
  });

  Future<void> deactivateDeviceToken({required Map<String, Object?> payload});

  Future<Map<String, dynamic>> sendDebugPushProbe();
}

class HttpBackendGateway implements BackendGateway {
  HttpBackendGateway({
    required FirebaseAuth auth,
    required Uri baseUri,
    HttpClient? client,
  }) : _auth = auth,
       _baseUri = baseUri,
       _client = client ?? HttpClient();

  final FirebaseAuth _auth;
  final Uri _baseUri;
  final HttpClient _client;
  static const _requestTimeout = Duration(seconds: 20);

  @override
  Future<Map<String, dynamic>> createPaymentSession({required String orderId}) {
    return _post('/api/orders/$orderId/payment-session', payload: const {});
  }

  @override
  Future<void> confirmOrderPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    await _post(
      '/api/orders/$orderId/confirm-payment',
      payload: {'paymentKey': paymentKey, 'amount': amount},
    );
  }

  @override
  Future<void> shipmentUpdate({
    required String orderId,
    required String carrierName,
    required String trackingNumber,
  }) async {
    await _post(
      '/api/orders/$orderId/shipment',
      payload: {'carrierName': carrierName, 'trackingNumber': trackingNumber},
    );
  }

  @override
  Future<void> confirmReceipt({required String orderId}) async {
    await _post('/api/orders/$orderId/confirm-receipt', payload: const {});
  }

  @override
  Future<void> placeBid({
    required String auctionId,
    required int amount,
  }) async {
    await _post(
      '/api/auctions/$auctionId/place-bid',
      payload: {'amount': amount},
    );
  }

  @override
  Future<void> setAutoBid({
    required String auctionId,
    required int maxAmount,
  }) async {
    await _post(
      '/api/auctions/$auctionId/auto-bid',
      payload: {'maxAmount': maxAmount},
    );
  }

  @override
  Future<String?> buyNow({required String auctionId}) async {
    final result = await _post(
      '/api/auctions/$auctionId/buy-now',
      payload: const {},
    );
    return _readStringField(result, 'orderId', 'buyNow');
  }

  @override
  Future<void> createOrUpdateItem({
    required Map<String, Object?> payload,
  }) async {
    await _post('/api/items', payload: payload);
  }

  @override
  Future<String> createAuctionFromItem({
    required Map<String, Object?> payload,
  }) async {
    final result = await _post('/api/auctions', payload: payload);
    final auctionId = _readStringField(
      result,
      'auctionId',
      'createAuctionFromItem',
    );
    if (auctionId == null) {
      throw FirebaseFunctionsException(
        code: 'unknown',
        message: 'createAuctionFromItem returned invalid auctionId.',
      );
    }
    return auctionId;
  }

  @override
  Future<void> markNotificationRead({required String notificationId}) async {
    await _post('/api/notifications/$notificationId/read', payload: const {});
  }

  @override
  Future<Map<String, dynamic>> registerDeviceToken({
    required Map<String, Object?> payload,
  }) {
    return _post('/api/device-tokens/register', payload: payload);
  }

  @override
  Future<void> deactivateDeviceToken({
    required Map<String, Object?> payload,
  }) async {
    await _post('/api/device-tokens/deactivate', payload: payload);
  }

  @override
  Future<Map<String, dynamic>> sendDebugPushProbe() {
    return _post('/api/notifications/debug/push-probe', payload: const {});
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, Object?> payload,
  }) async {
    final initialToken = await _resolveIdToken(forceRefresh: false);
    final initialResult = await _sendPost(
      path,
      payload: payload,
      idToken: initialToken,
    );
    if (initialResult.response.statusCode == HttpStatus.unauthorized) {
      final refreshedToken = await _resolveIdToken(forceRefresh: true);
      final retryResult = await _sendPost(
        path,
        payload: payload,
        idToken: refreshedToken,
      );
      return _decodeResponseBody(
        statusCode: retryResult.response.statusCode,
        rawBody: retryResult.rawBody,
      );
    }
    return _decodeResponseBody(
      statusCode: initialResult.response.statusCode,
      rawBody: initialResult.rawBody,
    );
  }

  Future<String> _resolveIdToken({required bool forceRefresh}) async {
    try {
      final idToken = await _auth.currentUser?.getIdToken(forceRefresh);
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseFunctionsException(
          code: 'unauthenticated',
          message: 'Sign-in is required to call the development backend.',
        );
      }
      return idToken;
    } on FirebaseFunctionsException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw FirebaseFunctionsException(
        code: error.code,
        message:
            error.message ?? 'Authentication is required to call the backend.',
      );
    } on TimeoutException {
      throw FirebaseFunctionsException(
        code: 'deadline-exceeded',
        message: 'Authentication token request timed out.',
      );
    } on SocketException catch (error) {
      throw FirebaseFunctionsException(
        code: 'unavailable',
        message: 'Authentication service is unreachable: ${error.message}',
      );
    }
  }

  Future<_HttpPostResult> _sendPost(
    String path, {
    required Map<String, Object?> payload,
    required String idToken,
  }) async {
    try {
      final request = await _client
          .postUrl(_baseUri.resolve(path))
          .timeout(_requestTimeout);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $idToken');
      request.write(jsonEncode(payload));

      final response = await request.close().timeout(_requestTimeout);
      final rawBody = await response
          .transform(utf8.decoder)
          .join()
          .timeout(_requestTimeout);
      return _HttpPostResult(response: response, rawBody: rawBody);
    } on TimeoutException {
      throw FirebaseFunctionsException(
        code: 'deadline-exceeded',
        message: 'Development backend request timed out.',
      );
    } on SocketException catch (error) {
      throw FirebaseFunctionsException(
        code: 'unavailable',
        message: 'Development backend is unreachable: ${error.message}',
      );
    }
  }

  Map<String, dynamic> _decodeResponseBody({
    required int statusCode,
    required String rawBody,
  }) {
    final trimmedBody = rawBody.trim();
    Map<String, dynamic> jsonBody;
    if (trimmedBody.isEmpty) {
      jsonBody = const <String, dynamic>{};
    } else {
      try {
        jsonBody = jsonDecode(trimmedBody) as Map<String, dynamic>;
      } on FormatException {
        jsonBody = <String, dynamic>{
          'code': 'unknown',
          'message': 'HTTP $statusCode: $trimmedBody',
        };
      }
    }

    if (statusCode >= 400) {
      throw FirebaseFunctionsException(
        code: jsonBody['code']?.toString() ?? 'unknown',
        message: jsonBody['message']?.toString() ?? 'Development backend error',
      );
    }

    return jsonBody;
  }
}

class _HttpPostResult {
  const _HttpPostResult({required this.response, required this.rawBody});

  final HttpClientResponse response;
  final String rawBody;
}

String? _readStringField(
  Map<String, dynamic> data,
  String fieldName,
  String actionName,
) {
  final value = data[fieldName];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  if (value == null) {
    return null;
  }

  throw StateError('$actionName returned invalid $fieldName: $value');
}
