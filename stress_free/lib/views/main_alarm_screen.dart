import 'package:flutter/material.dart';
import 'alarm_settings_screen.dart';

class MainAlarmScreen extends StatelessWidget {
    const MainAlarmScreen({super.key});
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Bedtime Alarm', style: TextStyle(fontSize: 22)),
              actions: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlarmSettingsScreen())
                        );
                      },
                      icon: Icon(Icons.settings)
                  )
              ] 
            ),
            body:
            Center(
              child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Alarm Title goes Here', style: TextStyle(fontSize: 20) ),
                  Text('8:00 AM',  style: TextStyle(fontSize: 60)),
                  ElevatedButton(
                      onPressed: () {},
                      child: Text('Stop Alarm', style: TextStyle(fontSize: 20))
                  )
                ]
              ),   
            )       
        );
    }
}