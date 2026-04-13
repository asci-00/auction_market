import 'package:auction_market_mobile/features/auth/application/auth_action_service.dart';
import 'package:auction_market_mobile/features/auth/application/google_sign_in_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  group('AuthActionService.signInWithGoogle', () {
    test(
      'signs in with Firebase credential when Google returns an id token',
      () async {
        final auth = MockFirebaseAuth();
        final service = AuthActionService(
          auth,
          const FakeGoogleSignInClient(idToken: 'google-id-token'),
        );

        await service.signInWithGoogle();

        expect(auth.currentUser, isNotNull);
      },
    );

    test(
      'throws a FirebaseAuthException when Google sign-in is canceled',
      () async {
        final service = AuthActionService(
          MockFirebaseAuth(),
          const FakeGoogleSignInClient(
            exception: GoogleSignInException(
              code: GoogleSignInExceptionCode.canceled,
              description: 'Canceled by user.',
            ),
          ),
        );

        await expectLater(
          service.signInWithGoogle(),
          throwsA(
            isA<FirebaseAuthException>()
                .having((error) => error.code, 'code', 'sign-in-canceled')
                .having(
                  (error) => error.message,
                  'message',
                  'Canceled by user.',
                ),
          ),
        );
      },
    );

    test(
      'throws invalid-credential when Google sign-in returns no id token',
      () async {
        final service = AuthActionService(
          MockFirebaseAuth(),
          const FakeGoogleSignInClient(idToken: null),
        );

        await expectLater(
          service.signInWithGoogle(),
          throwsA(
            isA<FirebaseAuthException>().having(
              (error) => error.code,
              'code',
              'invalid-credential',
            ),
          ),
        );
      },
    );

    test(
      'throws invalid-credential when Google sign-in returns an empty id token',
      () async {
        final service = AuthActionService(
          MockFirebaseAuth(),
          const FakeGoogleSignInClient(idToken: ''),
        );

        await expectLater(
          service.signInWithGoogle(),
          throwsA(
            isA<FirebaseAuthException>().having(
              (error) => error.code,
              'code',
              'invalid-credential',
            ),
          ),
        );
      },
    );
  });
}

class FakeGoogleSignInClient implements GoogleSignInClient {
  const FakeGoogleSignInClient({this.idToken, this.exception});

  final String? idToken;
  final GoogleSignInException? exception;

  @override
  Future<String?> authenticateForIdToken() async {
    if (exception case final error?) {
      throw error;
    }
    return idToken;
  }
}
