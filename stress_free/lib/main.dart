import 'package:flutter/material.dart';
import 'package:stress_free/views/main_navigation.dart';
import 'views/homescreen.dart';
import 'views/settings_screen.dart';

void main() {
  runApp(const StressFreeApp());
}

class StressFreeApp extends StatelessWidget {
  const StressFreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
