import 'package:auction_market_mobile/core/l10n/app_localization.dart';
import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/core/widgets/app_page_insets.dart';
import 'package:auction_market_mobile/core/widgets/app_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'reserves the measured page-level bottom bar height for body content',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedAppLocales,
          localeResolutionCallback: resolveAppLocale,
          home: AppPageScaffold(
            bottomBar: const SizedBox(height: 84),
            body: Builder(
              builder: (context) =>
                  Text(context.pageBottomInset.toStringAsFixed(0)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('84'), findsOneWidget);
    },
  );

  testWidgets('settings app bar action pushes the settings route', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const AppPageScaffold(title: 'Test', body: SizedBox.shrink()),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const Scaffold(body: Text('settings route')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedAppLocales,
        localeResolutionCallback: resolveAppLocale,
        locale: const Locale('en'),
        routerConfig: router,
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open settings'));
    await tester.pumpAndSettle();

    expect(find.text('settings route'), findsOneWidget);
  });
}
