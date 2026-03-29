import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const AnimationStyle appBottomSheetAnimationStyle = AnimationStyle(
  duration: Duration(milliseconds: 320),
  reverseDuration: Duration(milliseconds: 220),
);

Color resolveAppModalBarrierColor(Brightness brightness) {
  return AppColors.panelOverlayFor(
    brightness,
  ).withValues(alpha: brightness == Brightness.dark ? 0.34 : 0.2);
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useBlur = true,
}) {
  final brightness = Theme.of(context).brightness;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: resolveAppModalBarrierColor(brightness),
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(fade);

      final transitionedChild = FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );

      if (!useBlur) {
        return transitionedChild;
      }

      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6 * animation.value,
          sigmaY: 6 * animation.value,
        ),
        child: transitionedChild,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(type: MaterialType.transparency, child: builder(context));
    },
  );
}

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
}) {
  final brightness = Theme.of(context).brightness;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    barrierColor: resolveAppModalBarrierColor(brightness),
    sheetAnimationStyle: appBottomSheetAnimationStyle,
    builder: builder,
  );
}
