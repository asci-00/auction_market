import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/locale_menu_action.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('search.title'.tr()),
        actions: const [AppLocaleMenuAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'search.keyword'.tr()),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('search.category'.tr())),
                Chip(label: Text('search.priceRange'.tr())),
                Chip(label: Text('search.endingSoon'.tr())),
                Chip(label: Text('search.buyNow'.tr())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
