import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';
import '../../../generated/locale_keys.g.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.search_title.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: LocaleKeys.search_keyword.tr(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(LocaleKeys.search_category.tr())),
                Chip(label: Text(LocaleKeys.search_priceRange.tr())),
                Chip(label: Text(LocaleKeys.search_endingSoon.tr())),
                Chip(label: Text(LocaleKeys.search_buyNow.tr())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
