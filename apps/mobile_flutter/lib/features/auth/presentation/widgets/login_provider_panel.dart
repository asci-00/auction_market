import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class LoginProviderPanel extends StatelessWidget {
  const LoginProviderPanel({
    super.key,
    required this.isSubmitting,
    required this.useFirebaseEmulators,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  final bool isSubmitting;
  final bool useFirebaseEmulators;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        children: [
          FilledButton.icon(
            onPressed: isSubmitting ? null : onGooglePressed,
            icon: const Icon(Icons.g_mobiledata_rounded),
            label: Text(
              isSubmitting
                  ? context.l10n.loginSubmitting
                  : context.l10n.loginContinueGoogle,
            ),
          ),
          SizedBox(height: tokens.space3),
          OutlinedButton.icon(
            onPressed: isSubmitting ? null : onApplePressed,
            icon: const Icon(Icons.apple_rounded),
            label: Text(context.l10n.loginContinueApple),
          ),
          if (useFirebaseEmulators) ...[
            SizedBox(height: tokens.space3),
            Text(
              context.l10n.loginEmulatorWarning,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
