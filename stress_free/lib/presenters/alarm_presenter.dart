import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

class AlarmPresenter {
  final Alarm _alarm;
  String? _error;

  bool _alarmStopped = false;
  bool _isRinging = false; 
  bool _snoozing = false;


  bool get alarmOn => _alarm.alarmOn;
  TimeOfDay get alarmTime => _alarm.alarmTime;
  bool get notificationsOn => _alarm.notificationsOn;
  String get alarmName => _alarm.alarmName;
  String? get error => _error;

  bool get alarmStopped => _alarmStopped;
  bool get isRinging => _isRinging;
  bool get snoozing => _snoozing;

  AlarmPresenter({Alarm? alarm})
      : _alarm =
            alarm ??
            Alarm(
              alarmOn: false,
              alarmTime: const TimeOfDay(hour: 8, minute: 0),
              notificationsOn: false,
              alarmName: 'My Alarm',
            );

  bool updateAlarm(
    bool alarmOn,
    TimeOfDay alarmTime,
    bool notificationsOn,
    String alarmName,
  ) {
    final name = alarmName.trim();
    if (name.isEmpty) {
      _error = 'Enter an alarm name.';
      return false;
    }
    _alarm.updateAlarm(alarmOn, alarmTime, notificationsOn, name);
    _error = null;
    return true;
  }

  void checkAlarmTime() {
    DateTime currentTime = DateTime.now(); // Current time
    if (!alarmOn) { // If the alarm is off
      _isRinging = false; // the alarm should not ring. 
    } else if (currentTime.hour != _alarm.alarmTime.hour ||
        currentTime.minute != _alarm.alarmTime.minute) { // Else If the alarm is on and current time is not the alarm time
      _alarmStopped = false; // Reset alarm stopped
      _isRinging = false; // Alarm should not ring
    } else if (!_alarmStopped && !_isRinging) { // Else if the alarm is on, the time does match, hasn't been stopped, and is not already ringing
      _isRinging = true; // The alarm should now ring
    }
  }

  void stopAlarm() {
    _alarmStopped = true;
    _isRinging = false; 
  }
}
