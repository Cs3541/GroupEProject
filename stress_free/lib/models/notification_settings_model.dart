import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettingsModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isNotificationsEnabled;
  int notificationRate;
  bool isFavoritesOnly;

  bool isMotivation;
  bool isSelfLove;
  bool isConfidence;
  bool isPeace;
  bool isSuccess;

  NotificationSettingsModel({
    this.isNotificationsEnabled = true,
    this.notificationRate = 60,
    this.isFavoritesOnly = false,
    this.isMotivation = true,
    this.isSelfLove = true,
    this.isConfidence = true,
    this.isPeace = true,
    this.isSuccess = true,
  });

  Future<void> loadSettings(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      isNotificationsEnabled =
          data['isNotificationsEnabled'] ?? true;

      notificationRate = data['notificationRate'] ?? 60;

      isFavoritesOnly = data['isFavoritesOnly'] ?? false;

      isMotivation = data['isMotivation'] ?? true;
      isSelfLove = data['isSelfLove'] ?? true;
      isConfidence = data['isConfidence'] ?? true;
      isPeace = data['isPeace'] ?? true;
      isSuccess = data['isSuccess'] ?? true;
    }
  }

  Future<void> saveSettings(String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .set({
      'isNotificationsEnabled': isNotificationsEnabled,
      'notificationRate': notificationRate,
      'isFavoritesOnly': isFavoritesOnly,
      'isMotivation': isMotivation,
      'isSelfLove': isSelfLove,
      'isConfidence': isConfidence,
      'isPeace': isPeace,
      'isSuccess': isSuccess,
    });
  }
}