import 'package:flutter/material.dart';
import '../views/homescreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 152, 175),
        title: const Text('Settings'),
        centerTitle: true,
        leadingWidth: 100, 
        leading: TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Home', style: TextStyle(color: Colors.black),),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            iconColor: Colors.black
          ),
        ),
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