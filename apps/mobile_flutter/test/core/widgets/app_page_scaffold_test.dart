import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/core/widgets/app_page_insets.dart';
import 'package:auction_market_mobile/core/widgets/app_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'reserves the measured page-level bottom bar height for body content',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
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
}
