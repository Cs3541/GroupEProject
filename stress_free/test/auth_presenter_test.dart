import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/models/auth_service.dart';
import 'package:stress_free/presenters/auth_presenter.dart';

import 'support/fake_auth_service.dart';

void main() {
  late FakeAuthService auth;
  late AuthPresenter presenter;

  setUp(() {
    auth = FakeAuthService();
    presenter = AuthPresenter(auth);
  });

  tearDown(() async {
    presenter.dispose();
    await auth.dispose();
  });

  test('email validation rejects empty and malformed input', () {
    for (final value in [
      null,
      '',
      '  ',
      'person',
      'a@',
      '@mail.com',
      'a@b',
      'a b@c.com',
      'a@@b.com',
    ]) {
      expect(presenter.validateEmail(value), isNotNull, reason: '$value');
    }
    expect(presenter.validateEmail('  person+tag@example.com  '), isNull);
  });

  test(
    'signup passwords require six characters; login accepts existing passwords',
    () {
      expect(presenter.validatePassword(null), 'Enter your password.');
      expect(presenter.validatePassword(''), 'Enter your password.');
      expect(presenter.validatePassword('short', signingUp: true), isNotNull);
      expect(presenter.validatePassword('sixsix', signingUp: true), isNull);
      expect(presenter.validatePassword('short'), isNull);
    },
  );

  test('confirmation is required and must match exactly', () {
    expect(presenter.validateConfirmation(null, 'secret'), isNotNull);
    expect(presenter.validateConfirmation('', 'secret'), isNotNull);
    expect(presenter.validateConfirmation('Secret', 'secret'), isNotNull);
    expect(presenter.validateConfirmation('secret ', 'secret'), isNotNull);
    expect(presenter.validateConfirmation('secret', 'secret'), isNull);
  });

  test('invalid submissions never call the auth service', () async {
    expect(await presenter.login(email: 'bad', password: 'secret'), false);
    expect(await presenter.login(email: 'a@b.com', password: ''), false);
    expect(
      await presenter.signup(
        email: 'a@b.com',
        password: 'short',
        confirmation: 'short',
      ),
      false,
    );
    expect(
      await presenter.signup(
        email: 'a@b.com',
        password: 'secret',
        confirmation: 'other',
      ),
      false,
    );
    expect(auth.loginCalls, 0);
    expect(auth.signupCalls, 0);
    expect(presenter.busy, false);
  });

  for (final signup in [false, true]) {
    test(
      '${signup ? 'signup' : 'login'} succeeds, trims email and preserves password',
      () async {
        final success = signup
            ? await presenter.signup(
                email: '  a@b.com  ',
                password: ' secret ',
                confirmation: ' secret ',
              )
            : await presenter.login(email: '  a@b.com  ', password: ' secret ');
        expect(success, true);
        expect(auth.lastEmail, 'a@b.com');
        expect(auth.lastPassword, ' secret ');
        expect(auth.loginCalls, signup ? 0 : 1);
        expect(auth.signupCalls, signup ? 1 : 0);
        expect(presenter.error, isNull);
        expect(presenter.busy, false);
      },
    );
  }

  const errors = {
    'invalid-credential': 'Email or password is incorrect.',
    'invalid-login-credentials': 'Email or password is incorrect.',
    'wrong-password': 'Email or password is incorrect.',
    'user-not-found': 'Email or password is incorrect.',
    'invalid-email': 'Enter a valid email address.',
    'email-already-in-use':
        'An account already uses this email. Please log in.',
    'weak-password': 'Choose a stronger password with at least 6 characters.',
    'user-disabled': 'This account has been disabled. Contact support.',
    'too-many-requests': 'Too many attempts. Please wait and try again.',
    'network-request-failed': 'Check your internet connection and try again.',
    'operation-not-allowed':
        'Email and password authentication is currently unavailable.',
    'unknown': 'Authentication failed. Please try again.',
  };

  for (final entry in errors.entries) {
    test(
      'Firebase ${entry.key} gives useful feedback and allows retry',
      () async {
        auth.failure = AuthFailure(entry.key);
        expect(
          await presenter.signup(
            email: 'a@b.com',
            password: 'secret',
            confirmation: 'secret',
          ),
          false,
        );
        expect(presenter.error, entry.value);
        expect(presenter.busy, false);
        auth.failure = null;
        expect(
          await presenter.login(email: 'a@b.com', password: 'secret'),
          true,
        );
        expect(presenter.error, isNull);
      },
    );
  }

  test('unexpected failures give safe feedback', () async {
    auth.failure = StateError('internal details');
    expect(await presenter.login(email: 'a@b.com', password: 'secret'), false);
    expect(presenter.error, 'Could not connect. Please try again.');
    expect(presenter.busy, false);
  });

  test('loading is published and duplicate submissions are ignored', () async {
    final pending = Completer<void>();
    auth.delay = pending.future;
    final states = <bool>[];
    presenter.addListener(() => states.add(presenter.busy));
    final first = presenter.login(email: 'a@b.com', password: 'secret');
    expect(presenter.busy, true);
    expect(await presenter.login(email: 'a@b.com', password: 'secret'), false);
    expect(auth.loginCalls, 1);
    pending.complete();
    expect(await first, true);
    expect(states, [true, false]);
  });

  test('completion after disposal does not notify or throw', () async {
    final pending = Completer<void>();
    auth.delay = pending.future;
    final local = AuthPresenter(auth);
    var notifications = 0;
    local.addListener(() => notifications++);
    final result = local.login(email: 'a@b.com', password: 'secret');
    local.dispose();
    pending.complete();
    expect(await result, true);
    expect(notifications, 1);
    expect(await local.login(email: 'a@b.com', password: 'secret'), false);
  });
}
