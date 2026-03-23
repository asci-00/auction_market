import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_formatters.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../../../core/widgets/app_status_badge.dart';
import '../../data/sell_draft_summary.dart';

class SellRecentDraftsSection extends StatelessWidget {
  const SellRecentDraftsSection({
    super.key,
    required this.userId,
    required this.onSelectDraft,
  });

  final String? userId;
  final ValueChanged<SellDraftSummary> onSelectDraft;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeading(
          title: context.l10n.sellDraftsTitle,
          subtitle: context.l10n.sellDraftsSubtitle,
        ),
        SizedBox(height: tokens.space4),
        if (userId == null)
          AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: context.l10n.sellDraftEmptyTitle,
            description: context.l10n.sellDraftEmptyDescription,
          )
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('sellerId', isEqualTo: userId)
                .where('status', isEqualTo: 'DRAFT')
                .limit(8)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: context.l10n.genericUnavailable,
                  description: context.l10n.sellDraftEmptyDescription,
                );
              }

              final drafts = (snapshot.data?.docs ?? const [])
                  .map(SellDraftSummary.fromDocument)
                  .toList()
                ..sort((a, b) {
                  final aTime = a.updatedAt?.millisecondsSinceEpoch ?? 0;
                  final bTime = b.updatedAt?.millisecondsSinceEpoch ?? 0;
                  return bTime.compareTo(aTime);
                });

              if (drafts.isEmpty) {
                return AppEmptyState(
                  icon: Icons.inventory_outlined,
                  title: context.l10n.sellDraftEmptyTitle,
                  description: context.l10n.sellDraftEmptyDescription,
                );
              }

              return Column(
                children: drafts.map((draft) {
                  final isReady = draft.status == 'READY';
                  return Padding(
                    padding: EdgeInsets.only(bottom: tokens.space3),
                    child: AppPanel(
                      tone: isReady
                          ? AppPanelTone.elevated
                          : AppPanelTone.surface,
                      child: InkWell(
                        onTap: () => onSelectDraft(draft),
                        child: Row(
                          children: [
                            AppStatusBadge(
                              kind: isReady
                                  ? AppStatusKind.verified
                                  : AppStatusKind.pending,
                            ),
                            SizedBox(width: tokens.space3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft.title.isNotEmpty
                                        ? draft.title
                                        : context.l10n.sellDraftUntitled,
                                    style: context.textTheme.titleMedium,
                                  ),
                                  SizedBox(height: tokens.space1),
                                  Text(
                                    draft.updatedAt != null
                                        ? context.l10n.sellDraftUpdatedAt(
                                            formatCompactDateTime(
                                              context,
                                              draft.updatedAt!,
                                            ),
                                          )
                                        : context.l10n.sellDraftNoTimestamp,
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => onSelectDraft(draft),
                              child: Text(context.l10n.sellDraftLoadAction),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}
