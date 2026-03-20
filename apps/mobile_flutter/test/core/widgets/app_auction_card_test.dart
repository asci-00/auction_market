import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/core/widgets/app_auction_card.dart';
import 'package:auction_market_mobile/core/widgets/app_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders without overflow in the home rail size', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(
          width: 236,
          height: 352,
          child: AppAuctionCard(
            title: 'Limited Edition Auction Title That Can Span Two Lines',
            priceLabel: '₩120,000',
            metaLabel: 'Ends Mar 20, 23:59',
            bidCountLabel: '23 bids',
            badgeKind: AppStatusKind.endingSoon,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow in the search grid size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(
          width: 168,
          height: 262,
          child: AppAuctionCard(
            title: 'A compact card title that should still remain stable',
            priceLabel: '₩9,900,000',
            metaLabel: 'Ends Mar 20, 23:59',
            bidCountLabel: '102 bids',
            badgeKind: AppStatusKind.buyNow,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      localeResolutionCallback: resolveAppLocale,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }
}
