import 'package:flutter/material.dart';

import '../l10n/app_localization.dart';
import '../theme/app_theme.dart';

enum AppStatusKind {
  live,
  endingSoon,
  buyNow,
  paid,
  settled,
  pending,
  verified,
  unread,
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.kind,
  });

  final AppStatusKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = switch (kind) {
      AppStatusKind.live => (
          AppColors.panel,
          AppColors.textInverse,
          l10n.badgeLive
        ),
      AppStatusKind.endingSoon => (
          AppColors.accentUrgent,
          AppColors.textInverse,
          l10n.badgeEndingSoon,
        ),
      AppStatusKind.buyNow => (
          AppColors.accentPrimary,
          AppColors.textInverse,
          l10n.badgeBuyNow,
        ),
      AppStatusKind.paid => (
          AppColors.accentSuccess,
          AppColors.textPrimary,
          l10n.badgePaid,
        ),
      AppStatusKind.settled => (
          AppColors.accentSuccess,
          AppColors.textPrimary,
          l10n.badgeSettled,
        ),
      AppStatusKind.pending => (
          AppColors.sand,
          AppColors.textPrimary,
          l10n.badgePending,
        ),
      AppStatusKind.verified => (
          AppColors.accentPrimarySoft,
          AppColors.textPrimary,
          l10n.badgeVerified,
        ),
      AppStatusKind.unread => (
          AppColors.accentPrimary,
          AppColors.textInverse,
          l10n.badgeUnread,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: style.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        style.$3,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: style.$2,
            ),
      ),
    );
  }
}
