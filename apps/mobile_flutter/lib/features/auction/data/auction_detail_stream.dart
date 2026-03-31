import 'dart:async';

import 'auction_detail_view_data.dart';

class AuctionDetailDocument {
  const AuctionDetailDocument({
    required this.id,
    required this.exists,
    required this.data,
  });

  final String id;
  final bool exists;
  final Map<String, dynamic> data;
}

class AuctionItemDocument {
  const AuctionItemDocument({required this.exists, required this.data});

  final bool exists;
  final Map<String, dynamic> data;
}

Stream<AuctionDetailViewData?> bindAuctionDetailStreams({
  required Stream<AuctionDetailDocument> auctionStream,
  required Stream<AuctionItemDocument> Function(String itemId) itemStreamFor,
}) {
  return Stream<AuctionDetailViewData?>.multi((controller) {
    StreamSubscription<AuctionItemDocument>? itemSub;
    AuctionDetailDocument? latestAuction;
    AuctionItemDocument? latestItem;
    String? currentItemId;

    void emitCombined() {
      final auction = latestAuction;
      if (auction == null || !auction.exists) {
        controller.add(null);
        return;
      }

      controller.add(
        AuctionDetailViewData.fromMaps(
          auctionId: auction.id,
          auctionData: auction.data,
          itemData: latestItem?.exists == true ? latestItem?.data : null,
        ),
      );
    }

    final auctionSub = auctionStream.listen((auction) {
      latestAuction = auction;
      if (!auction.exists) {
        currentItemId = null;
        latestItem = null;
        itemSub?.cancel();
        itemSub = null;
        controller.add(null);
        return;
      }

      final nextItemId = (auction.data['itemId'] as String?)?.trim() ?? '';
      if (nextItemId.isEmpty) {
        currentItemId = null;
        latestItem = null;
        itemSub?.cancel();
        itemSub = null;
        emitCombined();
        return;
      }

      if (currentItemId != nextItemId) {
        currentItemId = nextItemId;
        latestItem = null;
        itemSub?.cancel();
        itemSub = itemStreamFor(nextItemId).listen((item) {
          latestItem = item;
          emitCombined();
        }, onError: controller.addError);
      }

      emitCombined();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await auctionSub.cancel();
      await itemSub?.cancel();
    };
  });
}
