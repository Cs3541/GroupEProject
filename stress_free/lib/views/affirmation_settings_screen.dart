import 'package:flutter/material.dart';

class AffirmationSettingsScreen extends StatefulWidget {
  const AffirmationSettingsScreen({super.key});

  @override
  State<AffirmationSettingsScreen> createState() => _AffirmationSettingsScreenState();

}

class _AffirmationSettingsScreenState extends State<AffirmationSettingsScreen> {
  bool isNotificationsEnabled = true;
  int notificationRate = 60;
  List<DropdownMenuEntry<dynamic>> dropdownMenuEntries = [
    DropdownMenuEntry(value: 15, label: "15 Minutes"),
    DropdownMenuEntry(value: 30, label: "30 Minutes"),
    DropdownMenuEntry(value: 60, label: "1 Hour"),
    DropdownMenuEntry(value: 180, label: "3 Hours"),
    DropdownMenuEntry(value: 480, label: "8 Hours"),
    DropdownMenuEntry(value: 1440, label: "Daily"),    
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings')),
      body: Column(
        children: [
          Row(
            // Alarm On or Off
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notifications Enabled:'),
              Switch(
                value: isNotificationsEnabled,
                onChanged: (value) => setState(() => isNotificationsEnabled = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notification Frequency'),
              DropdownMenu(
                dropdownMenuEntries: dropdownMenuEntries,
                initialSelection: dropdownMenuEntries[2].value,
                onSelected: (value) => setState(() => notificationRate = value)
              )
            ],
          ),
        ]
      )
    );
  }
}