import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_section_heading.dart';
import '../../../core/widgets/app_status_badge.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;

    return AppPageScaffold(
      title: l10n.myTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppEditorialHero(
            eyebrow: l10n.myHeroEyebrow,
            title: l10n.myHeroTitle,
            description: l10n.myHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.verified),
              AppStatusBadge(kind: AppStatusKind.pending),
            ],
          ),
          SizedBox(height: tokens.space5),
          AppPanel(
            tone: AppPanelTone.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.mySignedInAs,
                    style: Theme.of(context).textTheme.bodySmall),
                SizedBox(height: tokens.space2),
                Text(
                  user?.displayName ?? user?.email ?? l10n.genericUnknownUser,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space6),
          AppSectionHeading(
            title: l10n.myVerificationTitle,
            subtitle: l10n.myVerificationDescription,
          ),
          SizedBox(height: tokens.space4),
          if (user == null)
            AppEmptyState(
              icon: Icons.person_outline_rounded,
              title: l10n.mySessionUnavailable,
              description: l10n.myVerificationDescription,
            )
          else
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.genericUnavailable,
                    description: l10n.mySessionUnavailable,
                  );
                }

                final data = snapshot.data?.data();
                if (data == null) {
                  return AppEmptyState(
                    icon: Icons.person_search_outlined,
                    title: l10n.mySessionUnavailable,
                    description: l10n.myVerificationDescription,
                  );
                }

                final verification =
                    data['verification'] as Map<String, dynamic>? ?? const {};

                return Column(
                  children: [
                    _VerificationRow(
                      label: context.l10n.myVerificationPhone,
                      value: _verificationLabel(
                        context,
                        (verification['phone'] as String?) ?? 'UNVERIFIED',
                      ),
                    ),
                    SizedBox(height: tokens.space3),
                    _VerificationRow(
                      label: context.l10n.myVerificationIdentity,
                      value: _verificationLabel(
                        context,
                        (verification['id'] as String?) ?? 'UNVERIFIED',
                      ),
                    ),
                    SizedBox(height: tokens.space3),
                    _VerificationRow(
                      label: context.l10n.myVerificationSeller,
                      value: _verificationLabel(
                        context,
                        (verification['preciousSeller'] as String?) ??
                            'UNVERIFIED',
                      ),
                    ),
                  ],
                );
              },
            ),
          SizedBox(height: tokens.space6),
          FilledButton(
            onPressed: () => auth.signOut(),
            child: Text(l10n.mySignOut),
          ),
        ],
      ),
    );
  }
}

String _verificationLabel(BuildContext context, String value) {
  final l10n = context.l10n;

  switch (value) {
    case 'VERIFIED':
      return l10n.genericStateVerified;
    case 'PENDING':
      return l10n.genericStatePending;
    case 'REJECTED':
      return l10n.genericStateRejected;
    default:
      return l10n.genericStateUnverified;
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.elevated,
      child: Row(
        children: [
          const AppStatusBadge(kind: AppStatusKind.verified),
          SizedBox(width: tokens.space3),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
