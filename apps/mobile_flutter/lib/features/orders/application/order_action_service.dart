import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/backend_gateway.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';
import '../data/order_payment_session.dart';

final orderActionServiceProvider = Provider<OrderActionService>((ref) {
  return OrderActionService(ref.watch(backendGatewayProvider));
});

class OrderActionService {
  const OrderActionService(this._gateway);

  final BackendGateway _gateway;

  Future<OrderPaymentSession> createPaymentSession({
    required String orderId,
  }) async {
    final data = await _gateway.createPaymentSession(orderId: orderId);
    return OrderPaymentSession.fromMap(data);
  }

  Future<void> confirmPayment({
    required String orderId,
    required String paymentKey,
    required int amount,
  }) async {
    await _gateway.confirmOrderPayment(
      orderId: orderId,
      paymentKey: paymentKey,
      amount: amount,
    );
    sendToEventBus(BackendRefreshEvent.ordersChanged(orderId: orderId));
  }

  Future<void> submitShipment({
    required String orderId,
    required String carrierName,
    required String trackingNumber,
  }) async {
    await _gateway.shipmentUpdate(
      orderId: orderId,
      carrierName: carrierName,
      trackingNumber: trackingNumber,
    );
    sendToEventBus(BackendRefreshEvent.ordersChanged(orderId: orderId));
  }

  Future<void> confirmReceipt({required String orderId}) async {
    await _gateway.confirmReceipt(orderId: orderId);
    sendToEventBus(BackendRefreshEvent.ordersChanged(orderId: orderId));
  }
}
