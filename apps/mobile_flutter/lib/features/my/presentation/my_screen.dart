import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_shell_insets.dart';
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
          MyAccountPanel(user: user),
          SizedBox(height: tokens.space4),
          const _MyQuickActionsPanel(),
          SizedBox(height: tokens.space6),
          MyVerificationSection(
            user: user,
            profile: myAsync?.valueOrNull?.profile,
            isLoading: myAsync?.isLoading ?? false,
            hasError: myAsync?.hasError ?? false,
          ),
          SizedBox(height: tokens.space6),
          FilledButton(
            onPressed: () async {
              try {
                await ref
                    .read(notificationDeviceTokenServiceProvider)
                    .deactivateCurrentUserTokenBeforeSignOut()
                    .timeout(const Duration(seconds: 3));
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

class _MyQuickActionsPanel extends StatelessWidget {
  const _MyQuickActionsPanel();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.soft,
      padding: EdgeInsets.all(tokens.space3),
      child: Row(
        children: [
          Expanded(
            child: _MyQuickActionTile(
              key: const ValueKey('my-settings-fallback-action'),
              icon: Icons.tune_rounded,
              label: context.l10n.settingsOpenAction,
              onTap: () => context.push('/settings'),
            ),
          ),
          SizedBox(width: tokens.space3),
          Expanded(
            child: _MyQuickActionTile(
              icon: Icons.add_business_rounded,
              label: context.l10n.sellTitle,
              onTap: () => context.go('/sell'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyQuickActionTile extends StatelessWidget {
  const _MyQuickActionTile({
    super.key,
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
            ],
          ),
        ),
      ),
    );
  }
}
