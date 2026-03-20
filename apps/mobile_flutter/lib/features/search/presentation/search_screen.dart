import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_auction_card.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_status_badge.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return AppPageScaffold(
      title: l10n.searchTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppEditorialHero(
            eyebrow: l10n.searchHeroEyebrow,
            title: l10n.searchHeroTitle,
            description: l10n.searchHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.pending),
              AppStatusBadge(kind: AppStatusKind.buyNow),
            ],
            tone: AppPanelTone.surface,
          ),
          SizedBox(height: tokens.space5),
          TextField(
            controller: _controller,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              labelText: l10n.searchFieldLabel,
              hintText: l10n.searchFieldHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          SizedBox(height: tokens.space3),
          Wrap(
            spacing: tokens.space2,
            runSpacing: tokens.space2,
            children: [
              Chip(label: Text(l10n.searchFilterCategory)),
              Chip(label: Text(l10n.searchFilterPrice)),
              Chip(label: Text(l10n.searchFilterEndingSoon)),
              Chip(label: Text(l10n.searchFilterBuyNow)),
            ],
          ),
          SizedBox(height: tokens.space6),
          AppSectionHeading(
            title: l10n.searchResultsTitle,
            subtitle: l10n.searchResultsSubtitle,
          ),
          SizedBox(height: tokens.space4),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('auctions')
                .where('status', isEqualTo: 'LIVE')
                .orderBy('endAt')
                .limit(24)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: l10n.genericUnavailable,
                  description: l10n.searchEmptyDescription,
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs.where((doc) {
                if (_query.isEmpty) {
                  return true;
                }
                final data = doc.data();
                final title =
                    (data['titleSnapshot'] as String? ?? '').toLowerCase();
                final category =
                    (data['categorySub'] as String? ?? '').toLowerCase();
                final query = _query.toLowerCase();
                return title.contains(query) || category.contains(query);
              }).toList();

              if (docs.isEmpty) {
                return AppEmptyState(
                  icon: Icons.grid_view_rounded,
                  title: l10n.searchEmptyTitle,
                  description: l10n.searchEmptyDescription,
                  action: TextButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                    child: Text(l10n.searchResetAction),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.64,
                ),
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final endAt = (data['endAt'] as Timestamp?)?.toDate();
                  final buyNowPrice = data['buyNowPrice'] as num?;

                  return AppAuctionCard(
                    title: (data['titleSnapshot'] as String?) ??
                        l10n.genericUnavailable,
                    priceLabel: formatKrw(
                      context,
                      (data['currentPrice'] as num?) ?? 0,
                    ),
                    metaLabel: endAt != null
                        ? l10n.genericEndsAt(
                            formatCompactDateTime(context, endAt),
                          )
                        : l10n.genericUnavailable,
                    bidCountLabel: l10n.genericCountBids(
                      ((data['bidCount'] as num?) ?? 0).toInt(),
                    ),
                    imageUrl: data['heroImageUrl'] as String?,
                    badgeKind: buyNowPrice != null
                        ? AppStatusKind.buyNow
                        : AppStatusKind.live,
                    onTap: () => context.push('/auction/${docs[index].id}'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
