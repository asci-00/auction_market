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
import 'widgets/settings_choice_section.dart';
import 'widgets/settings_notification_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              return Column(
                children: [
                  SettingsNotificationSection(
                    preferences: preferences,
                    permissionStatus:
                        permissionAsync.valueOrNull ??
                        AuthorizationStatus.notDetermined,
                    onPushEnabledChanged: (enabled) =>
                        _handlePushEnabledChanged(
                          context,
                          ref,
                          user.uid,
                          enabled,
                        ),
                    onCategoryChanged: (category, enabled) =>
                        _handleCategoryChanged(
                          context,
                          ref,
                          user.uid,
                          category,
                          enabled,
                        ),
                    onRequestPermission: () =>
                        _handlePermissionRequest(context, ref),
                    onOpenSystemSettings: () =>
                        _handleOpenSystemSettings(context, ref),
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
                      SettingsNotificationCategory.auctionActivity: context
                          .l10n
                          .settingsCategoryAuctionActivityDescription,
                      SettingsNotificationCategory.orderPayment:
                          context.l10n.settingsCategoryOrderPaymentDescription,
                      SettingsNotificationCategory.shippingAndReceipt: context
                          .l10n
                          .settingsCategoryShippingAndReceiptDescription,
                      SettingsNotificationCategory.system:
                          context.l10n.settingsCategorySystemDescription,
                    },
                  ),
                  SizedBox(height: tokens.space6),
                  SettingsChoiceSection<SettingsThemeModePreference>(
                    sectionTitle: context.l10n.settingsAppearanceTitle,
                    sectionDescription:
                        context.l10n.settingsAppearanceDescription,
                    groupValue: preferences.themeMode,
                    options: [
                      SettingsChoiceOption(
                        value: SettingsThemeModePreference.system,
                        title: context.l10n.settingsThemeSystemTitle,
                        description:
                            context.l10n.settingsThemeSystemDescription,
                      ),
                      SettingsChoiceOption(
                        value: SettingsThemeModePreference.light,
                        title: context.l10n.settingsThemeLightTitle,
                        description: context.l10n.settingsThemeLightDescription,
                      ),
                      SettingsChoiceOption(
                        value: SettingsThemeModePreference.dark,
                        title: context.l10n.settingsThemeDarkTitle,
                        description: context.l10n.settingsThemeDarkDescription,
                      ),
                    ],
                    onChanged: (themeMode) => _handleThemeModeChanged(
                      context,
                      ref,
                      user.uid,
                      themeMode,
                    ),
                  ),
                  SizedBox(height: tokens.space6),
                  SettingsChoiceSection<SettingsLanguagePreference>(
                    sectionTitle: context.l10n.settingsLanguageTitle,
                    sectionDescription:
                        context.l10n.settingsLanguageDescription,
                    groupValue: preferences.languagePreference,
                    options: [
                      SettingsChoiceOption(
                        value: SettingsLanguagePreference.system,
                        title: context.l10n.settingsLanguageSystemTitle,
                        description:
                            context.l10n.settingsLanguageSystemDescription,
                      ),
                      SettingsChoiceOption(
                        value: SettingsLanguagePreference.korean,
                        title: context.l10n.settingsLanguageKoreanTitle,
                        description:
                            context.l10n.settingsLanguageKoreanDescription,
                      ),
                      SettingsChoiceOption(
                        value: SettingsLanguagePreference.english,
                        title: context.l10n.settingsLanguageEnglishTitle,
                        description:
                            context.l10n.settingsLanguageEnglishDescription,
                      ),
                    ],
                    onChanged: (languagePreference) =>
                        _handleLanguagePreferenceChanged(
                          context,
                          ref,
                          user.uid,
                          languagePreference,
                        ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
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
    WidgetRef ref,
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
    WidgetRef ref,
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

  Future<void> _handlePermissionRequest(
    BuildContext context,
    WidgetRef ref,
  ) async {
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

  Future<void> _handleOpenSystemSettings(
    BuildContext context,
    WidgetRef ref,
  ) async {
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

  Future<void> _handleThemeModeChanged(
    BuildContext context,
    WidgetRef ref,
    String userId,
    SettingsThemeModePreference themeMode,
  ) async {
    try {
      await ref
          .read(settingsPreferencesServiceProvider)
          .setThemeMode(userId: userId, themeMode: themeMode);
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(
        context.l10n.settingsThemeUpdatedToast(
          _themeModeLabel(context, themeMode),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.settingsUpdateFailed);
    }
  }

  Future<void> _handleLanguagePreferenceChanged(
    BuildContext context,
    WidgetRef ref,
    String userId,
    SettingsLanguagePreference languagePreference,
  ) async {
    try {
      await ref
          .read(settingsPreferencesServiceProvider)
          .setLanguagePreference(
            userId: userId,
            languagePreference: languagePreference,
          );
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(
        context.l10n.settingsLanguageUpdatedToast(
          _languagePreferenceLabel(context, languagePreference),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.settingsUpdateFailed);
    }
  }

  String _themeModeLabel(
    BuildContext context,
    SettingsThemeModePreference themeMode,
  ) {
    return switch (themeMode) {
      SettingsThemeModePreference.system =>
        context.l10n.settingsThemeSystemTitle,
      SettingsThemeModePreference.light => context.l10n.settingsThemeLightTitle,
      SettingsThemeModePreference.dark => context.l10n.settingsThemeDarkTitle,
    };
  }

  String _languagePreferenceLabel(
    BuildContext context,
    SettingsLanguagePreference languagePreference,
  ) {
    return switch (languagePreference) {
      SettingsLanguagePreference.system =>
        context.l10n.settingsLanguageSystemTitle,
      SettingsLanguagePreference.korean =>
        context.l10n.settingsLanguageKoreanTitle,
      SettingsLanguagePreference.english =>
        context.l10n.settingsLanguageEnglishTitle,
    };
  }
}
