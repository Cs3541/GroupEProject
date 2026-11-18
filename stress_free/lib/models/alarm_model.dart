import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

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

  Future<void> saveAlarm () async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('User is not logged in');
    }
    await _firestore.collection('alarms').doc(userId).set({
      'alarmOn': _alarmOn,
      'alarmTimeHour': _alarmTime.hour,
      'alarmTimeMinute': _alarmTime.minute,
      'alarmSound': _alarmSound,
      'notificationsOn': _notificationsOn,
      'alarmName': _alarmName,
      'userId': userId
    });
  }

  static Future<Alarm?> fetchAlarm() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('User is not logged in');
    }
    final doc = await _firestore.collection('alarms')
        .doc(userId)
        .get();
    if (!doc.exists) {return null;}
    final data = doc.data()!;
    return Alarm(
      alarmOn: data['alarmOn'] as bool,
      alarmTime: TimeOfDay(
        hour: data['alarmTimeHour'] as int,
        minute: data['alarmTimeMinute'] as int,
      ),
      alarmSound: data['alarmSound'] as String,
      notificationsOn: data['notificationsOn'] as bool,
      alarmName: data['alarmName'] as String,
    );
  }
}
