import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_bootstrap.dart';
import '../firebase/firebase_providers.dart';

final backendGatewayProvider = Provider<BackendGateway>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.usesHttpBackend) {
    return HttpBackendGateway(
      auth: ref.watch(firebaseAuthProvider),
      baseUri: Uri.parse(config.apiBaseUrl!),
    );
  }

  return FirebaseCallableBackendGateway(ref.watch(functionsProvider));
});

abstract class BackendGateway {
  Future<Map<String, dynamic>> createPaymentSession({
    required String orderId,
  });

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

  Future<void> confirmReceipt({
    required String orderId,
  });

  Future<void> placeBid({
    required String auctionId,
    required int amount,
  });

  Future<void> setAutoBid({
    required String auctionId,
    required int maxAmount,
  });

  Future<String?> buyNow({required String auctionId});

  Future<void> createOrUpdateItem({
    required Map<String, Object?> payload,
  });

  Future<String> createAuctionFromItem({
    required Map<String, Object?> payload,
  });

  Future<void> markNotificationRead({
    required String notificationId,
  });

  Future<Map<String, dynamic>> registerDeviceToken({
    required Map<String, Object?> payload,
  });

  Future<void> deactivateDeviceToken({
    required Map<String, Object?> payload,
  });
}

class FirebaseCallableBackendGateway implements BackendGateway {
  const FirebaseCallableBackendGateway(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<Map<String, dynamic>> createPaymentSession({
    required String orderId,
  }) async {
    final result =
        await _functions.httpsCallable('createPaymentSession').call<dynamic>({
      'orderId': orderId,
    });
    return _asMap(result.data, 'createPaymentSession');
  }

  @override
  Future<void> confirmOrderPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) {
    return _functions.httpsCallable('confirmOrderPayment').call<void>({
      'orderId': orderId,
      'paymentKey': paymentKey,
      'amount': amount,
    });
  }

  @override
  Future<void> shipmentUpdate({
    required String orderId,
    required String carrierName,
    required String trackingNumber,
  }) {
    return _functions.httpsCallable('shipmentUpdate').call<void>({
      'orderId': orderId,
      'carrierName': carrierName,
      'trackingNumber': trackingNumber,
    });
  }

  @override
  Future<void> confirmReceipt({
    required String orderId,
  }) {
    return _functions.httpsCallable('confirmReceipt').call<void>({
      'orderId': orderId,
    });
  }

  @override
  Future<void> placeBid({
    required String auctionId,
    required int amount,
  }) {
    return _functions.httpsCallable('placeBid').call<void>({
      'auctionId': auctionId,
      'amount': amount,
    });
  }

  @override
  Future<void> setAutoBid({
    required String auctionId,
    required int maxAmount,
  }) {
    return _functions.httpsCallable('setAutoBid').call<void>({
      'auctionId': auctionId,
      'maxAmount': maxAmount,
    });
  }

  @override
  Future<String?> buyNow({required String auctionId}) async {
    final result = await _functions.httpsCallable('buyNow').call<dynamic>({
      'auctionId': auctionId,
    });
    return _readStringField(
      _asMap(result.data, 'buyNow'),
      'orderId',
      'buyNow',
    );
  }

  @override
  Future<void> createOrUpdateItem({
    required Map<String, Object?> payload,
  }) {
    return _functions.httpsCallable('createOrUpdateItem').call<void>(payload);
  }

  @override
  Future<String> createAuctionFromItem({
    required Map<String, Object?> payload,
  }) async {
    final result =
        await _functions.httpsCallable('createAuctionFromItem').call<dynamic>(
          payload,
        );
    final auctionId = _readStringField(
      _asMap(result.data, 'createAuctionFromItem'),
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
  Future<void> markNotificationRead({
    required String notificationId,
  }) {
    return _functions.httpsCallable('markNotificationRead').call<void>({
      'notificationId': notificationId,
    });
  }

  @override
  Future<Map<String, dynamic>> registerDeviceToken({
    required Map<String, Object?> payload,
  }) async {
    final result = await _functions
        .httpsCallable('registerDeviceToken')
        .call<dynamic>(payload);
    return _asMap(result.data, 'registerDeviceToken');
  }

  @override
  Future<void> deactivateDeviceToken({
    required Map<String, Object?> payload,
  }) {
    return _functions.httpsCallable('deactivateDeviceToken').call<void>(payload);
  }
}

class HttpBackendGateway implements BackendGateway {
  HttpBackendGateway({
    required FirebaseAuth auth,
    required Uri baseUri,
    HttpClient? client,
  })  : _auth = auth,
        _baseUri = baseUri,
        _client = client ?? HttpClient();

  final FirebaseAuth _auth;
  final Uri _baseUri;
  final HttpClient _client;

  @override
  Future<Map<String, dynamic>> createPaymentSession({
    required String orderId,
  }) {
    return _post(
      '/api/orders/$orderId/payment-session',
      payload: const {},
    );
  }

  @override
  Future<void> confirmOrderPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    await _post(
      '/api/orders/$orderId/confirm-payment',
      payload: {
        'paymentKey': paymentKey,
        'amount': amount,
      },
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
      payload: {
        'carrierName': carrierName,
        'trackingNumber': trackingNumber,
      },
    );
  }

  @override
  Future<void> confirmReceipt({
    required String orderId,
  }) async {
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
  Future<void> markNotificationRead({
    required String notificationId,
  }) async {
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

  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, Object?> payload,
  }) async {
    final idToken = await _auth.currentUser?.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw FirebaseFunctionsException(
        code: 'unauthenticated',
        message: 'Sign-in is required to call the development backend.',
      );
    }

    final request = await _client.postUrl(_baseUri.resolve(path));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $idToken');
    request.write(jsonEncode(payload));

    final response = await request.close();
    final rawBody = await response.transform(utf8.decoder).join();
    final jsonBody = rawBody.trim().isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(rawBody) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw FirebaseFunctionsException(
        code: jsonBody['code']?.toString() ?? 'unknown',
        message: jsonBody['message']?.toString() ?? 'Development backend error',
      );
    }

    return jsonBody;
  }
}

Map<String, dynamic> _asMap(dynamic data, String functionName) {
  if (data is Map<dynamic, dynamic>) {
    return data.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }

  throw StateError('$functionName returned invalid payload: $data');
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
