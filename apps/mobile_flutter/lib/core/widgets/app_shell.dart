import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localization.dart';
import '../theme/app_theme.dart';
import 'app_shell_insets.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  double _bottomInset = 0;

  void _updateBottomInset(double value) {
    if ((_bottomInset - value).abs() < 0.5) {
      return;
    }
    setState(() => _bottomInset = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fallbackInset =
        tokens.navBarHeight + MediaQuery.viewPaddingOf(context).bottom;
    final brightness = Theme.of(context).brightness;
    final plateColor = AppColors.panelOverlayFor(
      brightness,
    ).withValues(alpha: brightness == Brightness.dark ? 0.78 : 0.68);
    final borderColor =
        (brightness == Brightness.dark
                ? AppColors.borderSoftDark
                : AppColors.textInverse)
            .withValues(alpha: brightness == Brightness.dark ? 0.32 : 0.08);
    final destinations = [
      (context.l10n.navHome, Icons.home_outlined, Icons.home_rounded),
      (
        context.l10n.navSearch,
        Icons.search_rounded,
        Icons.manage_search_rounded,
      ),
      (context.l10n.navSell, Icons.add_box_outlined, Icons.add_box_rounded),
      (
        context.l10n.navActivity,
        Icons.local_activity_outlined,
        Icons.local_activity_rounded,
      ),
      (context.l10n.navMy, Icons.person_outline_rounded, Icons.person_rounded),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: AppShellInsets(
        bottomInset: _bottomInset > 0 ? _bottomInset : fallbackInset,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: _MeasureSize(
        onChange: (size) => _updateBottomInset(size.height),
        child: SafeArea(
          minimum: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            0,
            tokens.screenPadding,
            tokens.space4,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.heroRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: EdgeInsets.all(tokens.space2),
                decoration: BoxDecoration(
                  color: plateColor,
                  borderRadius: BorderRadius.circular(tokens.heroRadius),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: brightness == Brightness.dark ? 0.3 : 0.16,
                      ),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ...destinations.mapIndexed(
                      (i, destination) => Expanded(
                        child: _NavItem(
                          label: destination.$1,
                          icon: destination.$2,
                          selectedIcon: destination.$3,
                          isSelected: i == widget.navigationShell.currentIndex,
                          onTap: () {
                            widget.navigationShell.goBranch(
                              i,
                              initialLocation:
                                  i == widget.navigationShell.currentIndex,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends StatefulWidget {
  const _MeasureSize({required this.onChange, required this.child});

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<_MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<_MeasureSize> {
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final brightness = theme.brightness;
    final foregroundColor = brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textInverse;
    final mutedForegroundColor = foregroundColor.withValues(alpha: 0.72);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space2 + 2,
              vertical: tokens.space2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? foregroundColor.withValues(
                      alpha: brightness == Brightness.dark ? 0.1 : 0.08,
                    )
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? foregroundColor.withValues(
                        alpha: brightness == Brightness.dark ? 0.12 : 0.08,
                      )
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  width: isSelected ? 26 : 0,
                  margin: EdgeInsets.only(bottom: tokens.space1),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimarySoftFor(brightness),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? foregroundColor : mutedForegroundColor,
                ),
                SizedBox(height: tokens.space1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected ? foregroundColor : mutedForegroundColor,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
