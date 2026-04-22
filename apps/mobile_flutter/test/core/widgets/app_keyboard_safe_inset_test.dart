import 'package:auction_market_mobile/core/widgets/app_keyboard_safe_inset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adds bottom keyboard inset to animated padding', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: 120)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: AppKeyboardSafeInset(
              padding: EdgeInsets.only(bottom: 24),
              useSafeArea: false,
              child: SizedBox(height: 80, width: 100),
            ),
          ),
        ),
      ),
    );

    final animatedPadding = tester.widget<AnimatedPadding>(
      find.byType(AnimatedPadding),
    );
    final contentPadding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Padding),
      ),
    );

    expect(animatedPadding.padding, const EdgeInsets.only(bottom: 120));
    expect(contentPadding.padding, const EdgeInsets.only(bottom: 24));
  });
}
