import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_status_badge.dart';
import 'widgets/activity_buyer_card.dart';
import 'widgets/activity_notifications_card.dart';
import 'widgets/activity_seller_card.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;

    return AppPageScaffold(
      title: l10n.activityTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppStaggeredItem(
            index: 0,
            child: AppEditorialHero(
              eyebrow: l10n.activityHeroEyebrow,
              title: l10n.activityHeroTitle,
              description: l10n.activityHeroDescription,
              badges: const [AppStatusBadge(kind: AppStatusKind.pending)],
            ),
          ),
          SizedBox(height: tokens.space6),
          AppStaggeredItem(
            index: 1,
            child: ActivityBuyerCard(
              userId: userId,
            ),
          ),
          SizedBox(height: tokens.space3),
          AppStaggeredItem(
            index: 2,
            child: ActivitySellerCard(
              userId: userId,
            ),
          ),
          SizedBox(height: tokens.space3),
          AppStaggeredItem(
            index: 3,
            child: ActivityNotificationsCard(
              userId: userId,
            ),
          ),
        ],
      ),
    );
  }
}
