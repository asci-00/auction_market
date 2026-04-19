import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_config/app_config.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../application/auth_action_service.dart';
import '../data/dev_quick_account.dart';
import 'auth_error_message.dart';
import 'widgets/login_dev_access_panel.dart';
import 'widgets/login_error_panel.dart';
import 'widgets/login_header.dart';
import 'widgets/login_notes_panel.dart';
import 'widgets/login_provider_panel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.returnTo,
    this.configOverride,
    bool? releaseModeOverride,
  }) : _releaseModeOverride = releaseModeOverride;

  final String? returnTo;
  final AppConfig? configOverride;
  final bool? _releaseModeOverride;

  bool get isReleaseMode => kReleaseMode || (_releaseModeOverride ?? false);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final config =
        widget.configOverride ?? ref.watch(appBootstrapProvider).value?.config;
    final useFirebaseEmulators = config?.useFirebaseEmulators == true;
    final showDevQuickLogin =
        !widget.isReleaseMode &&
        config?.environment == AppEnvironment.dev &&
        useFirebaseEmulators;

    return AppPageScaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space6,
          tokens.screenPadding,
          tokens.space7,
        ),
        children: [
          const LoginHeader(),
          SizedBox(height: tokens.space6),
          LoginProviderPanel(
            isSubmitting: _isSubmitting,
            useFirebaseEmulators: useFirebaseEmulators,
            onGooglePressed: () =>
                _signInWithGoogle(useFirebaseEmulators: useFirebaseEmulators),
            onApplePressed: () => _signIn(
              provider: _buildAppleProvider(),
              useFirebaseEmulators: useFirebaseEmulators,
            ),
          ),
          if (showDevQuickLogin) ...[
            SizedBox(height: tokens.space4),
            LoginDevAccessPanel(
              isSubmitting: _isSubmitting,
              onBuyerPressed: () =>
                  _signInWithSeededAccount(DevQuickAccount.buyer),
              onSellerPressed: () =>
                  _signInWithSeededAccount(DevQuickAccount.seller),
            ),
          ],
          if (_errorMessage case final message?) ...[
            SizedBox(height: tokens.space4),
            LoginErrorPanel(message: message),
          ],
          SizedBox(height: tokens.space4),
          LoginNotesPanel(showReturnNotice: widget.returnTo != null),
        ],
      ),
    );
  }

  AppleAuthProvider _buildAppleProvider() {
    final provider = AppleAuthProvider();
    provider.addScope('email');
    provider.addScope('name');
    return provider;
  }

  Future<void> _signInWithGoogle({required bool useFirebaseEmulators}) async {
    if (useFirebaseEmulators) {
      setState(() {
        _errorMessage = context.l10n.loginEmulatorUnsupportedProvider;
      });
      return;
    }

    await _runAuthAction(
      action: () => ref.read(authActionServiceProvider).signInWithGoogle(),
    );
  }

  Future<void> _signInWithSeededAccount(DevQuickAccount account) async {
    await _runAuthAction(
      action: () =>
          ref.read(authActionServiceProvider).signInWithSeededAccount(account),
    );
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

    await _runAuthAction(
      action: () =>
          ref.read(authActionServiceProvider).signInWithProvider(provider),
    );
  }

  Future<void> _runAuthAction({required Future<void> Function() action}) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await action();
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = mapAuthErrorMessage(context, error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
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
}
