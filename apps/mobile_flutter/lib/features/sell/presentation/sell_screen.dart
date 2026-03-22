import 'package:flutter/material.dart';

import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../application/sell_content_factory.dart';
import 'widgets/sell_policy_panel.dart';
import 'widgets/sell_step_card.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final steps = buildSellSteps(context);

    return AppPageScaffold(
      title: context.l10n.sellTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          AppEditorialHero(
            eyebrow: context.l10n.sellHeroEyebrow,
            title: context.l10n.sellHeroTitle,
            description: context.l10n.sellHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.pending),
              AppStatusBadge(kind: AppStatusKind.verified),
            ],
          ),
          SizedBox(height: tokens.space5),
          const SellPolicyPanel(),
          SizedBox(height: tokens.space6),
          ...steps.map((step) => SellStepCard(step: step)),
        ],
      ),
    );
  }
}
