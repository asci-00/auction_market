import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_status_badge.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return AppPageScaffold(
      title: l10n.sellTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppEditorialHero(
            eyebrow: l10n.sellHeroEyebrow,
            title: l10n.sellHeroTitle,
            description: l10n.sellHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.pending),
              AppStatusBadge(kind: AppStatusKind.verified),
            ],
          ),
          SizedBox(height: tokens.space5),
          AppPanel(
            tone: AppPanelTone.dark,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppStatusBadge(kind: AppStatusKind.endingSoon),
                SizedBox(width: tokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sellPolicyTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textInverse,
                                ),
                      ),
                      SizedBox(height: tokens.space2),
                      Text(
                        l10n.sellPolicyDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  AppColors.textInverse.withValues(alpha: 0.82),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space6),
          _SellStepCard(
            step: '01',
            title: l10n.sellStepCategoryTitle,
            description: l10n.sellStepCategoryDescription,
          ),
          _SellStepCard(
            step: '02',
            title: l10n.sellStepDetailsTitle,
            description: l10n.sellStepDetailsDescription,
          ),
          _SellStepCard(
            step: '03',
            title: l10n.sellStepPricingTitle,
            description: l10n.sellStepPricingDescription,
          ),
          _SellStepCard(
            step: '04',
            title: l10n.sellStepImagesTitle,
            description: l10n.sellStepImagesDescription,
          ),
          _SellStepCard(
            step: '05',
            title: l10n.sellStepPublishTitle,
            description: l10n.sellStepPublishDescription,
          ),
        ],
      ),
    );
  }
}

class _SellStepCard extends StatelessWidget {
  const _SellStepCard({
    required this.step,
    required this.title,
    required this.description,
  });

  final String step;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space3),
      child: AppPanel(
        tone: AppPanelTone.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                step,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.accentPrimary,
                ),
              ),
            ),
            SizedBox(width: tokens.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  SizedBox(height: tokens.space2),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
