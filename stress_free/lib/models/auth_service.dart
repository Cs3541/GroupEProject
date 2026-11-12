import 'package:firebase_auth/firebase_auth.dart';

/// App-facing authentication types keep presenters and fakes independent of Firebase.
class AuthUser {
  const AuthUser({required this.uid});

  final String uid;
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final String code;
}

abstract class AuthService {
  /// Emits the restored session first, then subsequent authentication changes.
  Stream<AuthUser?> authStateChanges();
  Future<void> signIn({required String email, required String password});
  Future<void> signUp({required String email, required String password});
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Stream<AuthUser?> authStateChanges() => _auth.authStateChanges().map(
    (user) => user == null ? null : AuthUser(uid: user.uid),
  );

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code);
    }
  }
}
