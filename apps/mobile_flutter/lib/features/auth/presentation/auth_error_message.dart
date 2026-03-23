import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../../../core/l10n/app_localization.dart';

String mapAuthErrorMessage(BuildContext context, FirebaseAuthException error) {
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
