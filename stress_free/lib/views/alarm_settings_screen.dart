import 'package:flutter/material.dart';
import '../presenters/alarm_presenter.dart'; 


class AlarmSettingsScreen extends StatefulWidget {
  final AlarmPresenter _alarmPresenter;
  const AlarmSettingsScreen({super.key, required AlarmPresenter alarmPresenter})
    :_alarmPresenter = alarmPresenter;

  @override
  State<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();


}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  
  // Stores user inputs
  late bool _alarmOn;
  late TimeOfDay _alarmTime;
  late bool _notificationsOn;
  late String _alarmName; 


  @override
  void initState() {
    super.initState();
    _alarmOn = widget._alarmPresenter.alarmOn;
    _alarmTime = widget._alarmPresenter.alarmTime;
    _notificationsOn = widget._alarmPresenter.notificationsOn;
    _alarmName = widget._alarmPresenter.alarmName; 
  }

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
                value: _alarmOn,
                onChanged: (bool v) {
                  setState(() {_alarmOn = v;});
                }
              ),  

            ], 
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm Time:'), 
              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _alarmTime
                  );
                  if (picked != null) {
                    _alarmTime = picked;
                  }
                  setState(() {});
                },
                child: Text(_alarmTime.format(context))
              )
            ],
          ),
          Row( // Bedtime Notifications
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bedtime Notifications:'),
              Switch(
                value: _notificationsOn,
                onChanged: (v) {
                  setState(() {_notificationsOn = v;});
                }
              ),
            ],
          ),
          Row( // Alarm Name
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm Name:'),
              Expanded(
                child: TextFormField(
                   initialValue: _alarmName,
                   onChanged: (v) {
                    setState(() {_alarmName = v;});
                   }
                )
              )
            ],  
          ),
          Row( // Save Button 
            children: [
              ElevatedButton(
                onPressed: () {
                  widget._alarmPresenter.updateAlarm(
                    _alarmOn, _alarmTime, _notificationsOn, _alarmName
                  );
                  Navigator.pop(context);
                },
                child: Text('Save')
              )
            ]
          )  
        ] 
      )
    );
  }
}