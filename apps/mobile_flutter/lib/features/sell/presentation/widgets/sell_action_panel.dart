import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class SellActionPanel extends StatelessWidget {
  const SellActionPanel({
    super.key,
    required this.itemId,
    required this.isSavingDraft,
    required this.isPublishing,
    required this.onSaveDraft,
    required this.onPublish,
  });

  final String? itemId;
  final bool isSavingDraft;
  final bool isPublishing;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (itemId != null)
            Padding(
              padding: EdgeInsets.only(bottom: tokens.space3),
              child: Text(
                context.l10n.sellCurrentDraftLabel(itemId!),
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.8),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSavingDraft || isPublishing ? null : onSaveDraft,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textInverse,
                    disabledForegroundColor:
                        AppColors.textInverse.withValues(alpha: 0.4),
                  ),
                  child: Text(
                    isSavingDraft
                        ? context.l10n.sellSavingDraft
                        : context.l10n.sellSaveDraftAction,
                  ),
                ),
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: FilledButton(
                  onPressed: isSavingDraft || isPublishing ? null : onPublish,
                  child: Text(
                    isPublishing
                        ? context.l10n.sellPublishing
                        : context.l10n.sellPublishAction,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
