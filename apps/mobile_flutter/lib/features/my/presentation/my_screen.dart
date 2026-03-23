import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_status_badge.dart';
import 'widgets/my_account_panel.dart';
import 'widgets/my_verification_section.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;

    return AppPageScaffold(
      title: context.l10n.myTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppEditorialHero(
            eyebrow: context.l10n.myHeroEyebrow,
            title: context.l10n.myHeroTitle,
            description: context.l10n.myHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.verified),
              AppStatusBadge(kind: AppStatusKind.pending),
            ],
          ),
          SizedBox(height: tokens.space5),
          MyAccountPanel(user: user),
          SizedBox(height: tokens.space6),
          MyVerificationSection(user: user),
          SizedBox(height: tokens.space6),
          FilledButton(
            onPressed: () => auth.signOut(),
            child: Text(context.l10n.mySignOut),
          ),
        ],
      ),
    );
  }
}
