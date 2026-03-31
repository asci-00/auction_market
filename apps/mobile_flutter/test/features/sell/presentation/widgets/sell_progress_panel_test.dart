import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/features/sell/presentation/widgets/sell_progress_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows step progress and not-saved draft state', (tester) async {
    await tester.pumpWidget(
      const _TestApp(
        child: SellProgressPanel(
          categoryReady: true,
          detailsReady: true,
          pricingReady: false,
          imagesReady: false,
          publishReady: false,
          currentDraftId: null,
          hasUnsavedChanges: false,
          lastSavedAt: null,
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Publishing progress'), findsOneWidget);
    expect(find.text('2 of 5 steps ready'), findsOneWidget);
    expect(find.text('Not saved yet'), findsOneWidget);
    expect(find.text('Choose a category'), findsOneWidget);
    expect(find.text('Preview and publish'), findsOneWidget);
  });

  testWidgets('shows unsaved and saved draft states', (tester) async {
    await tester.pumpWidget(
      _TestApp(
        child: SellProgressPanel(
          categoryReady: true,
          detailsReady: true,
          pricingReady: true,
          imagesReady: true,
          publishReady: true,
          currentDraftId: 'draft-42',
          hasUnsavedChanges: true,
          lastSavedAt: DateTime(2026, 3, 31, 9, 30),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Unsaved changes'), findsOneWidget);
    expect(find.text('Editing draft #draft-42'), findsOneWidget);

    await tester.pumpWidget(
      _TestApp(
        child: SellProgressPanel(
          categoryReady: true,
          detailsReady: true,
          pricingReady: true,
          imagesReady: true,
          publishReady: true,
          currentDraftId: 'draft-42',
          hasUnsavedChanges: false,
          lastSavedAt: DateTime(2026, 3, 31, 9, 30),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Draft saved'), findsOneWidget);
    expect(find.textContaining('Latest save:'), findsOneWidget);
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
      home: Scaffold(body: Center(child: child)),
    );
  }
}
