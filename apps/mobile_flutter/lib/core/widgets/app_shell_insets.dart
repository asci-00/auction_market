import 'package:flutter/widgets.dart';

class AppShellInsets extends InheritedWidget {
  const AppShellInsets({
    super.key,
    required this.bottomInset,
    required super.child,
  });

  final double bottomInset;

  static double? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppShellInsets>()
        ?.bottomInset;
  }

  @override
  bool updateShouldNotify(AppShellInsets oldWidget) {
    return bottomInset != oldWidget.bottomInset;
  }
}
