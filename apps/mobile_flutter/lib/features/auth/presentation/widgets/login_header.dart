import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_editorial_hero.dart';
import '../../../../core/widgets/app_status_badge.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppEditorialHero(
      eyebrow: context.l10n.loginHeroEyebrow,
      title: context.l10n.loginHeroTitle,
      description: context.l10n.loginHeroDescription,
      badges: const [
        AppStatusBadge(kind: AppStatusKind.verified),
        AppStatusBadge(kind: AppStatusKind.pending),
      ],
      trailing: Container(
        width: 88,
        height: 124,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.heroRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accentPrimary, AppColors.accentUrgent],
          ),
        ),
        child: const Icon(
          Icons.gavel_rounded,
          color: AppColors.textInverse,
          size: 34,
        ),
      ),
    );
  }
}
