import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:auction_market_mobile/core/widgets/app_sticky_action_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'adds persistent system bottom inset to the sticky action bar padding',
    (tester) async {
      const bottomInset = 24.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(bottom: bottomInset),
            viewPadding: EdgeInsets.only(bottom: bottomInset),
          ),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: AppStickyActionBar(
                title: 'Bid now',
                subtitle: 'Complete before the auction closes',
                child: SizedBox(height: 48),
              ),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);

      expect(padding.padding, const EdgeInsets.fromLTRB(20, 12, 20, 24));
    },
  );
}
