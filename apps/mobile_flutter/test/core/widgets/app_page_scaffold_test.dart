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
          home: const AppPageScaffold(
            bottomBar: SizedBox(height: 84),
            body: SizedBox(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final pageInsets = tester.widget<AppPageInsets>(
        find.byType(AppPageInsets),
      );

      expect(pageInsets.bottomInset, closeTo(84, 0.5));
    },
  );
}
