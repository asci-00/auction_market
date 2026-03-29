import 'package:flutter/widgets.dart';

class AppPageInsets extends InheritedWidget {
  const AppPageInsets({
    super.key,
    required this.bottomInset,
    required super.child,
  });

  final double bottomInset;

  static double maybeBottomOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppPageInsets>()
            ?.bottomInset ??
        0;
  }

  @override
  bool updateShouldNotify(AppPageInsets oldWidget) {
    return bottomInset != oldWidget.bottomInset;
  }
}

extension AppPageInsetsX on BuildContext {
  double get pageBottomInset => AppPageInsets.maybeBottomOf(this);
}
