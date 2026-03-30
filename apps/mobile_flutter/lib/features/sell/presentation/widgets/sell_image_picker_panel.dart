import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/extensions/build_context_x.dart';
import '../../../../core/l10n/app_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_panel.dart';

class SellImagePickerPanel extends StatelessWidget {
  const SellImagePickerPanel({
    super.key,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.existingUrls,
    required this.newFiles,
    required this.onPickPressed,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final List<String> existingUrls;
  final List<XFile> newFiles;
  final VoidCallback onPickPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final hasImages = existingUrls.isNotEmpty || newFiles.isNotEmpty;

    return AppPanel(
      tone: AppPanelTone.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.textTheme.titleMedium),
          SizedBox(height: tokens.space2),
          Text(description, style: context.textTheme.bodyMedium),
          SizedBox(height: tokens.space3),
          OutlinedButton.icon(
            onPressed: onPickPressed,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(buttonLabel),
          ),
          SizedBox(height: tokens.space3),
          if (!hasImages)
            Text(
              context.l10n.sellImagesEmptyState,
              style: context.textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: tokens.space2,
              runSpacing: tokens.space2,
              children: [
                ...existingUrls.map(
                  (url) => _ImagePreviewTile.network(url: url),
                ),
                ...newFiles.map(
                  (file) => _ImagePreviewTile.local(path: file.path),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ImagePreviewTile extends StatelessWidget {
  const _ImagePreviewTile.network({required this.url}) : path = null;

  const _ImagePreviewTile.local({required this.path}) : url = null;

  final String? url;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        height: 72,
        child: url != null
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallbackTile(),
              )
            : Image.file(
                File(path!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallbackTile(),
              ),
      ),
    );
  }
}

class _ImageFallbackTile extends StatelessWidget {
  const _ImageFallbackTile();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.bgMutedFor(brightness)),
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textSecondaryFor(brightness),
          ),
        ),
      ),
    );
  }
}
