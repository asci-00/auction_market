import 'package:flutter/widgets.dart';

import '../../../core/l10n/app_localization.dart';
import '../data/sell_step.dart';

List<SellStep> buildSellSteps(BuildContext context) {
  final l10n = context.l10n;

  return [
    SellStep(
      step: '01',
      title: l10n.sellStepCategoryTitle,
      description: l10n.sellStepCategoryDescription,
    ),
    SellStep(
      step: '02',
      title: l10n.sellStepDetailsTitle,
      description: l10n.sellStepDetailsDescription,
    ),
    SellStep(
      step: '03',
      title: l10n.sellStepPricingTitle,
      description: l10n.sellStepPricingDescription,
    ),
    SellStep(
      step: '04',
      title: l10n.sellStepImagesTitle,
      description: l10n.sellStepImagesDescription,
    ),
    SellStep(
      step: '05',
      title: l10n.sellStepPublishTitle,
      description: l10n.sellStepPublishDescription,
    ),
  ];
}
