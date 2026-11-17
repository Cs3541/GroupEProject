import 'package:flutter/material.dart';

import '../models/auth_service.dart';
import '../widgets/auth_service_scope.dart';
import 'homescreen.dart';
import 'login_view.dart';
import 'signup_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.authService});

  final AuthService? authService;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _auth;
  late Stream<AuthUser?> _authChanges;

  @override
  void initState() {
    super.initState();
    _auth = widget.authService ?? FirebaseAuthService();
    _authChanges = _auth.authStateChanges();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthUser?>(
    stream: _authChanges,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not check your session. Please try again.'),
                TextButton(
                  onPressed: () =>
                      setState(() => _authChanges = _auth.authStateChanges()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      // Keep the gate above the team's pushReplacement navigation. Changing
      // sessions replaces this entire navigator, including any open signup route.
      return _SessionNavigator(
        key: ValueKey(user?.uid),
        auth: _auth,
        user: user,
      );
    },
  );
}

class _SessionNavigator extends StatefulWidget {
  const _SessionNavigator({super.key, required this.auth, required this.user});

  final AuthService auth;
  final AuthUser? user;

  @override
  State<_SessionNavigator> createState() => _SessionNavigatorState();
}

class _SessionNavigatorState extends State<_SessionNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) => AuthServiceScope(
    authService: widget.auth,
    child: NavigatorPopHandler<void>(
      onPopWithResult: (_) => _navigatorKey.currentState!.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (context) {
            if (widget.user != null) return const HomePage();
            if (settings.name == '/signup') {
              return SignupView(
                authService: widget.auth,
                onLogin: () => Navigator.of(context).pop(),
              );
            }
            return LoginView(
              authService: widget.auth,
              onSignup: () => Navigator.of(context).pushNamed('/signup'),
            );
          },
        ),
      ),
    ),
  );
}
