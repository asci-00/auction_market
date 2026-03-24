import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_formatters.dart';

class AppLiveCountdownText extends StatefulWidget {
  const AppLiveCountdownText({
    super.key,
    required this.targetTime,
    required this.builder,
    this.expiredBuilder,
  });

  final DateTime targetTime;
  final Widget Function(BuildContext context, String label) builder;
  final WidgetBuilder? expiredBuilder;

  @override
  State<AppLiveCountdownText> createState() => _AppLiveCountdownTextState();
}

class _AppLiveCountdownTextState extends State<AppLiveCountdownText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleTick();
  }

  @override
  void didUpdateWidget(covariant AppLiveCountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _scheduleTick();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.targetTime.difference(DateTime.now());
    final keyLabel = remaining.isNegative
        ? 'expired'
        : formatRelativeCountdown(context, remaining);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: remaining.isNegative
          ? KeyedSubtree(
              key: const ValueKey('expired'),
              child: widget.expiredBuilder?.call(context) ?? const SizedBox(),
            )
          : KeyedSubtree(
              key: ValueKey(keyLabel),
              child: widget.builder(context, keyLabel),
            ),
    );
  }

  void _scheduleTick() {
    _timer?.cancel();
    final remaining = widget.targetTime.difference(DateTime.now());
    if (remaining.isNegative) {
      return;
    }

    final interval = remaining.inMinutes <= 1
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);
    _timer = Timer.periodic(interval, (_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }
}
