import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../search_results_layout.dart';

class SearchResultsLayoutToggle extends StatelessWidget {
  const SearchResultsLayoutToggle({
    super.key,
    required this.layout,
    required this.onChanged,
  });

  final SearchResultsLayout layout;
  final ValueChanged<SearchResultsLayout> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final nextLayout = layout == SearchResultsLayout.grid
        ? SearchResultsLayout.list
        : SearchResultsLayout.grid;
    final icon = nextLayout == SearchResultsLayout.list
        ? Icons.view_agenda_rounded
        : Icons.grid_view_rounded;
    final tooltip = nextLayout == SearchResultsLayout.list
        ? context.l10n.searchLayoutSwitchToList
        : context.l10n.searchLayoutSwitchToGrid;

    return Material(
      color: AppColors.bgSurfaceFor(brightness),
      borderRadius: BorderRadius.circular(18),
      child: IconButton(
        tooltip: tooltip,
        onPressed: () => onChanged(nextLayout),
        icon: Icon(icon, color: AppColors.textPrimaryFor(brightness)),
      ),
    );
  }
}
