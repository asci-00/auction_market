import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

FToast? _fToast;

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
    final fToast = (_fToast ??= FToast()..init(this));

    if (clearExisting) {
      fToast.removeCustomToast();
      fToast.removeQueuedCustomToasts();
    }

    fToast.showToast(
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(milliseconds: 2200),
      isDismissible: true,
      child: Container(
        width: mediaQuery.size.width * 0.9,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
