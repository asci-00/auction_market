import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/auction/data/auction_bid_history_entry.dart';
import 'package:auction_market_mobile/features/auction/data/auction_detail_view_data.dart';
import 'package:auction_market_mobile/features/auction/presentation/widgets/auction_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'renders live buyer auction composition with description and bid actions',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: AuctionDetailView(
            heroTag: null,
            userId: 'buyer1',
            isSubmitting: false,
            auction: _sampleAuction(),
            hasError: false,
            bidHistory: const [
              AuctionBidHistoryEntry(
                amount: 13200,
                createdAt: null,
              ),
            ],
            isLoading: false,
            onBrowseHome: () {},
            onRequireLogin: () {},
            onReviewOrders: () {},
            onOpenOrder: (_) {},
            onPlaceBid: (_) {},
            onSetAutoBid: (_) {},
            onBuyNow: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Item details'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Item details'), findsOneWidget);
      expect(find.text('Factory-sealed with hologram proof.'), findsOneWidget);
      expect(find.text('Set auto-bid ceiling'), findsOneWidget);
      expect(find.textContaining('Bid from'), findsOneWidget);
      expect(find.textContaining('Buy now'), findsOneWidget);
    },
  );

  testWidgets(
    'renders seller-owned live auction with review action instead of buyer actions',
    (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: AuctionDetailView(
            heroTag: null,
            userId: 'seller1',
            isSubmitting: false,
            auction: _sampleAuction(),
            hasError: false,
            bidHistory: const [],
            isLoading: false,
            onBrowseHome: () {},
            onRequireLogin: () {},
            onReviewOrders: () {},
            onOpenOrder: (_) {},
            onPlaceBid: (_) {},
            onSetAutoBid: (_) {},
            onBuyNow: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review orders'), findsOneWidget);
      expect(find.text('Set auto-bid ceiling'), findsNothing);
      expect(find.textContaining('Bid from'), findsNothing);
    },
  );

  testWidgets('renders fallback state when auction detail is unavailable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: AuctionDetailView(
          heroTag: null,
          userId: null,
          isSubmitting: false,
          auction: null,
          hasError: false,
          bidHistory: const [],
          isLoading: false,
          onBrowseHome: () {},
          onRequireLogin: () {},
          onReviewOrders: () {},
          onOpenOrder: (_) {},
          onPlaceBid: (_) {},
          onSetAutoBid: (_) {},
          onBuyNow: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Listing details are on the way'), findsOneWidget);
    expect(find.text('Browse live auctions'), findsOneWidget);
    expect(find.text('Item details'), findsNothing);
  });

  testWidgets('renders error fallback when detail fails to load', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: AuctionDetailView(
          heroTag: null,
          userId: null,
          isSubmitting: false,
          auction: null,
          hasError: true,
          bidHistory: const [],
          isLoading: false,
          onBrowseHome: () {},
          onRequireLogin: () {},
          onReviewOrders: () {},
          onOpenOrder: (_) {},
          onPlaceBid: (_) {},
          onSetAutoBid: (_) {},
          onBuyNow: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unavailable'), findsOneWidget);
    expect(find.text('Browse live auctions'), findsOneWidget);
    expect(find.text('Item details'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      localeResolutionCallback: resolveAppLocale,
      home: child,
    );
  }
}

AuctionDetailViewData _sampleAuction() {
  return AuctionDetailViewData(
    id: 'auction-live',
    itemId: 'item-live',
    titleSnapshot: 'Signed Album',
    heroImageUrl: 'https://example.com/1.jpg',
    imageUrls: const <String>[
      'https://example.com/1.jpg',
      'https://example.com/2.jpg',
    ],
    description: 'Factory-sealed with hologram proof.',
    categorySub: 'IDOL_MD',
    condition: 'LIKE_NEW',
    sellerId: 'seller1',
    status: 'LIVE',
    currentPrice: 13200,
    buyNowPrice: 18000,
    orderId: null,
    endAt: DateTime.utc(2026, 4, 1, 18),
  );
}
