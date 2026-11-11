// import 'package:flutter/material.dart';

class SleepSession {
  DateTime _sleepTime;
  DateTime? _wakeUpTime;
 

  DateTime get sleepTime => _sleepTime;
  DateTime? get wakeUpTime => _wakeUpTime;
 
  set wakeUpTime(DateTime? wakeUp) {
    this._wakeUpTime = wakeUp;
  }

  SleepSession({required DateTime sleepTime}) : 
    _sleepTime = sleepTime;
}





