import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bgBase = Color(0xFFF6F1EA);
  static const bgSurface = Color(0xFFFFFBF5);
  static const bgElevated = Color(0xFFF1E6D8);
  static const bgMuted = Color(0xFFF9F4ED);
  static const bgBaseDark = Color(0xFF11100E);
  static const bgSurfaceDark = Color(0xFF1A1715);
  static const bgElevatedDark = Color(0xFF24201D);
  static const bgMutedDark = Color(0xFF181614);
  static const panel = Color(0xFF1E1C1A);
  static const panelSoft = Color(0xFF2B2824);
  static const panelDark = Color(0xFF2A2521);
  static const panelSoftDark = Color(0xFF3A342F);
  static const textPrimary = Color(0xFF201D19);
  static const textSecondary = Color(0xFF6E665F);
  static const textMuted = Color(0xFF978D84);
  static const textPrimaryDark = Color(0xFFF4EDE3);
  static const textSecondaryDark = Color(0xFFCBBEAE);
  static const textMutedDark = Color(0xFF9F9489);
  static const textInverse = Color(0xFFF8F4EE);
  static const accentPrimary = Color(0xFFB86A3B);
  static const accentPrimarySoft = Color(0xFFE5C8B0);
  static const accentPrimarySoftDark = Color(0xFF765746);
  static const accentUrgent = Color(0xFFD85B45);
  static const accentSuccess = Color(0xFF6D8A74);
  static const sand = Color(0xFFEADCC9);
  static const borderSoft = Color(0xFFE5D9CC);
  static const borderStrong = Color(0xFFD4C2AE);
  static const borderSoftDark = Color(0xFF38322D);
  static const borderStrongDark = Color(0xFF4A423B);
  static const overlay = Color(0x251F1A15);
  static const overlayDark = Color(0x4020100F);
  static const panelOverlay = Color(0xCC1E1C1A);
  static const panelOverlayDark = Color(0xE6221F1C);

  static Color bgBaseFor(Brightness brightness) =>
      brightness == Brightness.dark ? bgBaseDark : bgBase;

  static Color bgSurfaceFor(Brightness brightness) =>
      brightness == Brightness.dark ? bgSurfaceDark : bgSurface;

  static Color bgElevatedFor(Brightness brightness) =>
      brightness == Brightness.dark ? bgElevatedDark : bgElevated;

  static Color bgMutedFor(Brightness brightness) =>
      brightness == Brightness.dark ? bgMutedDark : bgMuted;

  static Color panelFor(Brightness brightness) =>
      brightness == Brightness.dark ? panelDark : panel;

  static Color panelSoftFor(Brightness brightness) =>
      brightness == Brightness.dark ? panelSoftDark : panelSoft;

  static Color textPrimaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimaryDark : textPrimary;

  static Color textSecondaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondaryDark : textSecondary;

  static Color textMutedFor(Brightness brightness) =>
      brightness == Brightness.dark ? textMutedDark : textMuted;

  static Color borderSoftFor(Brightness brightness) =>
      brightness == Brightness.dark ? borderSoftDark : borderSoft;

  static Color borderStrongFor(Brightness brightness) =>
      brightness == Brightness.dark ? borderStrongDark : borderStrong;

  static Color overlayFor(Brightness brightness) =>
      brightness == Brightness.dark ? overlayDark : overlay;

  static Color panelOverlayFor(Brightness brightness) =>
      brightness == Brightness.dark ? panelOverlayDark : panelOverlay;

  static Color accentPrimarySoftFor(Brightness brightness) =>
      brightness == Brightness.dark ? accentPrimarySoftDark : accentPrimarySoft;
}

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.screenPadding,
    required this.cardRadius,
    required this.heroRadius,
    required this.sheetRadius,
    required this.inputHeight,
    required this.primaryButtonHeight,
    required this.stickyActionHeight,
    required this.navBarHeight,
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.space7,
    required this.space8,
  });

  final double screenPadding;
  final double cardRadius;
  final double heroRadius;
  final double sheetRadius;
  final double inputHeight;
  final double primaryButtonHeight;
  final double stickyActionHeight;
  final double navBarHeight;
  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space5;
  final double space6;
  final double space7;
  final double space8;

  @override
  AppThemeTokens copyWith({
    double? screenPadding,
    double? cardRadius,
    double? heroRadius,
    double? sheetRadius,
    double? inputHeight,
    double? primaryButtonHeight,
    double? stickyActionHeight,
    double? navBarHeight,
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
    double? space6,
    double? space7,
    double? space8,
  }) {
    return AppThemeTokens(
      screenPadding: screenPadding ?? this.screenPadding,
      cardRadius: cardRadius ?? this.cardRadius,
      heroRadius: heroRadius ?? this.heroRadius,
      sheetRadius: sheetRadius ?? this.sheetRadius,
      inputHeight: inputHeight ?? this.inputHeight,
      primaryButtonHeight: primaryButtonHeight ?? this.primaryButtonHeight,
      stickyActionHeight: stickyActionHeight ?? this.stickyActionHeight,
      navBarHeight: navBarHeight ?? this.navBarHeight,
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      space7: space7 ?? this.space7,
      space8: space8 ?? this.space8,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      screenPadding: Tween<double>(
        begin: screenPadding,
        end: other.screenPadding,
      ).transform(t),
      cardRadius: Tween<double>(
        begin: cardRadius,
        end: other.cardRadius,
      ).transform(t),
      heroRadius: Tween<double>(
        begin: heroRadius,
        end: other.heroRadius,
      ).transform(t),
      sheetRadius: Tween<double>(
        begin: sheetRadius,
        end: other.sheetRadius,
      ).transform(t),
      inputHeight: Tween<double>(
        begin: inputHeight,
        end: other.inputHeight,
      ).transform(t),
      primaryButtonHeight: Tween<double>(
        begin: primaryButtonHeight,
        end: other.primaryButtonHeight,
      ).transform(t),
      stickyActionHeight: Tween<double>(
        begin: stickyActionHeight,
        end: other.stickyActionHeight,
      ).transform(t),
      navBarHeight: Tween<double>(
        begin: navBarHeight,
        end: other.navBarHeight,
      ).transform(t),
      space1: Tween<double>(begin: space1, end: other.space1).transform(t),
      space2: Tween<double>(begin: space2, end: other.space2).transform(t),
      space3: Tween<double>(begin: space3, end: other.space3).transform(t),
      space4: Tween<double>(begin: space4, end: other.space4).transform(t),
      space5: Tween<double>(begin: space5, end: other.space5).transform(t),
      space6: Tween<double>(begin: space6, end: other.space6).transform(t),
      space7: Tween<double>(begin: space7, end: other.space7).transform(t),
      space8: Tween<double>(begin: space8, end: other.space8).transform(t),
    );
  }
}

class AppTheme {
  static const _tokens = AppThemeTokens(
    screenPadding: 20,
    cardRadius: 26,
    heroRadius: 34,
    sheetRadius: 30,
    inputHeight: 56,
    primaryButtonHeight: 56,
    stickyActionHeight: 104,
    navBarHeight: 86,
    space1: 4,
    space2: 8,
    space3: 12,
    space4: 16,
    space5: 20,
    space6: 24,
    space7: 32,
    space8: 40,
  );

  static ThemeData light() => _buildTheme(Brightness.light);

  static ThemeData dark() => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.accentPrimary,
      onPrimary: AppColors.textInverse,
      secondary: AppColors.accentSuccess,
      onSecondary: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      error: AppColors.accentUrgent,
      onError: AppColors.textInverse,
      surface: AppColors.bgSurfaceFor(brightness),
      onSurface: AppColors.textPrimaryFor(brightness),
    );

    final baseTextTheme =
        GoogleFonts.manropeTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ).apply(
          bodyColor: AppColors.textPrimaryFor(brightness),
          displayColor: AppColors.textPrimaryFor(brightness),
        );
    final displayTextTheme = GoogleFonts.cormorantGaramondTextTheme();

    final textTheme = baseTextTheme.copyWith(
      displayLarge: displayTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w600,
        height: 0.95,
        color: AppColors.textPrimaryFor(brightness),
      ),
      displayMedium: displayTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1,
        color: AppColors.textPrimaryFor(brightness),
      ),
      displaySmall: displayTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryFor(brightness),
      ),
      headlineLarge: displayTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryFor(brightness),
      ),
      headlineMedium: displayTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.05,
        color: AppColors.textPrimaryFor(brightness),
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondaryFor(brightness),
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        height: 1.55,
        color: AppColors.textPrimaryFor(brightness),
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryFor(brightness),
        height: 1.5,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: AppColors.textMutedFor(brightness),
        height: 1.45,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.bgBaseFor(brightness),
      colorScheme: colorScheme,
      textTheme: textTheme,
      dividerColor: AppColors.borderSoftFor(brightness),
      splashFactory: InkSparkle.splashFactory,
      extensions: const [_tokens],
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryFor(brightness),
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.bgSurfaceFor(brightness),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_tokens.cardRadius),
          side: BorderSide(color: AppColors.borderSoftFor(brightness)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurfaceFor(brightness),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        prefixIconColor: AppColors.textSecondaryFor(brightness),
        suffixIconColor: AppColors.textSecondaryFor(brightness),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textMutedFor(brightness),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_tokens.cardRadius),
          borderSide: BorderSide(color: AppColors.borderSoftFor(brightness)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_tokens.cardRadius),
          borderSide: BorderSide(color: AppColors.borderSoftFor(brightness)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_tokens.cardRadius),
          borderSide: const BorderSide(
            color: AppColors.accentPrimary,
            width: 1.4,
          ),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryFor(brightness),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSurfaceFor(brightness),
        selectedColor: AppColors.accentPrimarySoftFor(brightness),
        disabledColor: AppColors.bgMutedFor(brightness),
        side: BorderSide(color: AppColors.borderSoftFor(brightness)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimaryFor(brightness),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size.fromHeight(_tokens.primaryButtonHeight),
          backgroundColor: AppColors.accentPrimary,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(_tokens.primaryButtonHeight),
          foregroundColor: AppColors.textPrimaryFor(brightness),
          side: BorderSide(color: AppColors.borderStrongFor(brightness)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimaryFor(brightness)),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.bgSurfaceFor(brightness),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_tokens.sheetRadius),
          ),
        ),
      ),
    );
  }
}

extension AppThemeBuildContextX on BuildContext {
  AppThemeTokens get tokens => Theme.of(this).extension<AppThemeTokens>()!;
}
