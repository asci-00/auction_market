import 'package:flutter/material.dart';

class AppPageEntrance extends StatelessWidget {
  const AppPageEntrance({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: animatedChild,
          ),
        );
      },
    );
  }
}

class AppStaggeredReveal extends StatefulWidget {
  const AppStaggeredReveal({
    super.key,
    required this.index,
    required this.child,
    this.axis = Axis.vertical,
  });

  final int index;
  final Widget child;
  final Axis axis;

  @override
  State<AppStaggeredReveal> createState() => _AppStaggeredRevealState();
}

class AppStaggeredItem extends AppStaggeredReveal {
  const AppStaggeredItem({
    super.key,
    required super.index,
    required super.child,
    super.axis,
  });
}

class _AppStaggeredRevealState extends State<AppStaggeredReveal> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    final cappedIndex = widget.index.clamp(0, 5);
    Future<void>.delayed(Duration(milliseconds: cappedIndex * 30), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final offset = switch (widget.axis) {
      Axis.horizontal => const Offset(0.04, 0),
      Axis.vertical => const Offset(0, 0.04),
    };

    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      offset: _isVisible ? Offset.zero : offset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        opacity: _isVisible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}
