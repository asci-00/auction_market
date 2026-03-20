import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config/app_config.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_status_badge.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.returnTo,
    this.configOverride,
  });

  final String? returnTo;
  final AppConfig? configOverride;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSubmitting = false;
  String? _errorMessage;

  static const _buyerAccount = _DevQuickAccount(
    email: 'buyer1@test.local',
    password: 'buyer-pass-1234',
  );
  static const _sellerAccount = _DevQuickAccount(
    email: 'seller1@test.local',
    password: 'seller-pass-1234',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final config =
        widget.configOverride ?? ref.watch(appBootstrapProvider).value?.config;
    final useFirebaseEmulators = config?.useFirebaseEmulators == true;
    final showDevQuickLogin =
        config?.environment == AppEnvironment.dev && useFirebaseEmulators;

    return AppPageScaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space6,
          tokens.screenPadding,
          tokens.space7,
        ),
        children: [
          AppEditorialHero(
            eyebrow: l10n.loginHeroEyebrow,
            title: l10n.loginHeroTitle,
            description: l10n.loginHeroDescription,
            badges: const [
              AppStatusBadge(kind: AppStatusKind.verified),
              AppStatusBadge(kind: AppStatusKind.pending),
            ],
            trailing: Container(
              width: 88,
              height: 124,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.heroRadius),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.accentPrimary, AppColors.accentUrgent],
                ),
              ),
              child: const Icon(
                Icons.gavel_rounded,
                color: AppColors.textInverse,
                size: 34,
              ),
            ),
          ),
          SizedBox(height: tokens.space6),
          AppPanel(
            tone: AppPanelTone.surface,
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () => _signIn(
                            provider: _googleProvider(),
                            useFirebaseEmulators: useFirebaseEmulators,
                          ),
                  icon: const Icon(Icons.g_mobiledata_rounded),
                  label: Text(
                    _isSubmitting
                        ? l10n.loginSubmitting
                        : l10n.loginContinueGoogle,
                  ),
                ),
                SizedBox(height: tokens.space3),
                OutlinedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () => _signIn(
                            provider: _appleProvider(),
                            useFirebaseEmulators: useFirebaseEmulators,
                          ),
                  icon: const Icon(Icons.apple_rounded),
                  label: Text(l10n.loginContinueApple),
                ),
                if (useFirebaseEmulators) ...[
                  SizedBox(height: tokens.space3),
                  Text(
                    l10n.loginEmulatorWarning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showDevQuickLogin) ...[
            SizedBox(height: tokens.space4),
            AppPanel(
              tone: AppPanelTone.elevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.loginDevAccessTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: tokens.space2),
                  Text(
                    l10n.loginDevAccessDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: tokens.space3),
                  FilledButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _signInWithSeededAccount(_buyerAccount),
                    child: Text(l10n.loginDevBuyer),
                  ),
                  SizedBox(height: tokens.space2),
                  OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => _signInWithSeededAccount(_sellerAccount),
                    child: Text(l10n.loginDevSeller),
                  ),
                ],
              ),
            ),
          ],
          if (_errorMessage case final message?) ...[
            SizedBox(height: tokens.space4),
            AppPanel(
              tone: AppPanelTone.soft,
              borderColor: AppColors.accentUrgent.withValues(alpha: 0.3),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentUrgent,
                ),
              ),
            ),
          ],
          SizedBox(height: tokens.space4),
          AppPanel(
            tone: AppPanelTone.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.loginTrustNote, style: theme.textTheme.titleMedium),
                if (widget.returnTo != null) ...[
                  SizedBox(height: tokens.space2),
                  Text(
                    l10n.loginReturnNotice,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  GoogleAuthProvider _googleProvider() {
    final provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.setCustomParameters(const {'prompt': 'select_account'});
    return provider;
  }

  AppleAuthProvider _appleProvider() {
    final provider = AppleAuthProvider();
    provider.addScope('email');
    provider.addScope('name');
    return provider;
  }

  Future<void> _signInWithSeededAccount(_DevQuickAccount account) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(firebaseAuthProvider).signInWithEmailAndPassword(
            email: account.email,
            password: account.password,
          );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = _mapFirebaseError(context, error);
      });
    } catch (_) {
      setState(() {
        _errorMessage = context.l10n.loginGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _signIn({
    required AuthProvider provider,
    required bool useFirebaseEmulators,
  }) async {
    if (useFirebaseEmulators &&
        (provider is GoogleAuthProvider || provider is AppleAuthProvider)) {
      setState(() {
        _errorMessage = context.l10n.loginEmulatorUnsupportedProvider;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref.read(firebaseAuthProvider).signInWithProvider(provider);
    } on FirebaseAuthException catch (error) {
      setState(() {
        _errorMessage = _mapFirebaseError(context, error);
      });
    } catch (_) {
      setState(() {
        _errorMessage = context.l10n.loginGenericError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _mapFirebaseError(BuildContext context, FirebaseAuthException error) {
    final l10n = context.l10n;

    switch (error.code) {
      case 'network-request-failed':
        return l10n.loginErrorNetwork;
      case 'operation-not-allowed':
        return l10n.loginErrorProviderDisabled;
      case 'account-exists-with-different-credential':
        return l10n.loginErrorAccountExists;
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'user-not-found':
      case 'wrong-password':
        return l10n.loginErrorSeedAccountUnavailable;
      default:
        return error.message ?? l10n.loginGenericError;
    }
  }
}

class _DevQuickAccount {
  const _DevQuickAccount({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
