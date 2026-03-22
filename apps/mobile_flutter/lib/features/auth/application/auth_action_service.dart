import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/dev_quick_account.dart';

final authActionServiceProvider = Provider<AuthActionService>((ref) {
  return AuthActionService(ref.watch(firebaseAuthProvider));
});

class AuthActionService {
  const AuthActionService(this._auth);

  final FirebaseAuth _auth;

  Future<void> signInWithSeededAccount(DevQuickAccount account) {
    return _auth.signInWithEmailAndPassword(
      email: account.email,
      password: account.password,
    );
  }

  Future<void> signInWithProvider(AuthProvider provider) {
    return _auth.signInWithProvider(provider);
  }
}
