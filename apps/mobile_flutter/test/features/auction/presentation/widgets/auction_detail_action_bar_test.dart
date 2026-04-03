import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/auction/data/auction_detail_view_data.dart';
import 'package:auction_market_mobile/features/auction/presentation/widgets/auction_detail_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows bid pending copy and disables other buyer actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: AuctionDetailActionBar(
          auction: _sampleAuction(),
          userId: 'buyer1',
          submissionState: AuctionDetailSubmissionState.bidding,
          onBrowseHome: () {},
          onRequireLogin: () {},
          onReviewOrders: () {},
          onOpenOrder: () {},
          onPlaceBid: () {},
          onSetAutoBid: () {},
          onBuyNow: () {},
        ),
      ),
    );

    expect(find.textContaining('Submitting your bid now.'), findsOneWidget);
    expect(find.text('Submitting bid...'), findsOneWidget);
    expect(find.textContaining('Buy now'), findsOneWidget);
    expect(find.textContaining('18,000'), findsOneWidget);
    expect(find.text('Set auto-bid ceiling'), findsOneWidget);

    final filledButton = tester.widget<FilledButton>(
      find.byType(FilledButton).first,
    );
    final outlinedButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton).first,
    );
    final textButton = tester.widget<TextButton>(find.byType(TextButton).first);

    expect(filledButton.onPressed, isNull);
    expect(outlinedButton.onPressed, isNull);
    expect(textButton.onPressed, isNull);
  });

  testWidgets('shows buy now pending copy only for the active CTA', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: AuctionDetailActionBar(
          auction: _sampleAuction(),
          userId: 'buyer1',
          submissionState: AuctionDetailSubmissionState.buyingNow,
          onBrowseHome: () {},
          onRequireLogin: () {},
          onReviewOrders: () {},
          onOpenOrder: () {},
          onPlaceBid: () {},
          onSetAutoBid: () {},
          onBuyNow: () {},
        ),
      ),
    );

    expect(
      find.text(
        'Processing buy now. Other actions will reopen as soon as this step finishes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Processing buy now...'), findsOneWidget);
    expect(find.textContaining('Bid from'), findsOneWidget);
    expect(find.text('Set auto-bid ceiling'), findsOneWidget);
  });

  testWidgets('shows auto-bid pending copy and disables other buyer actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        child: AuctionDetailActionBar(
          auction: _sampleAuction(),
          userId: 'buyer1',
          submissionState: AuctionDetailSubmissionState.savingAutoBid,
          onBrowseHome: () {},
          onRequireLogin: () {},
          onReviewOrders: () {},
          onOpenOrder: () {},
          onPlaceBid: () {},
          onSetAutoBid: () {},
          onBuyNow: () {},
        ),
      ),
    );

    expect(
      find.text(
        'Saving your auto-bid ceiling now. Other actions will reopen as soon as this step finishes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Saving auto-bid...'), findsOneWidget);

    final filledButton = tester.widget<FilledButton>(
      find.byType(FilledButton).first,
    );
    final outlinedButton = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton).first,
    );
    final textButton = tester.widget<TextButton>(find.byType(TextButton).first);

    expect(filledButton.onPressed, isNull);
    expect(outlinedButton.onPressed, isNull);
    expect(textButton.onPressed, isNull);
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
      home: Scaffold(body: child),
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
