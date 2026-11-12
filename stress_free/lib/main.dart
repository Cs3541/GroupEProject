import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stress_free/views/main_navigation.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const StressFreeApp());
}

class StressFreeApp extends StatelessWidget {
  const StressFreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stress-Free',
      theme: ThemeData(
    scaffoldBackgroundColor: Color(0xFF8686AC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0E47),
      foregroundColor: Colors.white,
    ),
  ),
      home: const MainNavigationScreen(),
    );
  }
}
