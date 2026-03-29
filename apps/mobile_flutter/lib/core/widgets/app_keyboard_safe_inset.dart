import 'package:flutter/material.dart';

class AppKeyboardSafeInset extends StatelessWidget {
  const AppKeyboardSafeInset({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.useSafeArea = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    Widget content = SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (useSafeArea) {
      content = SafeArea(
        top: false,
        child: content,
      );
    }

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: content,
    );
  }
}
