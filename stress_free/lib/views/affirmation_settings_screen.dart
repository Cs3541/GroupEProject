import 'package:flutter/material.dart';

class AffirmationSettingsScreen extends StatefulWidget {
  const AffirmationSettingsScreen({super.key});

  @override
  State<AffirmationSettingsScreen> createState() => _AffirmationSettingsScreenState();

}

class _AffirmationSettingsScreenState extends State<AffirmationSettingsScreen> {
  bool isNotificationsEnabled = true;
  int notificationRate = 60;
  bool favoritesOnly = false;
  List<DropdownMenuEntry<dynamic>> rateEntries = [
    DropdownMenuEntry(value: 15, label: "15 Minutes"),
    DropdownMenuEntry(value: 30, label: "30 Minutes"),
    DropdownMenuEntry(value: 60, label: "1 Hour"),
    DropdownMenuEntry(value: 180, label: "3 Hours"),
    DropdownMenuEntry(value: 480, label: "8 Hours"),
    DropdownMenuEntry(value: 1440, label: "Daily"),    
  ];
  bool isMotivation = true;
  bool isSelfLove = true;
  bool isConfidence = true;
  bool isPeace = true;
  bool isSuccess = true;



  void _showNotificationCategorySelector() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Categories'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text('Motivation'),
                    value: isMotivation,
                    onChanged: (value) {
                      isMotivation = !isMotivation;
                      setDialogState(() {});
                      }
                  ),
                  CheckboxListTile(
                    title: Text('Self-love'),
                    value: isSelfLove,
                    onChanged: (value) {
                      isSelfLove = !isSelfLove;
                      setDialogState(() {});
                      }
                  ),CheckboxListTile(
                    title: Text('Confidence'),
                    value: isConfidence,
                    onChanged: (value) {
                      isConfidence = !isConfidence;
                      setDialogState(() {});
                      }
                  ),
                  CheckboxListTile(
                    title: Text('Peace'),
                    value: isPeace,
                    onChanged: (value) {
                      isPeace = !isPeace;
                      setDialogState(() {});
                    }
                  ),
                  CheckboxListTile(
                    title: Text('Success'),
                    value: isSuccess,
                    onChanged: (value) {
                      isSuccess = !isSuccess;
                      setDialogState(() {});
                      }
                  ),
                ]
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Confirm')
                )
              ]
            );
          }
        );
      }
    );
  }

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
                dropdownMenuEntries: rateEntries,
                initialSelection: rateEntries[2].value,
                onSelected: (value) => setState(() => notificationRate = value)
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notification Categories'),
              TextButton(
                onPressed: _showNotificationCategorySelector,
                child: Text('Open')
              )
            ],
          ),
        ]
      )
    );
  }
}