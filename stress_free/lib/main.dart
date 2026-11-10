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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
