import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/features/auction/data/auction_detail_view_data.dart';
import 'package:auction_market_mobile/features/auction/presentation/widgets/auction_detail_description_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders item description and metadata chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        locale: const Locale('en'),
        localeResolutionCallback: resolveAppLocale,
        home: const Scaffold(
          body: AuctionDetailDescriptionPanel(
            auction: AuctionDetailViewData(
              id: 'auction-live',
              itemId: 'item-live',
              titleSnapshot: 'Signed Album',
              heroImageUrl: 'https://example.com/hero.jpg',
              imageUrls: <String>[
                'https://example.com/hero.jpg',
                'https://example.com/detail-1.jpg',
              ],
              description: 'Factory-sealed with hologram proof.',
              categorySub: 'IDOL_MD',
              condition: 'LIKE_NEW',
              sellerId: 'seller1',
              status: 'LIVE',
              currentPrice: 12000,
              buyNowPrice: 18000,
              orderId: null,
              endAt: null,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Item details'), findsOneWidget);
    expect(find.text('Factory-sealed with hologram proof.'), findsOneWidget);
    expect(_findRichText('Condition  Like new'), findsOneWidget);
    expect(_findRichText('Category  Idol merchandise'), findsOneWidget);
  });
}

Finder _findRichText(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText() == text,
  );
}
