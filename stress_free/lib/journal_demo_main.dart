import 'package:flutter/material.dart';
import 'views/journal_screen.dart';

// Demo entrypoint only: DO NOT replace the group's existing main.dart.
// Run locally using: flutter run -t lib/journal_demo_main.dart
void main() {
  runApp(
    const MaterialApp(
      title: 'Stress-Free Journal Demo',
      debugShowCheckedModeBanner: false,
      home: JournalScreen(),
    ),
  );
}
