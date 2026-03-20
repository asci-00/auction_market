import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localization.dart';
import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final destinations = [
      (context.l10n.navHome, Icons.home_outlined, Icons.home_rounded),
      (
        context.l10n.navSearch,
        Icons.search_rounded,
        Icons.manage_search_rounded
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
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          0,
          tokens.screenPadding,
          tokens.space4,
        ),
        child: Container(
          padding: EdgeInsets.all(tokens.space2),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(tokens.heroRadius),
            border: Border.all(color: AppColors.panelSoft),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    label: destinations[i].$1,
                    icon: destinations[i].$2,
                    selectedIcon: destinations[i].$3,
                    isSelected: i == navigationShell.currentIndex,
                    onTap: () {
                      navigationShell.goBranch(
                        i,
                        initialLocation: i == navigationShell.currentIndex,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.space1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space2,
              vertical: tokens.space2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accentPrimary.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentPrimary.withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? AppColors.textInverse
                      : AppColors.textInverse.withValues(alpha: 0.72),
                ),
                SizedBox(height: tokens.space1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? AppColors.textInverse
                        : AppColors.textInverse.withValues(alpha: 0.72),
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
