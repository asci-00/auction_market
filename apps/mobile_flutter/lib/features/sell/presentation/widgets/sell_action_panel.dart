import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../sell_validation_state.dart';

class SellActionPanel extends StatelessWidget {
  const SellActionPanel({
    super.key,
    required this.itemId,
    required this.isSavingDraft,
    required this.isPublishing,
    required this.onSaveDraft,
    required this.onPublish,
    required this.validationMode,
    required this.validationSummary,
  });

  final String? itemId;
  final bool isSavingDraft;
  final bool isPublishing;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;
  final SellValidationMode validationMode;
  final List<String> validationSummary;

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
          if (validationSummary.isNotEmpty) ...[
            _SellValidationSummary(
              mode: validationMode,
              validationSummary: validationSummary,
            ),
            SizedBox(height: tokens.space4),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSavingDraft || isPublishing ? null : onSaveDraft,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textInverse,
                    disabledForegroundColor: AppColors.textInverse.withValues(
                      alpha: 0.4,
                    ),
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

class _SellValidationSummary extends StatelessWidget {
  const _SellValidationSummary({
    required this.mode,
    required this.validationSummary,
  });

  final SellValidationMode mode;
  final List<String> validationSummary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.space4),
      decoration: BoxDecoration(
        color: AppColors.accentUrgent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentUrgent.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mode == SellValidationMode.publish
                ? context.l10n.sellValidationSummaryPublishTitle
                : context.l10n.sellValidationSummaryDraftTitle,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.textInverse,
            ),
          ),
          SizedBox(height: tokens.space2),
          ...validationSummary.map(
            (message) => Padding(
              padding: EdgeInsets.only(bottom: tokens.space1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.textInverse,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.space2),
                  Expanded(
                    child: Text(
                      message,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textInverse.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
