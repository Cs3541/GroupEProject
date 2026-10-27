import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('Journal Settings'),
            ),
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('Notification Settings'),
            ),
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('Alarm Settings'),
            ),
            ElevatedButton(
              onPressed: null, // Add your onPressed logic here
              child: Text('... Settings'),
            ),
          ],
        ),
      ),
    );
  }
}