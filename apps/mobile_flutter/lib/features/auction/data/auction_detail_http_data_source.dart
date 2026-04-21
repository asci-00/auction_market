import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';

import 'auction_bid_history_entry.dart';
import 'auction_detail_view_data.dart';

class AuctionDetailHttpSnapshot {
  const AuctionDetailHttpSnapshot({
    required this.detail,
    required this.bidHistory,
  });

  final AuctionDetailViewData? detail;
  final List<AuctionBidHistoryEntry> bidHistory;
}

class AuctionDetailHttpDataSource {
  AuctionDetailHttpDataSource({required Uri baseUri, HttpClient? client})
    : _baseUri = baseUri,
      _client = client ?? HttpClient();

  final Uri _baseUri;
  final HttpClient _client;

  static const _requestTimeout = Duration(seconds: 15);

  void close() {
    _client.close(force: true);
  }

  Future<AuctionDetailHttpSnapshot> fetchDetail(String auctionId) async {
    final request = await _client
        .getUrl(_baseUri.resolve('/api/auctions/$auctionId/detail'))
        .timeout(_requestTimeout);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close().timeout(_requestTimeout);
    final rawBody = await response
        .transform(utf8.decoder)
        .join()
        .timeout(_requestTimeout);
    final payload = _decodePayload(response.statusCode, rawBody);

    final detailPayload = payload['detail'];
    final bidHistoryPayload = payload['bidHistory'];
    return AuctionDetailHttpSnapshot(
      detail: detailPayload is Map<String, dynamic>
          ? AuctionDetailViewData.fromMaps(
              auctionId: detailPayload['id'] as String? ?? auctionId,
              auctionData: detailPayload,
              itemData: detailPayload,
            )
          : null,
      bidHistory: bidHistoryPayload is List<Object?>
          ? bidHistoryPayload
                .whereType<Map<String, dynamic>>()
                .map(AuctionBidHistoryEntry.fromMap)
                .toList(growable: false)
          : const <AuctionBidHistoryEntry>[],
    );
  }

  Map<String, dynamic> _decodePayload(int statusCode, String rawBody) {
    final trimmedBody = rawBody.trim();
    Map<String, dynamic> payload;
    if (trimmedBody.isEmpty) {
      payload = const <String, dynamic>{};
    } else {
      try {
        payload = jsonDecode(trimmedBody) as Map<String, dynamic>;
      } on FormatException {
        payload = <String, dynamic>{
          'code': 'unknown',
          'message': 'HTTP $statusCode: $trimmedBody',
        };
      }
    }

    if (statusCode >= 400) {
      throw FirebaseFunctionsException(
        code: payload['code']?.toString() ?? 'unknown',
        message: payload['message']?.toString() ?? 'Auction detail failed.',
      );
    }
    return payload;
  }
}
