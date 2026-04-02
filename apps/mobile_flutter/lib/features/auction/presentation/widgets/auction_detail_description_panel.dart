import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../../../core/widgets/app_section_heading.dart';
import '../../data/auction_detail_view_data.dart';

class AuctionDetailDescriptionPanel extends StatelessWidget {
  const AuctionDetailDescriptionPanel({super.key, required this.auction});

  final AuctionDetailViewData auction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final meta = <({String label, String value})>[
      if (auction.condition.trim().isNotEmpty)
        (
          label: context.l10n.auctionDetailMetaCondition,
          value: _localizedCondition(context, auction.condition),
        ),
      if (auction.categorySub.trim().isNotEmpty)
        (
          label: context.l10n.auctionDetailMetaCategory,
          value: _localizedCategory(context, auction.categorySub),
        ),
    ];

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeading(
            title: context.l10n.auctionDetailDescriptionTitle,
            subtitle: context.l10n.auctionDetailDescriptionSubtitle,
            eyebrow: context.l10n.auctionDetailGalleryEyebrow,
          ),
          if (meta.isNotEmpty) ...[
            SizedBox(height: tokens.space4),
            Wrap(
              spacing: tokens.space2,
              runSpacing: tokens.space2,
              children: meta
                  .map(
                    (entry) =>
                        _DetailMetaChip(label: entry.label, value: entry.value),
                  )
                  .toList(growable: false),
            ),
          ],
          SizedBox(height: tokens.space4),
          Text(
            auction.description.trim().isNotEmpty
                ? auction.description.trim()
                : context.l10n.auctionDetailDescriptionFallback,
            style: context.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _DetailMetaChip extends StatelessWidget {
  const _DetailMetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgMutedFor(brightness),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSoftFor(brightness)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space3,
          vertical: tokens.space2,
        ),
        child: RichText(
          text: TextSpan(
            style: context.textTheme.bodySmall,
            children: [
              TextSpan(text: '$label  '),
              TextSpan(
                text: value,
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimaryFor(brightness),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localizedCondition(BuildContext context, String raw) {
  final normalized = raw.trim().toUpperCase();
  return switch (normalized) {
    'NEW' => context.l10n.auctionDetailConditionNew,
    'LIKE_NEW' => context.l10n.auctionDetailConditionLikeNew,
    'GOOD' => context.l10n.auctionDetailConditionGood,
    'FAIR' => context.l10n.auctionDetailConditionFair,
    'POOR' => context.l10n.auctionDetailConditionPoor,
    _ => _humanizeToken(raw),
  };
}

String _localizedCategory(BuildContext context, String raw) {
  final normalized = raw.trim().toUpperCase();
  return switch (normalized) {
    'IDOL_MD' => context.l10n.auctionDetailCategoryIdolMd,
    'WATCH' => context.l10n.auctionDetailCategoryWatch,
    'SNEAKERS' => context.l10n.auctionDetailCategorySneakers,
    'BULLION' => context.l10n.auctionDetailCategoryBullion,
    'CAMERA' => context.l10n.auctionDetailCategoryCamera,
    'JEWELRY' => context.l10n.auctionDetailCategoryJewelry,
    'PHOTO_CARD' => context.l10n.auctionDetailCategoryPhotoCard,
    'GAME_CONSOLE' => context.l10n.auctionDetailCategoryGameConsole,
    'FIGURE' => context.l10n.auctionDetailCategoryFigure,
    _ => _humanizeToken(raw),
  };
}

String _humanizeToken(String raw) {
  final cleaned = raw.trim();
  if (cleaned.isEmpty) {
    return '';
  }

  return cleaned
      .split('_')
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}
