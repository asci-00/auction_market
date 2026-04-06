import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';

class SettingsSectionHeading extends StatelessWidget {
  const SettingsSectionHeading({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(description, style: context.textTheme.bodySmall),
      ],
    );
  }
}
