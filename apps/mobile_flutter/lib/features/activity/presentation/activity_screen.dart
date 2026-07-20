import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_shell_insets.dart';
import 'activity_view_model.dart';
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
    final activityAsync = userId == null
        ? null
        : ref.watch(activityViewModelProvider(userId));

    return AppPageScaffold(
      title: l10n.activityTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8 + context.shellBottomInset,
        ),
        children: [
          AppStaggeredItem(
            index: 0,
            child: _ActivityQuickActions(userId: userId),
          ),
          SizedBox(height: tokens.space4),
          AppStaggeredItem(
            index: 1,
            child: ActivityBuyerCard(
              userId: userId,
              summary: activityAsync?.valueOrNull?.buyerSummary,
              isLoading: activityAsync?.isLoading ?? false,
              hasError: activityAsync?.hasError ?? false,
            ),
          ),
          SizedBox(height: tokens.space3),
          AppStaggeredItem(
            index: 2,
            child: ActivitySellerCard(
              userId: userId,
              summary: activityAsync?.valueOrNull?.sellerSummary,
              isLoading: activityAsync?.isLoading ?? false,
              hasError: activityAsync?.hasError ?? false,
            ),
          ),
          SizedBox(height: tokens.space3),
          AppStaggeredItem(
            index: 3,
            child: ActivityNotificationsCard(
              userId: userId,
              summary: activityAsync?.valueOrNull?.notificationsSummary,
              isLoading: activityAsync?.isLoading ?? false,
              hasError: activityAsync?.hasError ?? false,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityQuickActions extends StatelessWidget {
  const _ActivityQuickActions({required this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.soft,
      padding: EdgeInsets.all(tokens.space3),
      child: Row(
        children: [
          Expanded(
            child: _ActivityQuickActionTile(
              icon: Icons.receipt_long_rounded,
              label: context.l10n.activityOrdersTitle,
              onTap: () => _openOrSignIn(context, '/orders'),
            ),
          ),
          SizedBox(width: tokens.space3),
          Expanded(
            child: _ActivityQuickActionTile(
              icon: Icons.notifications_active_outlined,
              label: context.l10n.activityNotificationsTitle,
              onTap: () => _openOrSignIn(context, '/notifications'),
            ),
          ),
        ],
      ),
    );
  }

  void _openOrSignIn(BuildContext context, String path) {
    if (userId == null) {
      context.go('/login?from=${Uri.encodeComponent('/activity')}');
      return;
    }
    context.push(path);
  }
}

class _ActivityQuickActionTile extends StatelessWidget {
  const _ActivityQuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.space3,
            vertical: tokens.space3,
          ),
          decoration: BoxDecoration(
            color: AppColors.bgSurfaceFor(brightness),
            borderRadius: BorderRadius.circular(tokens.cardRadius),
            border: Border.all(color: AppColors.borderSoftFor(brightness)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: context.colorScheme.primary),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
