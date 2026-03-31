import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/search/data/search_auction_summary.dart';
import 'package:auction_market_mobile/features/search/presentation/search_results_layout.dart';
import 'package:auction_market_mobile/features/search/presentation/widgets/search_results_layout_toggle.dart';
import 'package:auction_market_mobile/features/search/presentation/widgets/search_results_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders compact search results without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SizedBox(
          width: 360,
          child: SearchResultsList(
            results: [
              SearchAuctionSummary(
                id: 'auction-1',
                title: 'Vintage coin lot with certificate',
                categoryMain: 'PRECIOUS',
                categorySub: 'COIN',
                currentPrice: 280000,
                bidCount: 14,
                heroImageUrl: null,
                buyNowPrice: 360000,
                endAt: null,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Vintage coin lot with certificate'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('layout toggle reports both directions and flips tooltip', (
    tester,
  ) async {
    const locale = Locale('en');
    final l10n = await AppLocalizations.delegate.load(locale);
    SearchResultsLayout layout = SearchResultsLayout.grid;

    Future<void> pumpToggle() async {
      await tester.pumpWidget(
        _TestApp(
          locale: locale,
          child: SearchResultsLayoutToggle(
            layout: layout,
            onChanged: (nextLayout) => layout = nextLayout,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpToggle();
    expect(find.byTooltip(l10n.searchLayoutSwitchToList), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.searchLayoutSwitchToList));
    await pumpToggle();

    expect(layout, SearchResultsLayout.list);
    expect(find.byTooltip(l10n.searchLayoutSwitchToGrid), findsOneWidget);

    await tester.tap(find.byTooltip(l10n.searchLayoutSwitchToGrid));
    await pumpToggle();

    expect(layout, SearchResultsLayout.grid);
    expect(find.byTooltip(l10n.searchLayoutSwitchToList), findsOneWidget);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child, this.locale});

  final Widget child;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedAppLocales,
      locale: locale,
      localeResolutionCallback: resolveAppLocale,
      home: Scaffold(body: Center(child: child)),
    );
  }
}
