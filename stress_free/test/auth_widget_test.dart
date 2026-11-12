import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/main.dart';
import 'package:stress_free/models/auth_service.dart';
import 'package:stress_free/views/homescreen.dart';
import 'package:stress_free/views/login_view.dart';
import 'package:stress_free/views/signup_view.dart';

import 'support/fake_auth_service.dart';

const emailField = Key('auth-email');
const passwordField = Key('auth-password');
const confirmationField = Key('auth-confirmation');
const submitButton = Key('auth-submit');
const switchButton = Key('auth-switch');

bool isObscured(WidgetTester tester, Key key) => tester
    .widget<TextField>(
      find.descendant(of: find.byKey(key), matching: find.byType(TextField)),
    )
    .obscureText;

Future<void> openApp(WidgetTester tester, FakeAuthService auth) async {
  await tester.pumpWidget(StressFreeApp(authService: auth));
  await tester.pumpAndSettle();
}

Future<void> fillCredentials(WidgetTester tester, {bool signup = false}) async {
  await tester.enterText(find.byKey(emailField), 'person@example.com');
  await tester.enterText(find.byKey(passwordField), 'secret123');
  if (signup) {
    await tester.enterText(find.byKey(confirmationField), 'secret123');
  }
}

void main() {
  late FakeAuthService auth;
  setUp(() => auth = FakeAuthService());
  tearDown(() => auth.dispose());

  testWidgets('login validates required fields and malformed email', (
    tester,
  ) async {
    await openApp(tester, auth);
    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    await tester.enterText(find.byKey(emailField), 'invalid');
    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(auth.loginCalls, 0);
  });

  testWidgets('signup validates email, password length and confirmation', (
    tester,
  ) async {
    await openApp(tester, auth);
    await tester.tap(find.byKey(switchButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.text('Confirm your password.'), findsOneWidget);
    await tester.enterText(find.byKey(emailField), 'bad-email');
    await tester.enterText(find.byKey(passwordField), 'short');
    await tester.enterText(find.byKey(confirmationField), 'other');
    await tester.ensureVisible(find.byKey(submitButton));
    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(auth.signupCalls, 0);
  });

  testWidgets('login and signup links and system Back navigate correctly', (
    tester,
  ) async {
    await openApp(tester, auth);
    expect(find.byType(LoginView), findsOneWidget);
    await tester.tap(find.byKey(switchButton));
    await tester.pumpAndSettle();
    expect(find.byType(SignupView), findsOneWidget);
    await tester.tap(find.byKey(switchButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    await tester.tap(find.byKey(switchButton));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(SignupView), findsNothing);
  });

  for (final signup in [false, true]) {
    testWidgets(
      '${signup ? 'signup' : 'login'} authenticates and replaces auth screens with existing home',
      (tester) async {
        await openApp(tester, auth);
        if (signup) {
          await tester.tap(find.byKey(switchButton));
          await tester.pumpAndSettle();
        }
        await fillCredentials(tester, signup: signup);
        await tester.tap(find.byKey(submitButton));
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
        for (final label in ['Alarms', 'Journal', 'Affirmations', 'Settings']) {
          expect(find.text(label), findsOneWidget);
        }
        expect(find.byType(LoginView), findsNothing);
        expect(find.byType(SignupView), findsNothing);
        expect(auth.loginCalls, signup ? 0 : 1);
        expect(auth.signupCalls, signup ? 1 : 0);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
      },
    );
  }

  testWidgets('password and confirmation visibility toggle independently', (
    tester,
  ) async {
    await openApp(tester, auth);
    expect(isObscured(tester, passwordField), true);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(isObscured(tester, passwordField), false);
    await tester.tap(find.byKey(switchButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Show password confirmation'));
    await tester.pump();
    expect(isObscured(tester, confirmationField), false);
    expect(isObscured(tester, passwordField), true);
  });

  for (final signup in [false, true]) {
    testWidgets(
      '${signup ? 'signup' : 'login'} disables controls while loading and shows retryable Firebase errors',
      (tester) async {
        final pending = Completer<void>();
        auth.delay = pending.future;
        auth.failure = AuthFailure(
          signup ? 'email-already-in-use' : 'invalid-credential',
        );
        await openApp(tester, auth);
        if (signup) {
          await tester.tap(find.byKey(switchButton));
          await tester.pumpAndSettle();
        }
        await fillCredentials(tester, signup: signup);
        await tester.tap(find.byKey(submitButton));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byKey(submitButton)).onPressed,
          isNull,
        );
        expect(
          tester.widget<TextButton>(find.byKey(switchButton)).onPressed,
          isNull,
        );
        expect(
          tester.widget<TextFormField>(find.byKey(emailField)).enabled,
          false,
        );
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.byType(signup ? SignupView : LoginView), findsOneWidget);
        pending.complete();
        await tester.pumpAndSettle();
        expect(
          find.text(
            signup
                ? 'An account already uses this email. Please log in.'
                : 'Email or password is incorrect.',
          ),
          findsOneWidget,
        );
        expect(find.byType(HomePage), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        auth.failure = null;
        await tester.ensureVisible(find.byKey(submitButton));
        await tester.tap(find.byKey(submitButton));
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
      },
    );
  }

  testWidgets('session restoration shows loading then the existing home', (
    tester,
  ) async {
    auth = FakeAuthService(initialUser: const AuthUser(uid: 'restored'))
      ..restoreImmediately = false;
    await tester.pumpWidget(StressFreeApp(authService: auth));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    auth.restoreSession();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('session stream errors offer retry', (tester) async {
    auth.sessionFailure = StateError('session unavailable');
    await openApp(tester, auth);
    expect(
      find.text('Could not check your session. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(HomePage), findsNothing);
    auth.sessionFailure = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('service success alone waits for an authenticated stream event', (
    tester,
  ) async {
    auth.emitOnSuccess = false;
    await openApp(tester, auth);
    await fillCredentials(tester);
    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    auth.emitUser(const AuthUser(uid: 'verified'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets(
    'auth gate survives existing home navigation and removes routes when session ends',
    (tester) async {
      auth = FakeAuthService(initialUser: const AuthUser(uid: 'restored'));
      await openApp(tester, auth);
      await tester.ensureVisible(find.text('Settings'));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Journal Settings'), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      await tester.ensureVisible(find.text('Settings'));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      auth.emitUser(null);
      await tester.pumpAndSettle();
      expect(find.byType(LoginView), findsOneWidget);
      expect(find.text('Journal Settings'), findsNothing);
      expect(find.byType(HomePage), findsNothing);
    },
  );
}
