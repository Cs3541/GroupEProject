import 'package:flutter/material.dart';

class Alarm {
  bool _alarmOn;
  TimeOfDay _alarmTime;
  bool _notificationsOn;
  String _alarmName;

  bool get alarmOn => _alarmOn;
  TimeOfDay get alarmTime => _alarmTime;
  bool get notificationsOn => _notificationsOn;
  String get alarmName => _alarmName;

  Alarm({required bool alarmOn, required TimeOfDay alarmTime, required bool notificationsOn, required String alarmName})
    : _alarmOn = alarmOn,
      _alarmTime = alarmTime,
      _notificationsOn = notificationsOn,
      _alarmName = alarmName;

  void updateAlarm(bool alarmOn, TimeOfDay alarmTime,bool notificationsOn, String alarmName,) {
    this._alarmOn = alarmOn;
    this._alarmTime = alarmTime;
    this._notificationsOn = notificationsOn;
    this._alarmName = alarmName;
  }
}