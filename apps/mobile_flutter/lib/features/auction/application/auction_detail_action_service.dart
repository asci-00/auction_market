import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';

final auctionDetailActionServiceProvider =
    Provider<AuctionDetailActionService>((ref) {
  return AuctionDetailActionService(ref.watch(functionsProvider));
});

class AuctionDetailActionService {
  const AuctionDetailActionService(this._functions);

  final FirebaseFunctions _functions;

  Future<void> placeBid({
    required String auctionId,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than 0');
    }

    await _functions.httpsCallable('placeBid').call<void>({
      'auctionId': auctionId,
      'amount': amount,
    });
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

    await _functions.httpsCallable('setAutoBid').call<void>({
      'auctionId': auctionId,
      'maxAmount': maxAmount,
    });
  }

  Future<String?> buyNow({
    required String auctionId,
  }) async {
    final result = await _functions.httpsCallable('buyNow').call<dynamic>({
      'auctionId': auctionId,
    });

    if (result.data case final Map<dynamic, dynamic> data) {
      final orderId = data['orderId'];
      if (orderId is String && orderId.isNotEmpty) {
        return orderId;
      }
    }

    throw StateError(
      'buyNow callable response missing non-empty orderId: ${result.data}',
    );
  }
}
