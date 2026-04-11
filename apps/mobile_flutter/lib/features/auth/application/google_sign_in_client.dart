import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInClientProvider = Provider<GoogleSignInClient>((ref) {
  return NativeGoogleSignInClient();
});

abstract interface class GoogleSignInClient {
  Future<String?> authenticateForIdToken();
}

class NativeGoogleSignInClient implements GoogleSignInClient {
  NativeGoogleSignInClient({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await _googleSignIn.initialize();
    _initialized = true;
  }

  @override
  Future<String?> authenticateForIdToken() async {
    await _ensureInitialized();
    final account = await _googleSignIn.authenticate();
    return account.authentication.idToken;
  }
}
