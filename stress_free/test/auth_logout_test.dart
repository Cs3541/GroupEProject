import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/main.dart';
import 'package:stress_free/models/auth_service.dart';
import 'package:stress_free/presenters/auth_presenter.dart';
import 'package:stress_free/views/homescreen.dart';
import 'package:stress_free/views/login_view.dart';
import 'package:stress_free/views/settings_screen.dart';

import 'support/fake_auth_service.dart';

Future<void> openSettings(WidgetTester tester, FakeAuthService auth) async {
  await tester.pumpWidget(StressFreeApp(authService: auth));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Settings'));
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeAuthService auth;
  late AuthPresenter presenter;

  setUp(() {
    auth = FakeAuthService(initialUser: const AuthUser(uid: 'signed-in'));
    presenter = AuthPresenter(auth);
  });

  tearDown(() async {
    presenter.dispose();
    await auth.dispose();
  });

  test('logout succeeds and publishes loading state', () async {
    final states = <bool>[];
    presenter.addListener(() => states.add(presenter.busy));
    expect(await presenter.logout(), true);
    expect(auth.logoutCalls, 1);
    expect(presenter.error, isNull);
    expect(states, [true, false]);
  });

  final failures = <String, Object>{
    'network': const AuthFailure('network-request-failed'),
    'Firebase': const AuthFailure('unknown'),
    'unexpected': StateError('private internal details'),
  };
  for (final failure in failures.entries) {
    test('${failure.key} logout failure gives feedback and permits retry', () async {
      auth.failure = failure.value;
      expect(await presenter.logout(), false);
      expect(presenter.busy, false);
      expect(
        presenter.error,
        failure.key == 'network'
            ? 'Could not log out. Check your internet connection and try again.'
            : 'Could not log out. Please try again.',
      );
      auth.failure = null;
      expect(await presenter.logout(), true);
      expect(presenter.error, isNull);
      expect(auth.logoutCalls, 2);
    });
  }

  test('duplicate logout requests are ignored during loading', () async {
    final pending = Completer<void>();
    auth.delay = pending.future;
    final first = presenter.logout();
    expect(presenter.busy, true);
    expect(await presenter.logout(), false);
    expect(auth.logoutCalls, 1);
    pending.complete();
    expect(await first, true);
    expect(presenter.busy, false);
  });

  for (final fails in [false, true]) {
    test(
      'logout ${fails ? 'failure' : 'success'} after disposal does not notify',
      () async {
        final pending = Completer<void>();
        auth.delay = pending.future;
        if (fails) auth.failure = const AuthFailure('unknown');
        final local = AuthPresenter(auth);
        var notifications = 0;
        local.addListener(() => notifications++);
        final result = local.logout();
        local.dispose();
        pending.complete();
        expect(await result, !fails);
        expect(notifications, 1);
        expect(await local.logout(), false);
        expect(auth.logoutCalls, 1);
      },
    );
  }

  testWidgets('Settings logout blocks repeated taps and AuthGate shows Login', (
    tester,
  ) async {
    final pending = Completer<void>();
    auth.delay = pending.future;
    await openSettings(tester, auth);
    for (final label in [
      'Journal Settings',
      'Notification Settings',
      'Alarm Settings',
      '... Settings',
    ]) {
      expect(find.widgetWithText(ElevatedButton, label), findsOneWidget);
    }
    expect(
      tester.getTopLeft(find.text('Log out')).dy,
      greaterThan(tester.getBottomLeft(find.text('... Settings')).dy),
    );
    await tester.tap(find.text('Log out'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Log out'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Log out'));
    await tester.pump();
    expect(auth.logoutCalls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(HomePage), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final network in [false, true]) {
    testWidgets(
      'Settings shows ${network ? 'network' : 'generic'} logout failure and allows retry',
      (tester) async {
        auth.failure = AuthFailure(
          network ? 'network-request-failed' : 'unknown',
        );
        await openSettings(tester, auth);
        await tester.tap(find.text('Log out'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            network
                ? 'Could not log out. Check your internet connection and try again.'
                : 'Could not log out. Please try again.',
          ),
          findsOneWidget,
        );
        expect(find.byType(SettingsScreen), findsOneWidget);
        expect(find.byType(LoginView), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Log out'),
              )
              .onPressed,
          isNotNull,
        );
        auth.failure = null;
        await tester.tap(find.text('Log out'));
        await tester.pumpAndSettle();
        expect(auth.logoutCalls, 2);
        expect(find.byType(LoginView), findsOneWidget);
      },
    );
  }

  testWidgets('logout navigation waits for AuthGate signed-out stream event', (
    tester,
  ) async {
    auth.emitOnSuccess = false;
    await openSettings(tester, auth);
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(auth.logoutCalls, 1);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
    auth.emitUser(null);
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });
}
