import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
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
    return SegmentedButton<SearchResultsLayout>(
      multiSelectionEnabled: false,
      emptySelectionAllowed: false,
      showSelectedIcon: false,
      segments: [
        ButtonSegment<SearchResultsLayout>(
          value: SearchResultsLayout.grid,
          icon: const Icon(Icons.grid_view_rounded),
          label: Text(context.l10n.searchLayoutGrid),
        ),
        ButtonSegment<SearchResultsLayout>(
          value: SearchResultsLayout.list,
          icon: const Icon(Icons.view_agenda_rounded),
          label: Text(context.l10n.searchLayoutList),
        ),
      ],
      selected: {layout},
      onSelectionChanged: (selection) {
        final nextLayout = selection.firstOrNull;
        if (nextLayout != null && nextLayout != layout) {
          onChanged(nextLayout);
        }
      },
    );
  }
}
