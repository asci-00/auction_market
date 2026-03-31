import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/auction/data/auction_detail_view_data.dart';
import 'package:auction_market_mobile/features/auction/presentation/widgets/auction_detail_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('clamps gallery index when image count shrinks', (tester) async {
    var auction = _auctionWithImages(const <String>[
      'https://example.com/1.jpg',
      'https://example.com/2.jpg',
      'https://example.com/3.jpg',
    ]);

    await tester.pumpWidget(_TestHarness(auction: auction));
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(find.text('3 / 3'), findsOneWidget);

    auction = _auctionWithImages(const <String>['https://example.com/1.jpg']);
    await tester.pumpWidget(_TestHarness(auction: auction));
    await tester.pumpAndSettle();

    expect(find.text('1 / 1'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _TestHarness extends StatelessWidget {
  const _TestHarness({required this.auction});

  final AuctionDetailViewData auction;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      locale: const Locale('en'),
      localeResolutionCallback: resolveAppLocale,
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: AuctionDetailHeader(auction: auction),
        ),
      ),
    );
  }
}

AuctionDetailViewData _auctionWithImages(List<String> images) {
  return AuctionDetailViewData(
    id: 'auction-live',
    itemId: 'item-live',
    titleSnapshot: 'Signed Album',
    heroImageUrl: images.isEmpty ? null : images.first,
    imageUrls: images,
    description: 'Factory-sealed with hologram proof.',
    categorySub: 'IDOL_MD',
    condition: 'LIKE_NEW',
    sellerId: 'seller1',
    status: 'LIVE',
    currentPrice: 12000,
    buyNowPrice: 18000,
    orderId: null,
    endAt: null,
  );
}
