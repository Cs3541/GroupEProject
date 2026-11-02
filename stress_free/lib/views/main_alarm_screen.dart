import 'package:flutter/material.dart';
import 'alarm_settings_screen.dart';
import '../presenters/alarm_presenter.dart'; 

class MainAlarmScreen extends StatefulWidget {
  const MainAlarmScreen({super.key});

  @override
  State<MainAlarmScreen> createState() => _MainAlarmScreenState();

}

class _MainAlarmScreenState extends State<MainAlarmScreen> {
  final AlarmPresenter _alarmPresenter = AlarmPresenter(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bedtime Alarm', style: TextStyle(fontSize: 22)),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlarmSettingsScreen(
                    alarmPresenter: _alarmPresenter,))
              );
              setState(() {});
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
            if (_alarmPresenter.alarmOn) ...[
              Text(_alarmPresenter.alarmName, style: TextStyle(fontSize: 20) ),
              Text(_alarmPresenter.alarmTime.format(context),  style: TextStyle(fontSize: 60)),
            ] else 
              Text("Alarm Off", style: TextStyle(fontSize: 60)),
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