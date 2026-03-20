import 'package:flutter/material.dart';

import '../l10n/locale_menu_action.dart';
import '../theme/app_theme.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    this.title,
    this.largeTitle,
    this.subtitle,
    this.actions,
    this.bottomBar,
    this.extendBody = false,
    required this.body,
  });

  final String? title;
  final String? largeTitle;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool extendBody;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final appBarActions = [
      if (actions case final customActions?) ...customActions,
      const AppLocaleMenuAction(),
      SizedBox(width: tokens.space2),
    ];

    return Scaffold(
      extendBody: extendBody,
      appBar: title == null && largeTitle == null
          ? null
          : AppBar(
              toolbarHeight: largeTitle != null ? 92 : kToolbarHeight,
              titleSpacing: tokens.screenPadding,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    largeTitle ?? title!,
                    style: largeTitle != null
                        ? theme.textTheme.headlineLarge
                        : theme.textTheme.titleLarge,
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: tokens.space1),
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
              actions: appBarActions,
            ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgBase, AppColors.bgSurface],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -60,
              child: _GlowOrb(
                size: 180,
                color: AppColors.accentPrimarySoft.withValues(alpha: 0.55),
              ),
            ),
            Positioned(
              top: 140,
              right: -70,
              child: _GlowOrb(
                size: 200,
                color: AppColors.sand.withValues(alpha: 0.6),
              ),
            ),
            SafeArea(
              top: false,
              bottom: bottomBar == null,
              child: body,
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

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
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
