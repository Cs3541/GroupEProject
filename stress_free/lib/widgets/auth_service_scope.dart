import 'package:flutter/widgets.dart';

import '../models/auth_service.dart';

/// Shares the gate's authentication service with existing navigation routes.
class AuthServiceScope extends InheritedWidget {
  const AuthServiceScope({
    super.key,
    required this.authService,
    required super.child,
  });

  final AuthService authService;

  static AuthService of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AuthServiceScope>();
    assert(
      scope != null,
      'Authentication screens must be inside AuthServiceScope.',
    );
    return scope!.authService;
  }

  @override
  bool updateShouldNotify(AuthServiceScope oldWidget) =>
      authService != oldWidget.authService;
}
