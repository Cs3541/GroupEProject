import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

class AlarmPresenter {
  final Alarm _alarm;
  String? _error;

  bool _alarmStopped = false;
  bool _isRinging = false; 
  bool _snoozing = false;
  late DateTime _snoozeTime;


  bool get alarmOn => _alarm.alarmOn;
  TimeOfDay get alarmTime => _alarm.alarmTime;
  bool get notificationsOn => _alarm.notificationsOn;
  String get alarmName => _alarm.alarmName;
  String? get error => _error;

  bool get alarmStopped => _alarmStopped;
  bool get isRinging => _isRinging;
  bool get snoozing => _snoozing;
  DateTime get snoozeTime => _snoozeTime;

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
      _snoozing = false; // Disable snooze
    } else if (snoozing) { // If the alarm is on, but is snoozing
      if (!currentTime.isBefore(_snoozeTime)) { // If the current time is or is after the snooze time
        _isRinging = true;
        _snoozing = false;
      } else { // current time is before the snooze time
        _isRinging = false;
      }
    } else if (_isRinging) { // Else if alarm is on, not snoozing, and is ringing
      // Keep state

    } else if ((currentTime.hour == _alarm.alarmTime.hour &&
              currentTime.minute == _alarm.alarmTime.minute)) {
      // If the alarm is on, is not snoozing, is not ringing, and current time matches
        if (!_alarmStopped) { // And it hasn't been stopped
          _isRinging = true;
        }
    } else { // If alarm is on, is not snoozing, is not ringing, but the current time doesn't match and it has been stopped
      _isRinging = false;
      _alarmStopped = false; // reset
    }
  }

  void stopAlarm() {
    _alarmStopped = true;
    _isRinging = false; 
    _snoozing = false; 
  }

  void snoozeAlarm() {
    if (_isRinging) {
      _isRinging = false;
      _snoozeTime = DateTime.now();
      _snoozeTime = _snoozeTime.add(Duration(minutes: 5));
      _snoozing = true;
    }
  }
}
