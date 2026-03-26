import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/my_profile_summary.dart';
import '../my_verification_label.dart';
import 'my_verification_row.dart';

class MyVerificationSection extends StatelessWidget {
  const MyVerificationSection({
    super.key,
    required this.user,
    required this.profile,
    required this.isLoading,
    required this.hasError,
  });

  final User? user;
  final MyProfileSummary? profile;
  final bool isLoading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: [
        AppSectionHeading(
          title: context.l10n.myVerificationTitle,
          subtitle: context.l10n.myVerificationDescription,
        ),
        SizedBox(height: tokens.space4),
        if (user == null)
          AppEmptyState(
            icon: Icons.person_outline_rounded,
            title: context.l10n.mySessionUnavailable,
            description: context.l10n.myVerificationDescription,
          )
        else if (hasError)
          AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: context.l10n.genericUnavailable,
            description: context.l10n.mySessionUnavailable,
          )
        else if (isLoading)
          const AppShimmerListPlaceholder(
            itemCount: 3,
            itemHeight: 84,
          )
        else
          _VerificationBody(profile: profile),
      ],
    );
  }
}

class _VerificationBody extends StatelessWidget {
  const _VerificationBody({required this.profile});

  final MyProfileSummary? profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    if (profile == null) {
      return AppEmptyState(
        icon: Icons.person_search_outlined,
        title: context.l10n.mySessionUnavailable,
        description: context.l10n.myVerificationDescription,
      );
    }

    return Column(
      children: [
        MyVerificationRow(
          label: context.l10n.myVerificationPhone,
          value: myVerificationLabel(
            context,
            profile!.phoneVerification,
          ),
        ),
        SizedBox(height: tokens.space3),
        MyVerificationRow(
          label: context.l10n.myVerificationIdentity,
          value: myVerificationLabel(
            context,
            profile!.identityVerification,
          ),
        ),
        SizedBox(height: tokens.space3),
        MyVerificationRow(
          label: context.l10n.myVerificationSeller,
          value: myVerificationLabel(
            context,
            profile!.sellerVerification,
          ),
        ),
      ],
    );
  }
}
