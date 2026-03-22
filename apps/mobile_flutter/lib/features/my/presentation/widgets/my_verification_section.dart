import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../data/my_profile_summary.dart';
import '../my_verification_label.dart';
import 'my_verification_row.dart';

class MyVerificationSection extends StatelessWidget {
  const MyVerificationSection({
    super.key,
    required this.user,
  });

  final User? user;

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
        else
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: context.l10n.genericUnavailable,
                  description: context.l10n.mySessionUnavailable,
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return AppEmptyState(
                  icon: Icons.person_search_outlined,
                  title: context.l10n.mySessionUnavailable,
                  description: context.l10n.myVerificationDescription,
                );
              }

              final profile = MyProfileSummary.fromDocument(snapshot.data!);

              return Column(
                children: [
                  MyVerificationRow(
                    label: context.l10n.myVerificationPhone,
                    value: myVerificationLabel(
                      context,
                      profile.phoneVerification,
                    ),
                  ),
                  SizedBox(height: tokens.space3),
                  MyVerificationRow(
                    label: context.l10n.myVerificationIdentity,
                    value: myVerificationLabel(
                      context,
                      profile.identityVerification,
                    ),
                  ),
                  SizedBox(height: tokens.space3),
                  MyVerificationRow(
                    label: context.l10n.myVerificationSeller,
                    value: myVerificationLabel(
                      context,
                      profile.sellerVerification,
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
