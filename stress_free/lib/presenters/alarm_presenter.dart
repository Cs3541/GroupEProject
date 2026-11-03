import 'package:flutter/material.dart';

import '../models/alarm_model.dart';

class AlarmPresenter {
  AlarmPresenter({Alarm? alarm})
    : _alarm =
          alarm ??
          Alarm(
            alarmOn: false,
            alarmTime: const TimeOfDay(hour: 8, minute: 0),
            notificationsOn: false,
            alarmName: 'My Alarm',
          );

  final Alarm _alarm;
  String? _error;

  bool get alarmOn => _alarm.alarmOn;
  TimeOfDay get alarmTime => _alarm.alarmTime;
  bool get notificationsOn => _alarm.notificationsOn;
  String get alarmName => _alarm.alarmName;
  String? get error => _error;

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
}
