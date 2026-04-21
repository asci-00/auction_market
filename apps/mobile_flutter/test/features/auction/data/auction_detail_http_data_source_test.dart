import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auction_market_mobile/features/auction/data/auction_detail_http_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetchDetail maps Render detail payload into view state data', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    unawaited(
      server.first.then((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/api/auctions/auction-live/detail');
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'detail': {
              'id': 'auction-live',
              'itemId': 'item-live',
              'titleSnapshot': 'Signed Album',
              'heroImageUrl': 'https://example.com/hero.jpg',
              'imageUrls': ['https://example.com/detail.jpg'],
              'description': 'Factory-sealed with hologram proof.',
              'categorySub': 'IDOL_MD',
              'condition': 'LIKE_NEW',
              'sellerId': 'seller1',
              'status': 'LIVE',
              'currentPrice': 13200,
              'buyNowPrice': 18000,
              'orderId': null,
              'endAt': '2026-04-01T18:00:00.000Z',
            },
            'bidHistory': [
              {'amount': 13200, 'createdAt': '2026-04-01T17:00:00.000Z'},
            ],
          }),
        );
        await request.response.close();
      }),
    );

    final dataSource = AuctionDetailHttpDataSource(
      baseUri: Uri.parse('http://${server.address.host}:${server.port}'),
    );
    addTearDown(dataSource.close);

    final snapshot = await dataSource.fetchDetail('auction-live');

    expect(snapshot.detail?.titleSnapshot, 'Signed Album');
    expect(snapshot.detail?.imageUrls, [
      'https://example.com/hero.jpg',
      'https://example.com/detail.jpg',
    ]);
    expect(snapshot.detail?.endAt, DateTime.utc(2026, 4, 1, 18));
    expect(snapshot.bidHistory.single.amount, 13200);
    expect(snapshot.bidHistory.single.createdAt, DateTime.utc(2026, 4, 1, 17));
  });
}
