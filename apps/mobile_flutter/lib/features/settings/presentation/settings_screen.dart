import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_shell_insets.dart';
import '../application/settings_preferences_service.dart';
import '../data/settings_preferences.dart';
import 'widgets/settings_app_info_section.dart';
import 'widgets/settings_notification_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationPermissionStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;

    if (user == null) {
      return AppPageScaffold(
        title: context.l10n.settingsTitle,
        showSettingsAction: false,
        body: AppEmptyState(
          icon: Icons.tune_rounded,
          title: context.l10n.settingsSignedOutTitle,
          description: context.l10n.settingsSignedOutDescription,
          action: FilledButton(
            onPressed: () =>
                context.go('/login?from=${Uri.encodeComponent('/settings')}'),
            child: Text(context.l10n.genericSignInAction),
          ),
        ),
      );
    }

    final preferencesAsync = ref.watch(settingsPreferencesProvider(user.uid));
    final permissionAsync = ref.watch(notificationPermissionStatusProvider);
    final packageInfoAsync = ref.watch(appPackageInfoProvider);
    final config = ref.watch(appBootstrapProvider).valueOrNull?.config;

    return AppPageScaffold(
      title: context.l10n.settingsTitle,
      subtitle: context.l10n.settingsSubtitle,
      showSettingsAction: false,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space3,
          tokens.screenPadding,
          tokens.space8 + context.shellBottomInset,
        ),
        children: [
          AppEditorialHero(
            eyebrow: context.l10n.settingsHeroEyebrow,
            title: context.l10n.settingsHeroTitle,
            description: context.l10n.settingsHeroDescription,
          ),
          SizedBox(height: tokens.space6),
          preferencesAsync.when(
            data: (preferences) {
              return SettingsNotificationSection(
                preferences: preferences,
                permissionStatus:
                    permissionAsync.valueOrNull ??
                    AuthorizationStatus.notDetermined,
                onPushEnabledChanged: (enabled) =>
                    _handlePushEnabledChanged(context, user.uid, enabled),
                onCategoryChanged: (category, enabled) =>
                    _handleCategoryChanged(
                      context,
                      user.uid,
                      category,
                      enabled,
                    ),
                onRequestPermission: () => _handlePermissionRequest(context),
                onOpenSystemSettings: () => _handleOpenSystemSettings(context),
                masterTitle: context.l10n.settingsNotificationsMasterTitle,
                masterDescription:
                    context.l10n.settingsNotificationsMasterDescription,
                permissionTitle:
                    context.l10n.settingsNotificationsPermissionTitle,
                permissionDescription:
                    context.l10n.settingsNotificationsPermissionDescription,
                permissionActionLabel: _permissionActionLabel(
                  context,
                  permissionAsync.valueOrNull ??
                      AuthorizationStatus.notDetermined,
                ),
                permissionStatusLabel: _permissionStatusLabel(
                  context,
                  permissionAsync.valueOrNull ??
                      AuthorizationStatus.notDetermined,
                ),
                categoryTitle:
                    context.l10n.settingsNotificationsCategoriesTitle,
                categoryDescription:
                    context.l10n.settingsNotificationsCategoriesDescription,
                categoryLabels: {
                  SettingsNotificationCategory.auctionActivity:
                      context.l10n.settingsCategoryAuctionActivity,
                  SettingsNotificationCategory.orderPayment:
                      context.l10n.settingsCategoryOrderPayment,
                  SettingsNotificationCategory.shippingAndReceipt:
                      context.l10n.settingsCategoryShippingAndReceipt,
                  SettingsNotificationCategory.system:
                      context.l10n.settingsCategorySystem,
                },
                categoryDescriptions: {
                  SettingsNotificationCategory.auctionActivity:
                      context.l10n.settingsCategoryAuctionActivityDescription,
                  SettingsNotificationCategory.orderPayment:
                      context.l10n.settingsCategoryOrderPaymentDescription,
                  SettingsNotificationCategory.shippingAndReceipt: context
                      .l10n
                      .settingsCategoryShippingAndReceiptDescription,
                  SettingsNotificationCategory.system:
                      context.l10n.settingsCategorySystemDescription,
                },
              );
            },
            loading: () => const _SettingsNotificationLoadingSection(),
            error: (_, __) => AppEmptyState(
              icon: Icons.settings_input_antenna_outlined,
              title: context.l10n.settingsUnavailableTitle,
              description: context.l10n.settingsUnavailableDescription,
            ),
          ),
          SizedBox(height: tokens.space6),
          SettingsAppInfoSection(
            sectionTitle: context.l10n.settingsAppInfoTitle,
            sectionDescription: context.l10n.settingsAppInfoDescription,
            versionLabel: context.l10n.settingsVersionLabel,
            versionValue: packageInfoAsync.maybeWhen(
              data: (info) => '${info.version} (${info.buildNumber})',
              orElse: () => context.l10n.settingsVersionLoading,
            ),
            licensesLabel: context.l10n.settingsLicensesTitle,
            licensesDescription: context.l10n.settingsLicensesDescription,
            onOpenLicenses: () {
              showLicensePage(
                context: context,
                applicationName: context.l10n.appTitle,
                applicationVersion: packageInfoAsync.maybeWhen(
                  data: (info) => '${info.version} (${info.buildNumber})',
                  orElse: () => null,
                ),
              );
            },
            config: config,
            debugTitle: context.l10n.settingsDeveloperTitle,
            debugDescription: context.l10n.settingsDeveloperDescription,
          ),
        ],
      ),
    );
  }

  String _categoryLabel(
    BuildContext context,
    SettingsNotificationCategory category,
  ) {
    return switch (category) {
      SettingsNotificationCategory.auctionActivity =>
        context.l10n.settingsCategoryAuctionActivity,
      SettingsNotificationCategory.orderPayment =>
        context.l10n.settingsCategoryOrderPayment,
      SettingsNotificationCategory.shippingAndReceipt =>
        context.l10n.settingsCategoryShippingAndReceipt,
      SettingsNotificationCategory.system =>
        context.l10n.settingsCategorySystem,
    };
  }

  String _permissionActionLabel(
    BuildContext context,
    AuthorizationStatus status,
  ) {
    return switch (status) {
      AuthorizationStatus.denied => context.l10n.settingsOpenSystemSettings,
      AuthorizationStatus.notDetermined =>
        context.l10n.settingsRequestPermission,
      AuthorizationStatus.authorized => context.l10n.settingsOpenSystemSettings,
      AuthorizationStatus.provisional =>
        context.l10n.settingsOpenSystemSettings,
    };
  }

  String _permissionStatusLabel(
    BuildContext context,
    AuthorizationStatus status,
  ) {
    return switch (status) {
      AuthorizationStatus.authorized =>
        context.l10n.settingsPermissionStatusAuthorized,
      AuthorizationStatus.denied => context.l10n.settingsPermissionStatusDenied,
      AuthorizationStatus.notDetermined =>
        context.l10n.settingsPermissionStatusNotDetermined,
      AuthorizationStatus.provisional =>
        context.l10n.settingsPermissionStatusProvisional,
    };
  }

  Future<void> _handlePushEnabledChanged(
    BuildContext context,
    String userId,
    bool enabled,
  ) async {
    try {
      await ref
          .read(settingsPreferencesServiceProvider)
          .setPushEnabled(userId: userId, enabled: enabled);
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(
        enabled
            ? context.l10n.settingsNotificationsEnabledToast
            : context.l10n.settingsNotificationsDisabledToast,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.settingsUpdateFailed);
    }
  }

  Future<void> _handleCategoryChanged(
    BuildContext context,
    String userId,
    SettingsNotificationCategory category,
    bool enabled,
  ) async {
    try {
      await ref
          .read(settingsPreferencesServiceProvider)
          .setCategoryEnabled(
            userId: userId,
            category: category,
            enabled: enabled,
          );
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(
        enabled
            ? context.l10n.settingsCategoryEnabledToast(
                _categoryLabel(context, category),
              )
            : context.l10n.settingsCategoryDisabledToast(
                _categoryLabel(context, category),
              ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.settingsUpdateFailed);
    }
  }

  Future<void> _handlePermissionRequest(BuildContext context) async {
    try {
      final status = await ref
          .read(settingsPreferencesServiceProvider)
          .requestPermission();
      ref.invalidate(notificationPermissionStatusProvider);
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(_permissionStatusLabel(context, status));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.settingsPermissionRequestFailed);
    }
  }

  Future<void> _handleOpenSystemSettings(BuildContext context) async {
    try {
      final opened = await ref
          .read(settingsPreferencesServiceProvider)
          .openSystemSettings();
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(
        opened
            ? context.l10n.settingsSystemSettingsOpened
            : context.l10n.settingsSystemSettingsUnavailable,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.settingsSystemSettingsUnavailable);
    }
  }
}

class _SettingsNotificationLoadingSection extends StatelessWidget {
  const _SettingsNotificationLoadingSection();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
      ),
      child: const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
