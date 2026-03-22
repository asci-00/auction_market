import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
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
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetQuery() {
    _controller.clear();
    setState(() {
      _query = '';
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
          tokens.space8,
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
            onChanged: (value) => setState(() => _query = value.trim()),
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
          SearchResultsGrid(
            query: _query,
            onResetQuery: _resetQuery,
          ),
        ],
      ),
    );
  }
}
