import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/dev_quick_account.dart';
import 'google_sign_in_client.dart';

final authActionServiceProvider = Provider<AuthActionService>((ref) {
  return AuthActionService(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInClientProvider),
  );
});

class AuthActionService {
  const AuthActionService(this._auth, this._googleSignInClient);

  final FirebaseAuth _auth;
  final GoogleSignInClient _googleSignInClient;

  Future<void> signInWithSeededAccount(DevQuickAccount account) async {
    if (kReleaseMode) {
      throw StateError('Seeded account login is disabled in release builds.');
    }

    await _signInWithEmailAndPasswordRetry(
      email: account.email,
      password: account.password,
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final idToken = await _googleSignInClient.authenticateForIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Google sign-in did not return an ID token.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      throw FirebaseAuthException(
        code: _mapGoogleSignInCode(error.code),
        message: error.description ?? _defaultGoogleSignInMessage(error.code),
      );
    }
  }

  Future<void> signInWithProvider(AuthProvider provider) {
    return _auth.signInWithProvider(provider);
  }

  Future<void> _signInWithEmailAndPasswordRetry({
    required String email,
    required String password,
  }) async {
    const maxAttempts = 3;

    for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
      try {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await _auth.signInWithCredential(credential);
        return;
      } on FirebaseAuthException catch (error) {
        final isRetriable = error.code == 'network-request-failed';
        if (!isRetriable || attempt == maxAttempts) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
      }
    }
  }

  String _mapGoogleSignInCode(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.canceled:
        return 'sign-in-canceled';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'provider-configuration-error';
      case GoogleSignInExceptionCode.interrupted:
        return 'sign-in-interrupted';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'ui-unavailable';
      case GoogleSignInExceptionCode.userMismatch:
        return 'user-mismatch';
      case GoogleSignInExceptionCode.unknownError:
        return 'unknown';
    }
  }

  String _defaultGoogleSignInMessage(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Google sign-in was canceled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google sign-in is not configured for this app build.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign-in was interrupted. Please try again.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google sign-in UI is unavailable on this device right now.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Google sign-in returned a different user than expected.';
      case GoogleSignInExceptionCode.unknownError:
        return 'Google sign-in failed.';
    }
  }
}
