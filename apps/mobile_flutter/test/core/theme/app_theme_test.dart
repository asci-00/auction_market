import 'package:auction_market_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('returns warm dark surfaces for dark mode', () {
      expect(AppColors.bgBaseFor(Brightness.dark), AppColors.bgBaseDark);
      expect(AppColors.bgSurfaceFor(Brightness.dark), AppColors.bgSurfaceDark);
      expect(
        AppColors.panelOverlayFor(Brightness.dark),
        AppColors.panelOverlayDark,
      );
    });

    test('returns editorial light surfaces for light mode', () {
      expect(AppColors.bgBaseFor(Brightness.light), AppColors.bgBase);
      expect(AppColors.bgSurfaceFor(Brightness.light), AppColors.bgSurface);
      expect(AppColors.textPrimaryFor(Brightness.light), AppColors.textPrimary);
    });
  });
}
