import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

class AlarmPresenter {
    Alarm _alarm = Alarm( 
        alarmOn: false,
        alarmTime: TimeOfDay(hour: 8, minute: 0),
        notificationsOn: false,
        alarmName: 'My Alarm');

    bool get alarmOn => _alarm.alarmOn;
    TimeOfDay get alarmTime => _alarm.alarmTime;
    bool get notificationsOn => _alarm.notificationsOn;
    String get alarmName => _alarm.alarmName;

    void updateAlarm(bool alarmOn, TimeOfDay alarmTime, bool notificationsOn, String alarmName) {
        _alarm.updateAlarm(alarmOn, alarmTime, notificationsOn, alarmName);
    }
}