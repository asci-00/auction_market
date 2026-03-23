import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_status_badge.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return AppPageScaffold(
      title: l10n.notificationsTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
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
            )
          else
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .doc(user.uid)
                  .collection('inbox')
                  .orderBy('createdAt', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.genericUnavailable,
                    description: l10n.notificationsEmptyDescription,
                  );
                }

                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: l10n.notificationsEmptyTitle,
                    description: l10n.notificationsEmptyDescription,
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();
                    final createdAt =
                        (data['createdAt'] as Timestamp?)?.toDate();
                    final deeplink = data['deeplink'] as String?;
                    final isRead = data['isRead'] as bool? ?? false;

                    return Padding(
                      padding: EdgeInsets.only(bottom: tokens.space3),
                      child: AppPanel(
                        tone: isRead
                            ? AppPanelTone.surface
                            : AppPanelTone.elevated,
                        child: InkWell(
                          onTap: deeplink == null || deeplink.isEmpty
                              ? null
                              : () async {
                                  if (!isRead) {
                                    try {
                                      await ref
                                          .read(functionsProvider)
                                          .httpsCallable('markNotificationRead')
                                          .call<void>({
                                        'notificationId': doc.id,
                                      });
                                    } catch (_) {
                                      // Keep navigation responsive even if the read marker fails.
                                    }
                                  }

                                  if (!context.mounted) {
                                    return;
                                  }
                                  context
                                      .push(resolveAppDeepLinkPath(deeplink));
                                },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isRead)
                                const AppStatusBadge(
                                    kind: AppStatusKind.unread),
                              if (!isRead) SizedBox(width: tokens.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (data['title'] as String?) ??
                                          l10n.notificationsTitle,
                                      style: context.textTheme.titleMedium,
                                    ),
                                    SizedBox(height: tokens.space2),
                                    Text(
                                      (data['body'] as String?) ??
                                          l10n.notificationsEmptyDescription,
                                      style: context.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              if (createdAt != null)
                                Padding(
                                  padding: EdgeInsets.only(left: tokens.space3),
                                  child: Text(
                                    formatCompactDateTime(context, createdAt),
                                    style: context.textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
