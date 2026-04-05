import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/dev_quick_account.dart';

final authActionServiceProvider = Provider<AuthActionService>((ref) {
  return AuthActionService(ref.watch(firebaseAuthProvider));
});

class AuthActionService {
  const AuthActionService(this._auth);

  final FirebaseAuth _auth;

  Future<void> signInWithSeededAccount(DevQuickAccount account) async {
    if (kReleaseMode) {
      throw StateError('Seeded account login is disabled in release builds.');
    }

    await _signInWithEmailAndPasswordRetry(
      email: account.email,
      password: account.password,
    );
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
        await Future<void>.delayed(
          Duration(milliseconds: 250 * attempt),
        );
      }
    }
  }
}
