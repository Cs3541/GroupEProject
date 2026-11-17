import 'package:flutter/material.dart';
import 'package:stress_free/views/journal_screen.dart';
import 'package:stress_free/views/main_affirmation_screen.dart';
import 'package:stress_free/views/main_alarm_screen.dart';
import 'package:stress_free/views/settings_screen.dart';
import 'package:stress_free/widgets/homescreen_nav_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void onPressed(Widget state) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => state),
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 75, 235),
        title: Text("Stress Free - Home"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Follow this format when adding navigation for new screens
              // I used various shades of blue, this doesn't have to be final
              NavCard(
                onPressed: () => onPressed(MainAlarmScreen()),
                title: 'Alarms',
                backgroundColor: Colors.lightBlue,
              ),
              NavCard(
                onPressed: () => onPressed(JournalScreen()),
                title: 'Journal',
                backgroundColor: const Color.fromARGB(255, 0, 203, 182),
              ),
              NavCard(
                onPressed: () => onPressed(MainAffirmationScreen()),
                title: 'Affirmations',
                backgroundColor: const Color.fromARGB(255, 59, 232, 255),
              ),
              NavCard(
                onPressed: () => onPressed(SettingsScreen()),
                title: 'Settings',
                backgroundColor: const Color.fromARGB(255, 104, 152, 175),
              ),
            ]
          )
        )
      )
    );
  }
}