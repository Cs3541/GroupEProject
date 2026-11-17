import 'package:flutter/material.dart';

import '../models/auth_service.dart';
import '../widgets/auth_form.dart';

class SignupView extends StatelessWidget {
  const SignupView({
    super.key,
    required this.authService,
    required this.onLogin,
  });

  final AuthService authService;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) =>
      AuthForm(authService: authService, signingUp: true, onSwitch: onLogin);
}
