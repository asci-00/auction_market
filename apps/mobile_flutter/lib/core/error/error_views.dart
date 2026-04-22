import 'package:flutter/material.dart';

import '../l10n/app_localization.dart';
import '../theme/app_theme.dart';
import '../widgets/app_panel.dart';
import '../widgets/app_shimmer.dart';
import 'app_error.dart';

class AppBootstrapLoadingScreen extends StatelessWidget {
  const AppBootstrapLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.screenPadding),
          child: AppPanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppShimmerCardPlaceholder(height: 112),
                SizedBox(height: tokens.space4),
                Text(
                  context.l10n.loadingApp,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StartupFailureView extends StatelessWidget {
  const StartupFailureView({super.key, required this.error, this.onRetry});

  final AppError error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.screenPadding),
            child: AppPanel(
              tone: AppPanelTone.dark,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    switch (error.kind) {
                      AppErrorKind.configuration =>
                        context.l10n.configRequiredTitle,
                      AppErrorKind.bootstrap =>
                        context.l10n.bootstrapFailedTitle,
                      AppErrorKind.unknown => context.l10n.unknownStartupTitle,
                    },
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                  SizedBox(height: tokens.space3),
                  Text(
                    error.kind == AppErrorKind.unknown
                        ? context.l10n.unknownStartupMessage
                        : error.message,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                  if (_detailsText(context, error) case final details?)
                    Padding(
                      padding: EdgeInsets.only(top: tokens.space3),
                      child: Text(
                        details,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textInverse.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  if (onRetry != null)
                    Padding(
                      padding: EdgeInsets.only(top: tokens.space5),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onRetry,
                          child: Text(context.l10n.retry),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _detailsText(BuildContext context, AppError error) {
    if (error.details case final details?) {
      return details;
    }
    if (error.kind == AppErrorKind.configuration) {
      return context.l10n.configRequiredDetails;
    }
    return null;
  }
}
