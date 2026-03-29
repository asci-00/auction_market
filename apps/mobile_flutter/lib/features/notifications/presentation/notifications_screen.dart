import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_formatters.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/routing/app_deeplink.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_overlay.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_shell_insets.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../data/notification_item.dart';
import 'notifications_view_model.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isNavigating = false;

  void _setNavigating(bool value) {
    if (!mounted || _isNavigating == value) {
      return;
    }
    setState(() => _isNavigating = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final notificationsAsync = user == null
        ? null
        : ref.watch(notificationsViewModelProvider(user.uid));

    return AppPageScaffold(
      title: l10n.notificationsTitle,
      body: AppLoadingOverlay(
        isLoading: _isNavigating,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.space4,
            tokens.screenPadding,
            tokens.space8 + context.shellBottomInset,
          ),
          children: [
            AppEditorialHero(
              eyebrow: l10n.notificationsHeroEyebrow,
              title: l10n.notificationsHeroTitle,
              description: l10n.notificationsHeroDescription,
              badges: const [AppStatusBadge(kind: AppStatusKind.unread)],
              tone: AppPanelTone.surface,
            ),
            SizedBox(height: tokens.space5),
            if (user == null)
              AppEmptyState(
                icon: Icons.notifications_active_outlined,
                title: l10n.notificationsEmptyTitle,
                description: l10n.notificationsEmptyDescription,
                action: TextButton(
                  onPressed: () => context.go(
                    '/login?from=${Uri.encodeComponent('/notifications')}',
                  ),
                  child: Text(l10n.genericSignInAction),
                ),
              )
            else
              _NotificationsBody(
                state: notificationsAsync,
                isNavigating: _isNavigating,
                onNavigateStart: () => _setNavigating(true),
                onNavigateEnd: () => _setNavigating(false),
                onRetry: () =>
                    ref.invalidate(notificationsViewModelProvider(user.uid)),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.state,
    required this.isNavigating,
    required this.onNavigateStart,
    required this.onNavigateEnd,
    required this.onRetry,
  });

  final AsyncValue<NotificationsViewState>? state;
  final bool isNavigating;
  final VoidCallback onNavigateStart;
  final VoidCallback onNavigateEnd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return state!.when(
      error: (_, __) => AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.genericUnavailable,
        description: l10n.notificationsEmptyDescription,
        action: TextButton(onPressed: onRetry, child: Text(l10n.retry)),
      ),
      loading: () =>
          const AppShimmerListPlaceholder(itemCount: 3, itemHeight: 120),
      data: (viewState) {
        final items = viewState.items;
        if (items.isEmpty) {
          return AppEmptyState(
            icon: Icons.notifications_none_rounded,
            title: l10n.notificationsEmptyTitle,
            description: l10n.notificationsEmptyDescription,
          );
        }

        return Column(
          children: items.indexed.map((entry) {
            final index = entry.$1;
            final item = entry.$2;

            return AppStaggeredReveal(
              index: index,
              child: Padding(
                padding: EdgeInsets.only(bottom: tokens.space3),
                child: _NotificationCard(
                  item: item,
                  isNavigating: isNavigating,
                  onNavigateStart: onNavigateStart,
                  onNavigateEnd: onNavigateEnd,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({
    required this.item,
    required this.isNavigating,
    required this.onNavigateStart,
    required this.onNavigateEnd,
  });

  final NotificationItem item;
  final bool isNavigating;
  final VoidCallback onNavigateStart;
  final VoidCallback onNavigateEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final l10n = context.l10n;
    final isRead = item.isRead;

    return AppPanel(
      tone: isRead ? AppPanelTone.surface : AppPanelTone.elevated,
      child: InkWell(
        onTap: item.deeplink == null || item.deeplink!.isEmpty
            ? null
            : () async {
                if (isNavigating) {
                  return;
                }
                onNavigateStart();
                if (!isRead) {
                  try {
                    await ref
                        .read(functionsProvider)
                        .httpsCallable('markNotificationRead')
                        .call<void>({'notificationId': item.id});
                  } catch (_) {
                    // Keep navigation responsive even if the read marker fails.
                  }
                }

                onNavigateEnd();
                if (!context.mounted) return;
                context.push(resolveAppDeepLinkPath(item.deeplink!));
              },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isRead) const AppStatusBadge(kind: AppStatusKind.unread),
            if (!isRead) SizedBox(width: tokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.isNotEmpty
                        ? item.title
                        : l10n.notificationsTitle,
                    style: context.textTheme.titleMedium,
                  ),
                  SizedBox(height: tokens.space2),
                  Text(
                    item.body.isNotEmpty
                        ? item.body
                        : l10n.notificationsEmptyDescription,
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (item.createdAt != null)
              Padding(
                padding: EdgeInsets.only(left: tokens.space3),
                child: Text(
                  formatCompactDateTime(context, item.createdAt!),
                  style: context.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
