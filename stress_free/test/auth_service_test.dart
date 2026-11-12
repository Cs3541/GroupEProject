import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/models/auth_service.dart';

class FakeFirebaseUser extends Fake implements User {
  @override
  String get uid => 'firebase-user';
}

class FakeCredential extends Fake implements UserCredential {}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  String? email;
  String? password;
  FirebaseAuthException? failure;
  bool? registered;
  int logoutCalls = 0;

  @override
  Future<void> signOut() async {
    logoutCalls++;
    if (failure != null) throw failure!;
  }

  @override
  Stream<User?> authStateChanges() =>
      Stream.fromIterable([null, FakeFirebaseUser(), null]);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    registered = false;
    return _complete(email, password);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    registered = true;
    return _complete(email, password);
  }

  UserCredential _complete(String email, String password) {
    this.email = email;
    this.password = password;
    if (failure != null) throw failure!;
    return FakeCredential();
  }
}

void main() {
  test('Firebase adapter delegates sign out', () async {
    final firebase = FakeFirebaseAuth();
    await FirebaseAuthService(firebaseAuth: firebase).signOut();
    expect(firebase.logoutCalls, 1);
  });

  test('Firebase adapter preserves sign out error codes', () async {
    final firebase = FakeFirebaseAuth()
      ..failure = FirebaseAuthException(code: 'network-request-failed');
    await expectLater(
      FirebaseAuthService(firebaseAuth: firebase).signOut(),
      throwsA(
        isA<AuthFailure>().having(
          (failure) => failure.code,
          'code',
          'network-request-failed',
        ),
      ),
    );
  });

  test(
    'Firebase adapter maps authenticated and signed-out stream events',
    () async {
      final service = FirebaseAuthService(firebaseAuth: FakeFirebaseAuth());
      final users = await service.authStateChanges().toList();
      expect(users.map((user) => user?.uid), [null, 'firebase-user', null]);
    },
  );

  for (final signup in [false, true]) {
    test(
      'Firebase adapter delegates ${signup ? 'registration' : 'login'} and preserves Firebase error codes',
      () async {
        final firebase = FakeFirebaseAuth();
        final service = FirebaseAuthService(firebaseAuth: firebase);
        Future<void> authenticate() => signup
            ? service.signUp(email: 'person@example.com', password: 'secret')
            : service.signIn(email: 'person@example.com', password: 'secret');
        await authenticate();
        expect(firebase.email, 'person@example.com');
        expect(firebase.password, 'secret');
        expect(firebase.registered, signup);
        firebase.failure = FirebaseAuthException(
          code: signup ? 'email-already-in-use' : 'invalid-credential',
        );
        await expectLater(
          authenticate(),
          throwsA(
            isA<AuthFailure>().having(
              (error) => error.code,
              'code',
              firebase.failure!.code,
            ),
          ),
        );
      },
    );
  }
}
