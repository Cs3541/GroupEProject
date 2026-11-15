import 'package:flutter/material.dart';

class NotificationSettings {
  bool isNotificationsEnabled = true;
  int notificationRate = 60;
  bool isFavoritesOnly = false;
  List<DropdownMenuEntry<dynamic>> rateEntries = [
    DropdownMenuEntry(value: 15, label: "15 Minutes"),
    DropdownMenuEntry(value: 30, label: "30 Minutes"),
    DropdownMenuEntry(value: 60, label: "1 Hour"),
    DropdownMenuEntry(value: 180, label: "3 Hours"),
    DropdownMenuEntry(value: 480, label: "8 Hours"),
    DropdownMenuEntry(value: 1440, label: "Daily"),    
  ];
  bool isMotivation = true;
  bool isSelfLove = true;
  bool isConfidence = true;
  bool isPeace = true;
  bool isSuccess = true;
  
  Future loadSettings() async {
    
  }
}