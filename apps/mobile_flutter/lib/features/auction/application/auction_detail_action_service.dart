import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/backend/backend_gateway.dart';

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
  }

  Future<String?> buyNow({required String auctionId}) async {
    return _gateway.buyNow(auctionId: auctionId);
  }
}
