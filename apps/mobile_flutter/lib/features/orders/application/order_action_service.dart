import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/order_payment_session.dart';

final orderActionServiceProvider = Provider<OrderActionService>((ref) {
  return OrderActionService(ref.watch(functionsProvider));
});

class OrderActionService {
  const OrderActionService(this._functions);

  final FirebaseFunctions _functions;

  Future<OrderPaymentSession> createPaymentSession({
    required String orderId,
  }) async {
    final result =
        await _functions.httpsCallable('createPaymentSession').call<dynamic>({
      'orderId': orderId,
    });

    final data = result.data;
    if (data is! Map<dynamic, dynamic>) {
      throw StateError(
        'createPaymentSession returned invalid payload: ${result.data}',
      );
    }

    return OrderPaymentSession.fromCallable(data);
  }

  Future<void> confirmPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    await _functions.httpsCallable('confirmOrderPayment').call<void>({
      'orderId': orderId,
      'paymentKey': paymentKey,
      'amount': amount,
    });
  }

  Future<void> submitShipment({
    required String orderId,
    required String carrierName,
    required String trackingNumber,
  }) async {
    await _functions.httpsCallable('shipmentUpdate').call<void>({
      'orderId': orderId,
      'carrierName': carrierName,
      'trackingNumber': trackingNumber,
    });
  }

  Future<void> confirmReceipt({
    required String orderId,
  }) async {
    await _functions.httpsCallable('confirmReceipt').call<void>({
      'orderId': orderId,
    });
  }
}
