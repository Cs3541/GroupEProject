import 'package:flutter/material.dart';

import '../models/auth_service.dart';
import '../widgets/auth_form.dart';

class LoginView extends StatelessWidget {
  const LoginView({
    super.key,
    required this.authService,
    required this.onSignup,
  });

  final AuthService authService;
  final VoidCallback onSignup;

  @override
  Widget build(BuildContext context) =>
      AuthForm(authService: authService, signingUp: false, onSwitch: onSignup);
}
