import 'package:flutter/material.dart';

class Alarm {
  bool _alarmOn;
  TimeOfDay _alarmTime;
  String _alarmSound;
  bool _notificationsOn;
  String _alarmName;

  bool get alarmOn => _alarmOn;
  TimeOfDay get alarmTime => _alarmTime;
  String get alarmSound => _alarmSound;
  bool get notificationsOn => _notificationsOn;
  String get alarmName => _alarmName;

  Alarm({
    required bool alarmOn,
    required TimeOfDay alarmTime,
    required String alarmSound,
    required bool notificationsOn,
    required String alarmName,
  }) : _alarmOn = alarmOn,
       _alarmTime = alarmTime,
       _alarmSound = alarmSound,
       _notificationsOn = notificationsOn,
       _alarmName = alarmName;

  void updateAlarm(
    bool alarmOn,
    TimeOfDay alarmTime,
    String alarmSound,
    bool notificationsOn,
    String alarmName,
  ) {
    _alarmOn = alarmOn;
    _alarmTime = alarmTime;
    _alarmSound = alarmSound;
    _notificationsOn = notificationsOn;
    _alarmName = alarmName;
  }
}
