import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_shell_insets.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../notifications/application/notification_device_token_service.dart';
import 'my_view_model.dart';
import 'widgets/my_account_panel.dart';
import 'widgets/my_verification_section.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;
    final myAsync = user == null
        ? null
        : ref.watch(myViewModelProvider(user.uid));

    return AppPageScaffold(
      title: context.l10n.myTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8 + context.shellBottomInset,
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
          MyVerificationSection(
            user: user,
            profile: myAsync?.valueOrNull?.profile,
            isLoading: myAsync?.isLoading ?? false,
            hasError: myAsync?.hasError ?? false,
          ),
          SizedBox(height: tokens.space6),
          OutlinedButton.icon(
            key: const ValueKey('my-settings-fallback-action'),
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune_rounded),
            label: Text(context.l10n.settingsOpenAction),
          ),
          SizedBox(height: tokens.space4),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(notificationDeviceTokenServiceProvider)
                    .deactivateCurrentUserTokenBeforeSignOut();
              } catch (error, stackTrace) {
                FlutterError.reportError(
                  FlutterErrorDetails(
                    exception: error,
                    stack: stackTrace,
                    library: 'my_screen',
                    context: ErrorDescription(
                      'while deactivating the current device token before sign-out',
                    ),
                  ),
                );
              } finally {
                await auth.signOut();
              }
            },
            child: Text(context.l10n.mySignOut),
          ),
        ],
      ),
    );
  }
}
