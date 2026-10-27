import 'package:flutter/material.dart';

class AlarmSettingsScreen extends StatelessWidget {
  const AlarmSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Settings'),
      ),
      body: Column(
        children: [
          Row( // Alarm On or Off
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm On or Off:'),
              Switch(
                value: true,
                onChanged: (value) {}
              ),  

            ], 
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm Time:'),
              Expanded(
                child: TextField(),
              ),
              ToggleButtons(
                isSelected: [true, false],
                onPressed: (value) {},
                children: [
                  Text('AM'),
                  Text('PM'),
                ]
              )
            ],
          ),
          Row( // Bedtime Notifications
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bedtime Notifications:'),
              Switch(
                value: true,
                onChanged: (value) {}
              ),
            ],
          ),
          Row( // Alarm Name
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm Name:'),
              Expanded(
                child: TextField()
              )
            ],  
          )   
        ] 
      )
    );
  }
}