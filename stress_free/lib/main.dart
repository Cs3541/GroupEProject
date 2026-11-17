import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stress_free/models/auth_service.dart';
import 'package:stress_free/views/auth_gate.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StressFreeApp());
}

class StressFreeApp extends StatelessWidget {
  const StressFreeApp({super.key, this.authService});

  final AuthService? authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stress-Free',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(authService: authService),
    );
  }
}
