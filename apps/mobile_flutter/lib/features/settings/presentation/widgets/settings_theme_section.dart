import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';
import '../../data/settings_preferences.dart';
import 'settings_section_heading.dart';

class SettingsThemeSection extends StatelessWidget {
  const SettingsThemeSection({
    super.key,
    required this.sectionTitle,
    required this.groupValue,
    required this.systemTitle,
    required this.lightTitle,
    required this.darkTitle,
    required this.onChanged,
  });

  final String sectionTitle;
  final SettingsThemeModePreference groupValue;
  final String systemTitle;
  final String lightTitle;
  final String darkTitle;
  final ValueChanged<SettingsThemeModePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSectionHeading(
            title: sectionTitle,
            description: context.l10n.settingsAppearanceDescription,
          ),
          SizedBox(height: tokens.space3),
          Row(
            children: [
              Expanded(
                child: _ThemePreviewTile(
                  mode: SettingsThemeModePreference.system,
                  title: systemTitle,
                  isSelected: groupValue == SettingsThemeModePreference.system,
                  previewBrightness: systemBrightness,
                  onTap: () => onChanged(SettingsThemeModePreference.system),
                ),
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: _ThemePreviewTile(
                  mode: SettingsThemeModePreference.light,
                  title: lightTitle,
                  isSelected: groupValue == SettingsThemeModePreference.light,
                  previewBrightness: Brightness.light,
                  onTap: () => onChanged(SettingsThemeModePreference.light),
                ),
              ),
              SizedBox(width: tokens.space3),
              Expanded(
                child: _ThemePreviewTile(
                  mode: SettingsThemeModePreference.dark,
                  title: darkTitle,
                  isSelected: groupValue == SettingsThemeModePreference.dark,
                  previewBrightness: Brightness.dark,
                  onTap: () => onChanged(SettingsThemeModePreference.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemePreviewTile extends StatelessWidget {
  const _ThemePreviewTile({
    required this.mode,
    required this.title,
    required this.isSelected,
    required this.previewBrightness,
    required this.onTap,
  });

  final SettingsThemeModePreference mode;
  final String title;
  final bool isSelected;
  final Brightness previewBrightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final borderColor = isSelected
        ? context.colorScheme.primary
        : context.colorScheme.outlineVariant.withValues(alpha: 0.72);
    final background = previewBrightness == Brightness.dark
        ? AppColors.bgSurfaceDark
        : AppColors.bgSurface;
    final topBar = previewBrightness == Brightness.dark
        ? AppColors.panelSoftDark
        : AppColors.sand;
    final card = previewBrightness == Brightness.dark
        ? AppColors.bgElevatedDark
        : AppColors.bgElevated;
    final chip = previewBrightness == Brightness.dark
        ? AppColors.accentPrimarySoftDark
        : AppColors.accentPrimarySoft;
    final textColor = previewBrightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewHeight = (constraints.maxWidth * 0.72).clamp(74.0, 98.0) + 8;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('settings-theme-${mode.name}'),
            borderRadius: BorderRadius.circular(tokens.cardRadius),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.38,
                ),
                borderRadius: BorderRadius.circular(tokens.cardRadius),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 1.6 : 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(tokens.space3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: previewHeight,
                      child: Stack(
                        children: [
                          DecoratedBox(
                            key: ValueKey(
                              'settings-theme-preview-${mode.name}',
                            ),
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(
                                tokens.space3,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: previewBrightness == Brightness.dark
                                      ? 0.06
                                      : 0.42,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(tokens.space2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: topBar,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  SizedBox(height: tokens.space2),
                                  Container(
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: card,
                                      borderRadius: BorderRadius.circular(
                                        tokens.space2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: tokens.space2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: chip.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(
                                              tokens.space2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: tokens.space2),
                                      Expanded(
                                        child: Container(
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: card,
                                            borderRadius: BorderRadius.circular(
                                              tokens.space2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 6,
                                    width: 34,
                                    decoration: BoxDecoration(
                                      color: textColor.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: tokens.space2,
                            right: tokens.space2,
                            child: Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 18,
                              color: isSelected
                                  ? context.colorScheme.primary
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: tokens.space2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
