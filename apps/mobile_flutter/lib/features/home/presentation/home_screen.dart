import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_shell_insets.dart';
import '../../../core/widgets/app_status_badge.dart';
import 'widgets/home_action_icon_button.dart';
import 'widgets/home_auction_rail.dart';
import '../data/home_auction_summary.dart';
import 'home_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final homeAsync = ref.watch(homeViewModelProvider);

    return homeAsync.when(
      error: (_, __) => AppPageScaffold(
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
        body: AppEmptyState(
          icon: Icons.wifi_tethering_error_rounded,
          title: context.l10n.genericUnavailable,
          description: context.l10n.homeEmptyDescription,
        ),
      ),
      loading: () => _HomeBody(
        tokens: tokens,
        endingSoon: const [],
        hot: const [],
        isLoading: true,
      ),
      data: (state) => _HomeBody(
        tokens: tokens,
        endingSoon: state.endingSoon,
        hot: state.hot,
        isLoading: false,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.tokens,
    required this.endingSoon,
    required this.hot,
    required this.isLoading,
  });

  final AppThemeTokens tokens;
  final List<HomeAuctionSummary> endingSoon;
  final List<HomeAuctionSummary> hot;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
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
          tokens.space8 + context.shellBottomInset,
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
            auctions: endingSoon,
            isLoading: isLoading,
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
            auctions: hot,
            isLoading: isLoading,
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
