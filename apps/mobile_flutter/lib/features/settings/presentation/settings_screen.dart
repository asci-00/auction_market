import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/backend/backend_gateway.dart';
import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_shell_insets.dart';
import '../../notifications/application/notification_device_token_service.dart';
import '../application/settings_preferences_service.dart';
import '../data/settings_preferences.dart';
import 'widgets/settings_app_info_section.dart';
import 'widgets/settings_language_section.dart';
import 'widgets/settings_notification_section.dart';
import 'widgets/settings_theme_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  bool _isSendingDebugPushProbe = false;

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

    final preferencesAsync = ref.watch(settingsPreferencesProvider);
    final themeMode = ref.watch(themeModePreferenceProvider);
    final permissionAsync = ref.watch(notificationPermissionStatusProvider);
    final permissionStatus =
        permissionAsync.valueOrNull ?? AuthorizationStatus.notDetermined;
    final packageInfoAsync = ref.watch(appPackageInfoProvider);
    final config = ref.watch(appBootstrapProvider).valueOrNull?.config;
    final canUseDebugPushProbe = !kReleaseMode && (config?.isDev ?? false);

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
              final effectivePreferences = SettingsPreferences(
                pushEnabled: _isPushEnabledForUi(
                  preferences: preferences,
                  permissionStatus: permissionStatus,
                ),
                categories: preferences.categories,
              );
              return SettingsNotificationSection(
                preferences: effectivePreferences,
                onPushEnabledChanged: (enabled) => _handlePushEnabledChanged(
                  context,
                  user.uid,
                  enabled,
                  permissionStatus: permissionStatus,
                ),
                onCategoryChanged: (category, enabled) =>
                    _handleCategoryChanged(
                      context,
                      user.uid,
                      category,
                      enabled,
                    ),
                masterTitle: context.l10n.settingsNotificationsMasterTitle,
                masterDescription:
                    context.l10n.settingsNotificationsMasterDescription,
                permissionTitle:
                    context.l10n.settingsNotificationsPermissionTitle,
                permissionDescription:
                    context.l10n.settingsNotificationsPermissionDescription,
                permissionStatusLabel: _permissionStatusLabel(
                  context,
                  permissionStatus,
                ),
                openPermissionSettingsLabel:
                    context.l10n.settingsOpenSystemSettings,
                onOpenPermissionSettings:
                    permissionStatus == AuthorizationStatus.denied
                    ? () => _handleOpenSystemSettingsInternal(
                        context,
                        showResultToast: true,
                      )
                    : null,
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
          SettingsThemeSection(
            sectionTitle: context.l10n.settingsAppearanceTitle,
            groupValue: themeMode,
            systemTitle: context.l10n.settingsThemeSystemTitle,
            lightTitle: context.l10n.settingsThemeLightTitle,
            darkTitle: context.l10n.settingsThemeDarkTitle,
            onChanged: (themeMode) =>
                _handleThemeModeChanged(context, ref, themeMode),
          ),
          SizedBox(height: tokens.space6),
          SettingsLanguageSection(
            sectionTitle: context.l10n.settingsLanguageTitle,
            sectionDescription: context.l10n.settingsLanguageDescription,
            currentLanguageLabel: context.l10n.settingsLanguageCurrentLabel,
            supportedLanguageLabel: context.l10n.settingsLanguageSupportedLabel,
            supportedLanguageValue: context.l10n.settingsLanguageSupportedValue,
            koreanLanguageLabel: context.l10n.settingsLanguageKoreanLabel,
            englishLanguageLabel: context.l10n.settingsLanguageEnglishLabel,
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
            debugPushProbeTitle: context.l10n.settingsDebugPushProbeTitle,
            debugPushProbeDescription:
                context.l10n.settingsDebugPushProbeDescription,
            debugPushProbeActionLabel: _isSendingDebugPushProbe
                ? context.l10n.settingsDebugPushProbeSending
                : context.l10n.settingsDebugPushProbeAction,
            onDebugPushProbe: canUseDebugPushProbe
                ? () => _handleDebugPushProbe(context, user.uid)
                : null,
            isDebugPushProbeInFlight: _isSendingDebugPushProbe,
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

  Future<void> _handlePushEnabledChanged(
    BuildContext context,
    String userId,
    bool enabled, {
    required AuthorizationStatus permissionStatus,
  }) async {
    try {
      _logNotificationDiagnostics(
        'push toggle requested enabled=$enabled userId=$userId',
        ref,
      );
      if (!enabled) {
        await ref
            .read(settingsPreferencesServiceProvider)
            .setPushEnabled(enabled: false);
        await ref
            .read(notificationDeviceTokenServiceProvider)
            .deactivateTokenForUser(userId);
        _logNotificationDiagnostics(
          'push disabled and token deactivated userId=$userId',
          ref,
        );
        ref.invalidate(notificationPermissionStatusProvider);
        if (!context.mounted) {
          return;
        }
        context.showSnackBarMessage(
          context.l10n.settingsNotificationsDisabledToast,
        );
        return;
      }

      final activationStatus = await _resolvePermissionForToggleActivation(
        context: context,
        permissionStatus: permissionStatus,
      );
      final isPermissionActive = _isDevicePermissionActive(activationStatus);
      if (!isPermissionActive) {
        _logNotificationDiagnostics(
          'push enable skipped due to inactive permission status=${_permissionDiagnosticsLabel(activationStatus)}',
          ref,
        );
        ref.invalidate(notificationPermissionStatusProvider);
        return;
      }

      await ref
          .read(settingsPreferencesServiceProvider)
          .setPushEnabled(enabled: true);
      await ref
          .read(notificationDeviceTokenServiceProvider)
          .syncUserDeviceToken(userId);
      _logNotificationDiagnostics(
        'push enabled and token sync requested userId=$userId',
        ref,
      );

      ref.invalidate(notificationPermissionStatusProvider);
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(
        context.l10n.settingsNotificationsEnabledToast,
      );
    } catch (error) {
      _logNotificationDiagnostics(
        'push toggle failed enabled=$enabled userId=$userId error=$error',
        ref,
      );
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
          .setCategoryEnabled(category: category, enabled: enabled);
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

  Future<void> _handleOpenSystemSettingsInternal(
    BuildContext context, {
    required bool showResultToast,
  }) async {
    try {
      final opened = await ref
          .read(settingsPreferencesServiceProvider)
          .openSystemSettings();
      _logNotificationDiagnostics(
        'open system settings result opened=$opened',
        ref,
      );
      final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (userId != null) {
        await ref
            .read(notificationDeviceTokenServiceProvider)
            .syncUserDeviceToken(userId);
        _logNotificationDiagnostics(
          'device token sync requested after opening system settings userId=$userId',
          ref,
        );
      }
      ref.invalidate(notificationPermissionStatusProvider);
      if (!context.mounted || !showResultToast) {
        return;
      }
      context.showSnackBarMessage(
        opened
            ? context.l10n.settingsSystemSettingsOpened
            : context.l10n.settingsSystemSettingsUnavailable,
      );
    } catch (error) {
      _logNotificationDiagnostics(
        'open system settings failed error=$error',
        ref,
      );
      if (!context.mounted) {
        return;
      }
      context.showErrorSnackBar(context.l10n.settingsSystemSettingsUnavailable);
    }
  }

  Future<void> _handleDebugPushProbe(
    BuildContext context,
    String userId,
  ) async {
    final config = ref.read(appBootstrapProvider).valueOrNull?.config;
    if (kReleaseMode || _isSendingDebugPushProbe || !(config?.isDev ?? false)) {
      return;
    }

    setState(() {
      _isSendingDebugPushProbe = true;
    });
    _logDebugPushProbeDiagnostics('probe requested userId=$userId', ref);

    try {
      final response = await ref
          .read(backendGatewayProvider)
          .sendDebugPushProbe();
      final keys = response.keys.toList()..sort();
      final pushAttempted = response['pushAttempted'] == true;
      final tokenCount = switch (response['tokenCount']) {
        final int value => value,
        final num value => value.toInt(),
        _ => 0,
      };
      _logDebugPushProbeDiagnostics(
        'probe completed userId=$userId pushAttempted=$pushAttempted tokenCount=$tokenCount responseKeys=${keys.join(',')}',
        ref,
      );
      if (!context.mounted) {
        return;
      }
      if (!pushAttempted) {
        context.showErrorSnackBar(
          context.l10n.settingsDebugPushProbeSkipped(tokenCount),
        );
        return;
      }
      context.showSnackBarMessage(context.l10n.settingsDebugPushProbeSuccess);
    } catch (error, stackTrace) {
      final backendMessage = error is FirebaseFunctionsException
          ? (error.message?.trim() ?? '')
          : '';
      _logDebugPushProbeDiagnostics(
        'probe failed userId=$userId error=$error',
        ref,
        error: error,
        stackTrace: stackTrace,
      );
      if (!context.mounted) {
        return;
      }
      if (backendMessage.isNotEmpty) {
        context.showErrorSnackBar(
          context.l10n.settingsDebugPushProbeFailureWithReason(backendMessage),
        );
      } else {
        context.showErrorSnackBar(context.l10n.settingsDebugPushProbeFailure);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingDebugPushProbe = false;
        });
      }
    }
  }

  bool _isDevicePermissionActive(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => true,
      AuthorizationStatus.provisional => true,
      AuthorizationStatus.denied => false,
      AuthorizationStatus.notDetermined => false,
    };
  }

  bool _isPushEnabledForUi({
    required SettingsPreferences preferences,
    required AuthorizationStatus permissionStatus,
  }) {
    return preferences.pushEnabled &&
        _isDevicePermissionActive(permissionStatus);
  }

  Future<AuthorizationStatus> _resolvePermissionForToggleActivation({
    required BuildContext context,
    required AuthorizationStatus permissionStatus,
  }) async {
    switch (permissionStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return permissionStatus;
      case AuthorizationStatus.notDetermined:
        try {
          final status = await ref
              .read(settingsPreferencesServiceProvider)
              .requestPermission();
          _logNotificationDiagnostics(
            'permission request completed status=${_permissionDiagnosticsLabel(status)}',
            ref,
          );
          return status;
        } catch (error) {
          _logNotificationDiagnostics(
            'permission request failed error=$error',
            ref,
          );
          if (context.mounted) {
            context.showErrorSnackBar(
              context.l10n.settingsPermissionRequestFailed,
            );
          }
          return permissionStatus;
        }
      case AuthorizationStatus.denied:
        final shouldOpen = await _confirmSystemSettingsNavigation(context);
        if (!shouldOpen) {
          return permissionStatus;
        }
        if (!context.mounted) {
          return permissionStatus;
        }
        await _handleOpenSystemSettingsInternal(
          context,
          showResultToast: false,
        );
        ref.invalidate(notificationPermissionStatusProvider);
        return ref.read(notificationPermissionStatusProvider.future);
    }
  }

  Future<bool> _confirmSystemSettingsNavigation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.settingsNotificationsPermissionTitle),
          content: Text(
            context.l10n.settingsNotificationsPermissionDescription,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.settingsOpenSystemSettings),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<void> _handleThemeModeChanged(
    BuildContext context,
    WidgetRef ref,
    SettingsThemeModePreference themeMode,
  ) async {
    final previousThemeMode = ref.read(themeModePreferenceProvider);
    try {
      ref.read(themeModePreferenceProvider.notifier).state = themeMode;
      await ref
          .read(settingsPreferencesServiceProvider)
          .setThemeMode(themeMode);
      if (!context.mounted) {
        return;
      }
      context.showSnackBarMessage(
        context.l10n.settingsThemeUpdatedToast(
          _themeModeLabel(context, themeMode),
        ),
      );
    } catch (_) {
      final currentThemeMode = ref.read(themeModePreferenceProvider);
      if (currentThemeMode == themeMode) {
        ref.read(themeModePreferenceProvider.notifier).state =
            previousThemeMode;
      }
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

  String _permissionDiagnosticsLabel(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => 'AUTHORIZED',
      AuthorizationStatus.denied => 'DENIED',
      AuthorizationStatus.notDetermined => 'NOT_DETERMINED',
      AuthorizationStatus.provisional => 'PROVISIONAL',
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

  void _logNotificationDiagnostics(String message, WidgetRef ref) {
    if (kReleaseMode) {
      return;
    }
    ref
        .read(appLoggerProvider)
        .debug(
          message,
          domain: AppLogDomain.settings,
          source: 'settings_screen:notifications',
        );
  }

  void _logDebugPushProbeDiagnostics(
    String message,
    WidgetRef ref, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) {
      return;
    }
    ref
        .read(appLoggerProvider)
        .debug(
          message,
          domain: AppLogDomain.settings,
          source: 'settings_screen:debug_push_probe',
          error: error,
          stackTrace: stackTrace,
        );
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
