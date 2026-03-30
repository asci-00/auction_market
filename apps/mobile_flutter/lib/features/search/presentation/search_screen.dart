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
import '../application/search_auction_filter.dart';
import 'search_results_layout.dart';
import 'widgets/search_filter_chips.dart';
import 'widgets/search_query_field.dart';
import 'widgets/search_results_grid.dart';
import 'widgets/search_results_layout_toggle.dart';

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
  SearchFilterState _filters = const SearchFilterState();
  SearchResultsLayout _resultsLayout = SearchResultsLayout.grid;

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

  void _cycleCategoryFilter() {
    setState(() {
      _filters = _filters.copyWith(
        category: nextSearchCategoryFilter(_filters.category),
      );
    });
  }

  void _cyclePriceFilter() {
    setState(() {
      _filters = _filters.copyWith(
        price: nextSearchPriceFilter(_filters.price),
      );
    });
  }

  void _toggleEndingSoon(bool selected) {
    setState(() {
      _filters = _filters.copyWith(endingSoonOnly: selected);
    });
  }

  void _toggleBuyNow(bool selected) {
    setState(() {
      _filters = _filters.copyWith(buyNowOnly: selected);
    });
  }

  void _resetFilters() {
    setState(() {
      _filters = const SearchFilterState();
    });
  }

  void _setResultsLayout(SearchResultsLayout layout) {
    setState(() {
      _resultsLayout = layout;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return AppPageScaffold(
      title: context.l10n.searchTitle,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.space4,
              tokens.screenPadding,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: AppEditorialHero(
                eyebrow: context.l10n.searchHeroEyebrow,
                title: context.l10n.searchHeroTitle,
                description: context.l10n.searchHeroDescription,
                badges: const [
                  AppStatusBadge(kind: AppStatusKind.pending),
                  AppStatusBadge(kind: AppStatusKind.buyNow),
                ],
                tone: AppPanelTone.surface,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchStickyQueryHeaderDelegate(
              tokens: tokens,
              brightness: brightness,
              child: SearchQueryField(
                controller: _controller,
                query: _query,
                onChanged: _onQueryChanged,
                onClear: _resetQuery,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.space3,
              tokens.screenPadding,
              tokens.space8 + context.shellBottomInset,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchFilterChips(
                    filters: _filters,
                    onCycleCategory: _cycleCategoryFilter,
                    onCyclePrice: _cyclePriceFilter,
                    onToggleEndingSoon: _toggleEndingSoon,
                    onToggleBuyNow: _toggleBuyNow,
                  ),
                  SizedBox(height: tokens.space6),
                  AppSectionHeading(
                    title: context.l10n.searchResultsTitle,
                    subtitle: context.l10n.searchResultsSubtitle,
                  ),
                  SizedBox(height: tokens.space3),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SearchResultsLayoutToggle(
                      layout: _resultsLayout,
                      onChanged: _setResultsLayout,
                    ),
                  ),
                  SizedBox(height: tokens.space4),
                  SearchResultsView(
                    query: _debouncedQuery,
                    filters: _filters,
                    layout: _resultsLayout,
                    onResetQuery: _resetQuery,
                    onResetFilters: _resetFilters,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchStickyQueryHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SearchStickyQueryHeaderDelegate({
    required this.tokens,
    required this.brightness,
    required this.child,
  });

  final AppThemeTokens tokens;
  final Brightness brightness;
  final Widget child;

  @override
  double get minExtent => tokens.inputHeight + tokens.space4 * 2;

  @override
  double get maxExtent => tokens.inputHeight + tokens.space4 * 2;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final borderColor = AppColors.borderSoftFor(
      brightness,
    ).withValues(alpha: overlapsContent ? 0.85 : 0.35);
    final shadowColor = AppColors.overlayFor(brightness).withValues(alpha: 0.2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgBaseFor(brightness).withValues(alpha: 0.94),
        border: Border(bottom: BorderSide(color: borderColor)),
        boxShadow: overlapsContent
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space4,
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchStickyQueryHeaderDelegate oldDelegate) {
    return oldDelegate.tokens != tokens ||
        oldDelegate.brightness != brightness ||
        oldDelegate.child != child;
  }
}
