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
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return AppPageScaffold(
      largeTitle: l10n.homeLargeTitle,
      subtitle: l10n.homeHeroEyebrow,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: tokens.screenPadding),
          child: _ActionIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: l10n.homeOpenNotifications,
            onPressed: () => context.push('/notifications'),
          ),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space2,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppEditorialHero(
            eyebrow: l10n.homeHeroEyebrow,
            title: l10n.homeHeroTitle,
            description: l10n.homeHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.live),
              AppStatusBadge(kind: AppStatusKind.verified),
            ],
          ),
          SizedBox(height: tokens.space6),
          AppSectionHeading(
            eyebrow: l10n.homeHeroChipUrgency,
            title: l10n.homeEndingSoonTitle,
            subtitle: l10n.homeEndingSoonSubtitle,
            trailing: TextButton(
              onPressed: () => context.go('/search'),
              child: Text(l10n.homeSectionViewAll),
            ),
          ),
          SizedBox(height: tokens.space4),
          _AuctionRail(
            stream: FirebaseFirestore.instance
                .collection('auctions')
                .where('status', isEqualTo: 'LIVE')
                .orderBy('endAt')
                .limit(8)
                .snapshots(),
            onTapAuction: (id) => context.push('/auction/$id'),
          ),
          SizedBox(height: tokens.space7),
          AppSectionHeading(
            eyebrow: l10n.homeHeroChipQuality,
            title: l10n.homeHotTitle,
            subtitle: l10n.homeHotSubtitle,
          ),
          SizedBox(height: tokens.space4),
          _AuctionRail(
            stream: FirebaseFirestore.instance
                .collection('auctions')
                .where('status', isEqualTo: 'LIVE')
                .orderBy('bidCount', descending: true)
                .limit(8)
                .snapshots(),
            defaultBadge: AppStatusKind.buyNow,
            onTapAuction: (id) => context.push('/auction/$id'),
          ),
        ],
      ),
    );
  }
}

class _AuctionRail extends StatelessWidget {
  const _AuctionRail({
    required this.stream,
    required this.onTapAuction,
    this.defaultBadge = AppStatusKind.endingSoon,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final ValueChanged<String> onTapAuction;
  final AppStatusKind defaultBadge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AppEmptyState(
            icon: Icons.wifi_tethering_error_rounded,
            title: l10n.genericUnavailable,
            description: l10n.homeEmptyDescription,
          );
        }

        if (!snapshot.hasData) {
          return const _AuctionRailPlaceholder();
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return AppEmptyState(
            icon: Icons.hourglass_bottom_rounded,
            title: l10n.homeEmptyTitle,
            description: l10n.homeEmptyDescription,
          );
        }

        return SizedBox(
          height: 352,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final endAt = (data['endAt'] as Timestamp?)?.toDate();
              final buyNowPrice = data['buyNowPrice'] as num?;

              return SizedBox(
                width: 236,
                child: AppAuctionCard(
                  title: (data['titleSnapshot'] as String?) ??
                      context.l10n.genericUnavailable,
                  priceLabel: formatKrw(
                    context,
                    (data['currentPrice'] as num?) ?? 0,
                  ),
                  metaLabel: endAt != null
                      ? context.l10n.genericEndsAt(
                          formatCompactDateTime(context, endAt),
                        )
                      : context.l10n.genericUnavailable,
                  bidCountLabel: context.l10n.genericCountBids(
                    ((data['bidCount'] as num?) ?? 0).toInt(),
                  ),
                  imageUrl: data['heroImageUrl'] as String?,
                  badgeKind:
                      buyNowPrice != null ? AppStatusKind.buyNow : defaultBadge,
                  onTap: () => onTapAuction(docs[index].id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AuctionRailPlaceholder extends StatelessWidget {
  const _AuctionRailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 352,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => Container(
          width: 236,
          decoration: BoxDecoration(
            color: AppColors.bgMuted,
            borderRadius: BorderRadius.circular(context.tokens.cardRadius),
            border: Border.all(color: AppColors.borderSoft),
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(18),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
