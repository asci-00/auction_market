import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/locale_menu_action.dart';
import '../theme/app_theme.dart';
import 'app_motion.dart';
import 'app_shell_insets.dart';

class AppPageScaffold extends StatefulWidget {
  const AppPageScaffold({
    super.key,
    this.title,
    this.largeTitle,
    this.subtitle,
    this.actions,
    this.bottomBar,
    this.extendBody = false,
    this.extendBodyBehindAppBar = true,
    this.bottomContentInset,
    required this.body,
  });

  final String? title;
  final String? largeTitle;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final double? bottomContentInset;
  final Widget body;

  @override
  State<AppPageScaffold> createState() => _AppPageScaffoldState();
}

class _AppPageScaffoldState extends State<AppPageScaffold> {
  static const _bodyPaddingKey = ValueKey<String>(
    'app-page-scaffold-body-padding',
  );

  double _localBottomBarInset = 0;

  void _updateBottomBarInset(double value) {
    if ((_localBottomBarInset - value).abs() < 0.5) {
      return;
    }
    setState(() => _localBottomBarInset = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final brightness = theme.brightness;
    final hasAppBar = widget.title != null || widget.largeTitle != null;
    final shellBottomInset = AppShellInsets.maybeOf(context);
    final resolvedBottomInset =
        (shellBottomInset ?? 0) +
        _localBottomBarInset +
        (widget.bottomContentInset ?? 0);
    final useSafeAreaBottom = resolvedBottomInset == 0;
    final appBarActions = [
      if (widget.actions case final customActions?) ...customActions,
      const AppLocaleMenuAction(),
      SizedBox(width: tokens.space2),
    ];

    return Scaffold(
      extendBody: widget.extendBody,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      appBar: widget.title == null && widget.largeTitle == null
          ? null
          : AppBar(
              toolbarHeight: widget.largeTitle != null ? 92 : kToolbarHeight,
              titleSpacing: tokens.screenPadding,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.panelOverlayFor(brightness).withValues(
                        alpha: brightness == Brightness.dark ? 0.82 : 0.7,
                      ),
                    ),
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.largeTitle ?? widget.title!,
                    style: widget.largeTitle != null
                        ? theme.textTheme.headlineLarge
                        : theme.textTheme.titleLarge,
                  ),
                  if (widget.subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: tokens.space1),
                      child: Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
              actions: appBarActions,
            ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgBaseFor(brightness),
              AppColors.bgSurfaceFor(brightness),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -60,
              child: _GlowOrb(
                size: 180,
                color: AppColors.accentPrimarySoftFor(brightness).withValues(
                  alpha: brightness == Brightness.dark ? 0.32 : 0.85,
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: -70,
              child: _GlowOrb(
                size: 200,
                color:
                    (brightness == Brightness.dark
                            ? AppColors.panelSoftDark
                            : AppColors.sand)
                        .withValues(
                          alpha: brightness == Brightness.dark ? 0.38 : 0.9,
                        ),
              ),
            ),
            SafeArea(
              top: hasAppBar,
              bottom: useSafeAreaBottom,
              child: Padding(
                key: _bodyPaddingKey,
                padding: EdgeInsets.only(
                  bottom: useSafeAreaBottom ? 0 : resolvedBottomInset,
                ),
                child: AppPageEntrance(child: widget.body),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.bottomBar == null
          ? null
          : _MeasureInset(
              onChange: (size) => _updateBottomBarInset(size.height),
              child: widget.bottomBar!,
            ),
    );
  }
}

class _MeasureInset extends StatefulWidget {
  const _MeasureInset({required this.onChange, required this.child});

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureInset> createState() => _MeasureInsetState();
}

class _MeasureInsetState extends State<_MeasureInset> {
  Size? _lastSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return;
      }

      final newSize = renderObject.size;
      if (_lastSize == newSize) {
        return;
      }

      _lastSize = newSize;
      widget.onChange(newSize);
    });

    return widget.child;
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
