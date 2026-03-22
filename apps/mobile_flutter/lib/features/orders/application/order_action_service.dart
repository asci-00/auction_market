import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';

final orderActionServiceProvider = Provider<OrderActionService>((ref) {
  return OrderActionService(ref.watch(functionsProvider));
});

class OrderActionService {
  const OrderActionService(this._functions);

  final FirebaseFunctions _functions;

  Future<void> submitShipment({
    required String orderId,
    required String carrierName,
    required String trackingNumber,
  }) async {
    await _functions.httpsCallable('shipmentUpdate').call({
      'orderId': orderId,
      'carrierName': carrierName,
      'trackingNumber': trackingNumber,
    });
  }

  Future<void> confirmReceipt({
    required String orderId,
  }) async {
    await _functions.httpsCallable('confirmReceipt').call({
      'orderId': orderId,
    });
  }
}
