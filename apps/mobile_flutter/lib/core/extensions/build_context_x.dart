import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsService;
import 'package:go_router/go_router.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  ScaffoldMessengerState get messenger => ScaffoldMessenger.of(this);
  NavigatorState get navigator => Navigator.of(this);
  GoRouter get router => GoRouter.of(this);

  void showSnackBarMessage(String message, {bool clearExisting = true}) {
    _showToast(message, clearExisting: clearExisting, isError: false);
  }

  void showErrorSnackBar(String message, {bool clearExisting = true}) {
    _showToast(message, clearExisting: clearExisting, isError: true);
  }

  void _showToast(
    String message, {
    required bool clearExisting,
    required bool isError,
  }) {
    final scheme = colorScheme;
    final backgroundColor = isError ? scheme.error : scheme.inverseSurface;
    final foregroundColor = isError ? scheme.onError : scheme.onInverseSurface;
    final messengerState = messenger;
    if (clearExisting) {
      messengerState.clearSnackBars();
    }

    final direction = Directionality.maybeOf(this) ?? TextDirection.ltr;
    SemanticsService.announce(message, direction);

    messengerState.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2200),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Semantics(
          liveRegion: true,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
