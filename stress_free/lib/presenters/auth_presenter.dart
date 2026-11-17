import 'package:flutter/foundation.dart';

import '../models/auth_service.dart';

class AuthPresenter extends ChangeNotifier {
  AuthPresenter(this._auth);

  final AuthService _auth;
  bool _disposed = false;
  bool _busy = false;
  String? _error;

  bool get busy => _busy;
  String? get error => _error;

  Future<bool> logout() async {
    if (_busy || _disposed) return false;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signOut();
      return true;
    } on AuthFailure catch (failure) {
      _error = failure.code == 'network-request-failed'
          ? 'Could not log out. Check your internet connection and try again.'
          : 'Could not log out. Please try again.';
      return false;
    } catch (_) {
      _error = 'Could not log out. Please try again.';
      return false;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String? value, {bool signingUp = false}) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (signingUp && value.length < 6) {
      return 'Use at least 6 characters.';
    }
    return null;
  }

  String? validateConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != password) return 'Passwords do not match.';
    return null;
  }

  Future<bool> login({required String email, required String password}) =>
      _authenticate(email: email, password: password);

  Future<bool> signup({
    required String email,
    required String password,
    required String confirmation,
  }) => _authenticate(
    email: email,
    password: password,
    confirmation: confirmation,
    signingUp: true,
  );

  Future<bool> _authenticate({
    required String email,
    required String password,
    String? confirmation,
    bool signingUp = false,
  }) async {
    if (_busy || _disposed) return false;
    _error =
        validateEmail(email) ??
        validatePassword(password, signingUp: signingUp) ??
        (signingUp ? validateConfirmation(confirmation, password) : null);
    if (_error != null) {
      notifyListeners();
      return false;
    }
    _busy = true;
    notifyListeners();
    try {
      if (signingUp) {
        await _auth.signUp(email: email.trim(), password: password);
      } else {
        await _auth.signIn(email: email.trim(), password: password);
      }
      return true;
    } on AuthFailure catch (failure) {
      _error = _messageFor(failure.code);
      return false;
    } catch (_) {
      _error = 'Could not connect. Please try again.';
      return false;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  String _messageFor(String code) => switch (code) {
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'wrong-password' ||
    'user-not-found' => 'Email or password is incorrect.',
    'invalid-email' => 'Enter a valid email address.',
    'email-already-in-use' =>
      'An account already uses this email. Please log in.',
    'weak-password' => 'Choose a stronger password with at least 6 characters.',
    'user-disabled' => 'This account has been disabled. Contact support.',
    'too-many-requests' => 'Too many attempts. Please wait and try again.',
    'network-request-failed' => 'Check your internet connection and try again.',
    'operation-not-allowed' =>
      'Email and password authentication is currently unavailable.',
    _ => 'Authentication failed. Please try again.',
  };

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
