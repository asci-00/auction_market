import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class SellCategoryPanel extends StatelessWidget {
  const SellCategoryPanel({
    super.key,
    required this.categoryMain,
    required this.categorySubController,
    required this.onCategoryMainChanged,
    this.categorySubError,
  });

  final String categoryMain;
  final TextEditingController categorySubController;
  final ValueChanged<String> onCategoryMainChanged;
  final String? categorySubError;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.sellStepCategoryTitle,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: tokens.space3),
          DropdownButtonFormField<String>(
            key: ValueKey(categoryMain),
            initialValue: categoryMain,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormCategoryMainLabel,
            ),
            items: [
              DropdownMenuItem(
                value: 'GOODS',
                child: Text(context.l10n.sellCategoryGoods),
              ),
              DropdownMenuItem(
                value: 'PRECIOUS',
                child: Text(context.l10n.sellCategoryPrecious),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onCategoryMainChanged(value);
              }
            },
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: categorySubController,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormCategorySubLabel,
              errorText: categorySubError,
            ),
          ),
        ],
      ),
    );
  }
}
