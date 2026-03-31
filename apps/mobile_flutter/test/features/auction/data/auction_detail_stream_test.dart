import 'dart:async';

import 'package:auction_market_mobile/features/auction/data/auction_detail_stream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'bindAuctionDetailStreams keeps emitting auction updates after item subscription starts',
    () async {
      final auctionController = StreamController<AuctionDetailDocument>();
      final itemController = StreamController<AuctionItemDocument>();

      final stream = bindAuctionDetailStreams(
        auctionStream: auctionController.stream,
        itemStreamFor: (_) => itemController.stream,
      );

      final events = <String?>[];
      final subscription = stream.listen(
        (detail) => events.add(detail?.currentPrice.toString()),
      );

      auctionController.add(
        const AuctionDetailDocument(
          id: 'auction-live',
          exists: true,
          data: <String, dynamic>{
            'itemId': 'item-live',
            'titleSnapshot': 'Signed Album',
            'heroImageUrl': 'https://example.com/hero.jpg',
            'sellerId': 'seller1',
            'status': 'LIVE',
            'currentPrice': 13200,
          },
        ),
      );
      await pumpEventQueue();

      itemController.add(
        const AuctionItemDocument(
          exists: true,
          data: <String, dynamic>{
            'description': 'Factory-sealed with hologram proof.',
            'imageUrls': <String>['https://example.com/detail.jpg'],
          },
        ),
      );
      await pumpEventQueue();

      auctionController.add(
        const AuctionDetailDocument(
          id: 'auction-live',
          exists: true,
          data: <String, dynamic>{
            'itemId': 'item-live',
            'titleSnapshot': 'Signed Album',
            'heroImageUrl': 'https://example.com/hero.jpg',
            'sellerId': 'seller1',
            'status': 'LIVE',
            'currentPrice': 14800,
          },
        ),
      );
      await pumpEventQueue();

      expect(events, <String?>['13200', '13200', '14800']);

      await subscription.cancel();
      await auctionController.close();
      await itemController.close();
    },
  );

  test('bindAuctionDetailStreams emits null when auction disappears', () async {
    final auctionController = StreamController<AuctionDetailDocument>();
    final stream = bindAuctionDetailStreams(
      auctionStream: auctionController.stream,
      itemStreamFor: (_) => const Stream<AuctionItemDocument>.empty(),
    );

    final events = <String?>[];
    final subscription = stream.listen(
      (detail) => events.add(detail?.titleSnapshot),
    );

    auctionController.add(
      const AuctionDetailDocument(
        id: 'auction-live',
        exists: true,
        data: <String, dynamic>{
          'itemId': '',
          'titleSnapshot': 'Signed Album',
          'status': 'LIVE',
          'currentPrice': 13200,
        },
      ),
    );
    await pumpEventQueue();

    auctionController.add(
      const AuctionDetailDocument(
        id: 'auction-live',
        exists: false,
        data: <String, dynamic>{},
      ),
    );
    await pumpEventQueue();

    expect(events, <String?>['Signed Album', null]);

    await subscription.cancel();
    await auctionController.close();
  });
}
