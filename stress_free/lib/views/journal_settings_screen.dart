import 'package:flutter/material.dart';

class JournalSettingsScreen extends StatefulWidget {
  const JournalSettingsScreen({super.key});

  @override
  State<JournalSettingsScreen> createState() =>
      _JournalSettingsScreenState();
}

class _JournalSettingsScreenState extends State<JournalSettingsScreen> {
  String selectedFont = 'Roboto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journal Settings',
              style: TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 30),

            const Text('Change Font'),

            DropdownButton<String>(
              value: selectedFont,
              items: ['Roboto', 'Serif', 'Monospace'].map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFont = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Still have to clear journal entries once journal storage is added.
              },
              child: const Text('Clear All Journals'),
            ),
          ],
        ),
      ),
    );
  }
}