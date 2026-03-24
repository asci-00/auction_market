import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_status_badge.dart';
import 'widgets/home_action_icon_button.dart';
import 'widgets/home_auction_rail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPageScaffold(
      largeTitle: context.l10n.homeLargeTitle,
      subtitle: context.l10n.homeHeroEyebrow,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: tokens.screenPadding),
          child: HomeActionIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: context.l10n.homeOpenNotifications,
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
            eyebrow: context.l10n.homeHeroEyebrow,
            title: context.l10n.homeHeroTitle,
            description: context.l10n.homeHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.live),
              AppStatusBadge(kind: AppStatusKind.verified),
            ],
          ),
          SizedBox(height: tokens.space6),
          AppSectionHeading(
            eyebrow: context.l10n.homeHeroChipUrgency,
            title: context.l10n.homeEndingSoonTitle,
            subtitle: context.l10n.homeEndingSoonSubtitle,
            trailing: TextButton(
              onPressed: () => context.go('/search'),
              child: Text(context.l10n.homeSectionViewAll),
            ),
          ),
          SizedBox(height: tokens.space4),
          HomeAuctionRail(
            stream: FirebaseFirestore.instance
                .collection('auctions')
                .where('status', isEqualTo: 'LIVE')
                .orderBy('endAt')
                .limit(8)
                .snapshots(),
            heroNamespace: 'home-ending',
            onTapAuction: (id, heroTag) =>
                context.push('/auction/$id?heroTag=$heroTag'),
          ),
          SizedBox(height: tokens.space7),
          AppSectionHeading(
            eyebrow: context.l10n.homeHeroChipQuality,
            title: context.l10n.homeHotTitle,
            subtitle: context.l10n.homeHotSubtitle,
          ),
          SizedBox(height: tokens.space4),
          HomeAuctionRail(
            stream: FirebaseFirestore.instance
                .collection('auctions')
                .where('status', isEqualTo: 'LIVE')
                .orderBy('bidCount', descending: true)
                .limit(8)
                .snapshots(),
            heroNamespace: 'home-hot',
            defaultBadge: AppStatusKind.buyNow,
            onTapAuction: (id, heroTag) =>
                context.push('/auction/$id?heroTag=$heroTag'),
          ),
        ],
      ),
    );
  }
}
