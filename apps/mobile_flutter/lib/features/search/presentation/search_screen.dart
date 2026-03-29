import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_event_transformers.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_shell_insets.dart';
import '../../../core/widgets/app_status_badge.dart';
import 'widgets/search_filter_chips.dart';
import 'widgets/search_query_field.dart';
import 'widgets/search_results_grid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _searchDebounce = Duration(milliseconds: 300);

  final TextEditingController _controller = TextEditingController();
  late final Debouncer _queryDebouncer = Debouncer(_searchDebounce);
  String _query = '';
  String _debouncedQuery = '';

  @override
  void dispose() {
    _queryDebouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    final normalized = value.trim();
    setState(() => _query = normalized);

    if (normalized.isEmpty) {
      _queryDebouncer.cancel();
      setState(() => _debouncedQuery = '');
      return;
    }

    _queryDebouncer.run(() {
      if (!mounted) {
        return;
      }
      setState(() => _debouncedQuery = normalized);
    });
  }

  void _resetQuery() {
    _queryDebouncer.cancel();
    _controller.clear();
    setState(() {
      _query = '';
      _debouncedQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPageScaffold(
      title: context.l10n.searchTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8 + context.shellBottomInset,
        ),
        children: [
          AppEditorialHero(
            eyebrow: context.l10n.searchHeroEyebrow,
            title: context.l10n.searchHeroTitle,
            description: context.l10n.searchHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.pending),
              AppStatusBadge(kind: AppStatusKind.buyNow),
            ],
            tone: AppPanelTone.surface,
          ),
          SizedBox(height: tokens.space5),
          SearchQueryField(
            controller: _controller,
            query: _query,
            onChanged: _onQueryChanged,
            onClear: _resetQuery,
          ),
          SizedBox(height: tokens.space3),
          const SearchFilterChips(),
          SizedBox(height: tokens.space6),
          AppSectionHeading(
            title: context.l10n.searchResultsTitle,
            subtitle: context.l10n.searchResultsSubtitle,
          ),
          SizedBox(height: tokens.space4),
          SearchResultsGrid(query: _debouncedQuery, onResetQuery: _resetQuery),
        ],
      ),
    );
  }
}
