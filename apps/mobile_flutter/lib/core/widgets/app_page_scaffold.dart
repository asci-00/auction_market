import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localization.dart';
import '../theme/app_theme.dart';
import 'app_motion.dart';
import 'app_page_insets.dart';
import 'app_shell_insets.dart';

class AppPageScaffold extends StatefulWidget {
  const AppPageScaffold({
    super.key,
    this.title,
    this.largeTitle,
    this.subtitle,
    this.actions,
    this.showSettingsAction = true,
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
  final bool showSettingsAction;
  final Widget? bottomBar;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final double? bottomContentInset;
  final Widget body;

  @override
  State<AppPageScaffold> createState() => _AppPageScaffoldState();
}

class _AppPageScaffoldState extends State<AppPageScaffold> {
  double _measuredBottomBarInset = 0;

  void _updateBottomBarInset(double value) {
    if ((_measuredBottomBarInset - value).abs() < 0.5) {
      return;
    }
    setState(() => _measuredBottomBarInset = value);
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
        _measuredBottomBarInset +
        (widget.bottomContentInset ?? 0);
    final useSafeAreaBottom =
        resolvedBottomInset == 0 && widget.bottomBar == null;
    final appBarActions = [
      if (widget.actions case final customActions?) ...customActions,
      if (widget.showSettingsAction)
        IconButton(
          tooltip: context.l10n.settingsOpenAction,
          icon: const Icon(Icons.tune_rounded),
          onPressed: () => context.push('/settings'),
        ),
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
              top: widget.extendBodyBehindAppBar && hasAppBar,
              bottom: useSafeAreaBottom,
              child: AppPageInsets(
                bottomInset: resolvedBottomInset,
                child: AppPageEntrance(child: widget.body),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.bottomBar == null
          ? null
          : _MeasuredBottomBar(
              onSizeChanged: _updateBottomBarInset,
              child: widget.bottomBar!,
            ),
    );
  }
}

class _MeasuredBottomBar extends StatefulWidget {
  const _MeasuredBottomBar({required this.onSizeChanged, required this.child});

  final ValueChanged<double> onSizeChanged;
  final Widget child;

  @override
  State<_MeasuredBottomBar> createState() => _MeasuredBottomBarState();
}

class _MeasuredBottomBarState extends State<_MeasuredBottomBar> {
  Size? _lastSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        return;
      }

      final newSize = renderObject.size;
      if (_lastSize == newSize) {
        return;
      }
      _lastSize = newSize;
      widget.onSizeChanged(newSize.height);
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
