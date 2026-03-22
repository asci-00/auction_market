import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  ScaffoldMessengerState get messenger => ScaffoldMessenger.of(this);
  NavigatorState get navigator => Navigator.of(this);

  void showSnackBarMessage(
    String message, {
    bool clearExisting = true,
  }) {
    if (clearExisting) {
      messenger.hideCurrentSnackBar();
    }

    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showErrorSnackBar(
    String message, {
    bool clearExisting = true,
  }) {
    if (clearExisting) {
      messenger.hideCurrentSnackBar();
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
      ),
    );
  }
}
