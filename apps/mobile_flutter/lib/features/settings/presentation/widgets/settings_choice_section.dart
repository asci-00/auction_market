import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import 'settings_section_heading.dart';

class SettingsChoiceOption<T> {
  const SettingsChoiceOption({
    required this.value,
    required this.title,
    required this.description,
  });

  final T value;
  final String title;
  final String description;
}

class SettingsChoiceSection<T> extends StatelessWidget {
  const SettingsChoiceSection({
    super.key,
    required this.sectionTitle,
    required this.sectionDescription,
    required this.groupValue,
    required this.options,
    required this.onChanged,
  });

  final String sectionTitle;
  final String sectionDescription;
  final T groupValue;
  final List<SettingsChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSectionHeading(
            title: sectionTitle,
            description: sectionDescription,
          ),
          SizedBox(height: tokens.space3),
          for (var index = 0; index < options.length; index++) ...[
            _SettingsChoiceTile<T>(
              option: options[index],
              selected: groupValue == options[index].value,
              onTap: () => onChanged(options[index].value),
            ),
            if (index != options.length - 1) SizedBox(height: tokens.space2),
          ],
        ],
      ),
    );
  }
}

class _SettingsChoiceTile<T> extends StatelessWidget {
  const _SettingsChoiceTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SettingsChoiceOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = context.theme.brightness;
    final highlight = selected
        ? AppColors.accentPrimarySoftFor(
            brightness,
          ).withValues(alpha: brightness == Brightness.dark ? 0.32 : 0.52)
        : context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72);
    final borderColor = selected
        ? context.colorScheme.primary.withValues(alpha: 0.42)
        : context.colorScheme.outlineVariant.withValues(alpha: 0.58);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: highlight,
            borderRadius: BorderRadius.circular(tokens.cardRadius),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space4,
              vertical: tokens.space3,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 20,
                  color: selected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: tokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.title, style: context.textTheme.titleSmall),
                      SizedBox(height: tokens.space1),
                      Text(
                        option.description,
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
