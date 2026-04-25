import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/backend/backend_gateway.dart';
import '../../../core/backend/backend_refresh_event.dart';
import '../../../core/events/event_bus.dart';

final auctionDetailActionServiceProvider = Provider<AuctionDetailActionService>(
  (ref) {
    return AuctionDetailActionService(ref.watch(backendGatewayProvider));
  },
);

class AuctionDetailActionService {
  const AuctionDetailActionService(this._gateway);

  final BackendGateway _gateway;

  Future<void> placeBid({
    required String auctionId,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than 0');
    }

    await _gateway.placeBid(auctionId: auctionId, amount: amount);
    sendToEventBus(BackendRefreshEvent.auctionChanged(auctionId));
  }

  Future<void> setAutoBid({
    required String auctionId,
    required int maxAmount,
  }) async {
    if (maxAmount <= 0) {
      throw ArgumentError.value(
        maxAmount,
        'maxAmount',
        'must be greater than 0',
      );
    }

    await _gateway.setAutoBid(auctionId: auctionId, maxAmount: maxAmount);
    sendToEventBus(BackendRefreshEvent.auctionChanged(auctionId));
  }

  Future<String> buyNow({required String auctionId}) async {
    final orderId = await _gateway.buyNow(auctionId: auctionId);
    if (orderId == null || orderId.isEmpty) {
      throw FirebaseFunctionsException(
        code: 'internal',
        message: 'Buy now completed without orderId.',
      );
    }
    sendToEventBus(
      BackendRefreshEvent.buyNowCompleted(
        auctionId: auctionId,
        orderId: orderId,
      ),
    );
    return orderId;
  }
}
