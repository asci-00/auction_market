import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class SellPricingPanel extends StatelessWidget {
  const SellPricingPanel({
    super.key,
    required this.startPriceController,
    required this.buyNowPriceController,
    required this.durationDays,
    required this.onDurationChanged,
  });

  final TextEditingController startPriceController;
  final TextEditingController buyNowPriceController;
  final int durationDays;
  final ValueChanged<int> onDurationChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.sellStepPricingTitle,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: startPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormStartPriceLabel,
            ),
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: buyNowPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormBuyNowPriceLabel,
            ),
          ),
          SizedBox(height: tokens.space3),
          DropdownButtonFormField<int>(
            key: ValueKey(durationDays),
            initialValue: durationDays,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormDurationLabel,
            ),
            items: [1, 3, 5, 7]
                .map(
                  (days) => DropdownMenuItem(
                    value: days,
                    child: Text(context.l10n.sellDurationDays(days)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onDurationChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
