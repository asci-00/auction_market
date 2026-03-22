import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../data/sell_step.dart';

class SellStepCard extends StatelessWidget {
  const SellStepCard({
    super.key,
    required this.step,
  });

  final SellStep step;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

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
                step.step,
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.accentPrimary,
                ),
              ),
            ),
            SizedBox(width: tokens.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: context.textTheme.titleLarge),
                  SizedBox(height: tokens.space2),
                  Text(
                    step.description,
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
