import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';

class SearchFilterChips extends StatelessWidget {
  const SearchFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Wrap(
      spacing: tokens.space2,
      runSpacing: tokens.space2,
      children: [
        Chip(label: Text(context.l10n.searchFilterCategory)),
        Chip(label: Text(context.l10n.searchFilterPrice)),
        Chip(label: Text(context.l10n.searchFilterEndingSoon)),
        Chip(label: Text(context.l10n.searchFilterBuyNow)),
      ],
    );
  }
}
