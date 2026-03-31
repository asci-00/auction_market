import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_status_badge.dart';

class SellProgressPanel extends StatelessWidget {
  const SellProgressPanel({
    super.key,
    required this.categoryReady,
    required this.detailsReady,
    required this.pricingReady,
    required this.imagesReady,
    required this.publishReady,
    required this.currentDraftId,
    required this.hasUnsavedChanges,
    required this.lastSavedAt,
  });

  final bool categoryReady;
  final bool detailsReady;
  final bool pricingReady;
  final bool imagesReady;
  final bool publishReady;
  final String? currentDraftId;
  final bool hasUnsavedChanges;
  final DateTime? lastSavedAt;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;
    final steps = [
      _SellProgressStep(
        title: context.l10n.sellStepCategoryTitle,
        isReady: categoryReady,
      ),
      _SellProgressStep(
        title: context.l10n.sellStepDetailsTitle,
        isReady: detailsReady,
      ),
      _SellProgressStep(
        title: context.l10n.sellStepPricingTitle,
        isReady: pricingReady,
      ),
      _SellProgressStep(
        title: context.l10n.sellStepImagesTitle,
        isReady: imagesReady,
      ),
      _SellProgressStep(
        title: context.l10n.sellStepPublishTitle,
        isReady: publishReady,
      ),
    ];
    final completedSteps = steps.where((step) => step.isReady).length;
    final progress = completedSteps / steps.length;
    final draftState = _resolveDraftState();
    final accentColor = switch (draftState) {
      _SellDraftState.saved => AppColors.accentSuccess,
      _SellDraftState.unsaved => AppColors.accentUrgent,
      _SellDraftState.notSaved => AppColors.accentPrimary,
    };

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.sellProgressTitle,
                      style: context.textTheme.titleMedium,
                    ),
                    SizedBox(height: tokens.space1),
                    Text(
                      context.l10n.sellProgressSubtitle(
                        completedSteps,
                        steps.length,
                      ),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryFor(brightness),
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusBadge(
                kind: publishReady
                    ? AppStatusKind.verified
                    : AppStatusKind.pending,
              ),
            ],
          ),
          SizedBox(height: tokens.space4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 8,
              color: AppColors.bgMutedFor(brightness),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: publishReady
                          ? AppColors.accentSuccess
                          : AppColors.accentPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.space4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(tokens.space4),
            decoration: BoxDecoration(
              color: accentColor.withValues(
                alpha: brightness == Brightness.dark ? 0.20 : 0.12,
              ),
              borderRadius: BorderRadius.circular(tokens.cardRadius - 8),
              border: Border.all(
                color: accentColor.withValues(
                  alpha: brightness == Brightness.dark ? 0.34 : 0.24,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_draftIconFor(draftState), color: accentColor, size: 20),
                SizedBox(width: tokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _draftTitle(context, draftState),
                        style: context.textTheme.titleSmall,
                      ),
                      SizedBox(height: tokens.space1),
                      Text(
                        _draftDescription(context, draftState),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryFor(brightness),
                        ),
                      ),
                      if (currentDraftId != null) ...[
                        SizedBox(height: tokens.space2),
                        Text(
                          context.l10n.sellCurrentDraftLabel(currentDraftId!),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondaryFor(brightness),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.space4),
          Column(
            children: steps
                .map(
                  (step) => Padding(
                    padding: EdgeInsets.only(bottom: tokens.space2),
                    child: _SellProgressRow(step: step),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  _SellDraftState _resolveDraftState() {
    if (currentDraftId == null && !hasUnsavedChanges) {
      return _SellDraftState.notSaved;
    }
    if (hasUnsavedChanges) {
      return _SellDraftState.unsaved;
    }
    return _SellDraftState.saved;
  }

  String _draftTitle(BuildContext context, _SellDraftState state) {
    return switch (state) {
      _SellDraftState.notSaved => context.l10n.sellDraftStatusNotSaved,
      _SellDraftState.unsaved => context.l10n.sellDraftStatusUnsaved,
      _SellDraftState.saved => context.l10n.sellDraftStatusSaved,
    };
  }

  String _draftDescription(BuildContext context, _SellDraftState state) {
    return switch (state) {
      _SellDraftState.notSaved =>
        context.l10n.sellDraftStatusNotSavedDescription,
      _SellDraftState.unsaved => context.l10n.sellDraftStatusUnsavedDescription,
      _SellDraftState.saved => context.l10n.sellDraftStatusSavedDescription(
        lastSavedAt == null
            ? context.l10n.sellDraftNoTimestamp
            : formatCompactDateTime(context, lastSavedAt!),
      ),
    };
  }

  IconData _draftIconFor(_SellDraftState state) {
    return switch (state) {
      _SellDraftState.notSaved => Icons.edit_note_rounded,
      _SellDraftState.unsaved => Icons.schedule_rounded,
      _SellDraftState.saved => Icons.check_circle_rounded,
    };
  }
}

enum _SellDraftState { notSaved, unsaved, saved }

class _SellProgressStep {
  const _SellProgressStep({required this.title, required this.isReady});

  final String title;
  final bool isReady;
}

class _SellProgressRow extends StatelessWidget {
  const _SellProgressRow({required this.step});

  final _SellProgressStep step;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final tokens = context.tokens;
    final iconColor = step.isReady
        ? AppColors.accentSuccess
        : AppColors.textMutedFor(brightness);

    return Row(
      children: [
        Icon(
          step.isReady
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 18,
          color: iconColor,
        ),
        SizedBox(width: tokens.space3),
        Expanded(
          child: Text(
            step.title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: step.isReady
                  ? AppColors.textPrimaryFor(brightness)
                  : AppColors.textSecondaryFor(brightness),
            ),
          ),
        ),
      ],
    );
  }
}
