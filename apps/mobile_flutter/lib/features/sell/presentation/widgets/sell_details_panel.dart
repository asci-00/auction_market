import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class SellDetailsPanel extends StatelessWidget {
  const SellDetailsPanel({
    super.key,
    required this.titleController,
    required this.conditionController,
    required this.tagsController,
    required this.descriptionController,
    required this.appraisalRequested,
    required this.onAppraisalChanged,
    this.titleError,
    this.conditionError,
    this.descriptionError,
  });

  final TextEditingController titleController;
  final TextEditingController conditionController;
  final TextEditingController tagsController;
  final TextEditingController descriptionController;
  final bool appraisalRequested;
  final ValueChanged<bool> onAppraisalChanged;
  final String? titleError;
  final String? conditionError;
  final String? descriptionError;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.sellStepDetailsTitle,
            style: context.textTheme.titleMedium,
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormTitleLabel,
              errorText: titleError,
            ),
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: conditionController,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormConditionLabel,
              errorText: conditionError,
            ),
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: tagsController,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormTagsLabel,
              hintText: context.l10n.sellFormTagsHint,
            ),
          ),
          SizedBox(height: tokens.space3),
          TextField(
            controller: descriptionController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: context.l10n.sellFormDescriptionLabel,
              alignLabelWithHint: true,
              errorText: descriptionError,
            ),
          ),
          SizedBox(height: tokens.space3),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: appraisalRequested,
            title: Text(context.l10n.sellFormAppraisalLabel),
            onChanged: onAppraisalChanged,
          ),
        ],
      ),
    );
  }
}
