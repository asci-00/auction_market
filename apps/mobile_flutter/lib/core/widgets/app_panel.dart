import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppPanelTone {
  surface,
  elevated,
  dark,
  soft,
}

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding,
    this.tone = AppPanelTone.surface,
    this.borderColor,
    this.blurSigma = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AppPanelTone tone;
  final Color? borderColor;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = switch (tone) {
      AppPanelTone.surface => (
          AppColors.bgSurface,
          borderColor ?? AppColors.borderSoft,
          AppColors.overlay.withValues(alpha: 0.08),
        ),
      AppPanelTone.elevated => (
          AppColors.bgElevated,
          borderColor ?? AppColors.borderStrong,
          AppColors.overlay.withValues(alpha: 0.12),
        ),
      AppPanelTone.dark => (
          AppColors.panel,
          borderColor ?? AppColors.panelSoft,
          Colors.black.withValues(alpha: 0.18),
        ),
      AppPanelTone.soft => (
          AppColors.bgMuted,
          borderColor ?? AppColors.borderSoft,
          AppColors.overlay.withValues(alpha: 0.04),
        ),
    };

    final decoratedChild = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: palette.$2),
        boxShadow: [
          BoxShadow(
            color: palette.$3,
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(tokens.space5),
        child: child,
      ),
    );

    if (blurSigma <= 0) {
      return decoratedChild;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: decoratedChild,
      ),
    );
  }
}
