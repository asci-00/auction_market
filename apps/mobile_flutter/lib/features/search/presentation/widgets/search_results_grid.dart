import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/app_auction_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../application/search_auction_filter.dart';
import '../../data/search_auction_summary.dart';

class SearchResultsGrid extends StatelessWidget {
  const SearchResultsGrid({
    super.key,
    required this.query,
    required this.onResetQuery,
  });

  final String query;
  final VoidCallback onResetQuery;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
            title: context.l10n.genericUnavailable,
            description: context.l10n.searchEmptyDescription,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final auctions =
            snapshot.data!.docs.map(SearchAuctionSummary.fromDocument).toList();
        final filtered = filterSearchAuctions(auctions, query);

        if (filtered.isEmpty) {
          return AppEmptyState(
            icon: Icons.grid_view_rounded,
            title: context.l10n.searchEmptyTitle,
            description: context.l10n.searchEmptyDescription,
            action: TextButton(
              onPressed: onResetQuery,
              child: Text(context.l10n.searchResetAction),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.64,
          ),
          itemBuilder: (context, index) {
            final auction = filtered[index];

            return AppAuctionCard(
              title: auction.title.isNotEmpty
                  ? auction.title
                  : context.l10n.genericUnavailable,
              priceLabel: formatKrw(context, auction.currentPrice),
              metaLabel: auction.endAt != null
                  ? context.l10n.genericEndsAt(
                      formatCompactDateTime(context, auction.endAt!),
                    )
                  : context.l10n.genericUnavailable,
              bidCountLabel: context.l10n.genericCountBids(auction.bidCount),
              imageUrl: auction.heroImageUrl,
              badgeKind: auction.buyNowPrice != null
                  ? AppStatusKind.buyNow
                  : AppStatusKind.live,
              onTap: () => context.push('/auction/${auction.id}'),
            );
          },
        );
      },
    );
  }
}
