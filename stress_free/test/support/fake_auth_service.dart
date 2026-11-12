import 'dart:async';

import 'package:stress_free/models/auth_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.initialUser});

  final AuthUser? initialUser;
  final _changes = StreamController<AuthUser?>.broadcast();
  final _ready = Completer<void>();
  bool restoreImmediately = true;
  bool emitOnSuccess = true;
  Object? failure;
  Object? sessionFailure;
  Future<void>? delay;
  int loginCalls = 0;
  int signupCalls = 0;
  int logoutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    if (!restoreImmediately) await _ready.future;
    if (sessionFailure != null) throw sessionFailure!;
    yield initialUser;
    yield* _changes.stream;
  }

  void restoreSession() => _ready.complete();
  void emitUser(AuthUser? user) => _changes.add(user);

  @override
  Future<void> signOut() async {
    logoutCalls++;
    if (delay != null) await delay;
    if (failure != null) throw failure!;
    if (emitOnSuccess) emitUser(null);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    loginCalls++;
    await _authenticate(email, password);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    signupCalls++;
    await _authenticate(email, password);
  }

  Future<void> _authenticate(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    if (delay != null) await delay;
    if (failure != null) throw failure!;
    if (emitOnSuccess) emitUser(const AuthUser(uid: 'test-user'));
  }

  Future<void> dispose() => _changes.close();
}
