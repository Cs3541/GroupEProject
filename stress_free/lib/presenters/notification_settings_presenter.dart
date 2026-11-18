import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_settings_model.dart';

abstract class NotificationView {
  void onSettingsLoaded();
  void onSettingsSaved();
  void onError(String message);
}

class NotificationPresenter {
  final NotificationView view;
  final NotificationSettingsModel model;

  NotificationPresenter({
    required this.view,
    required this.model,
  });

  Future<void> loadSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in');
      }

      await model.loadSettings(user.uid);

      view.onSettingsLoaded();
    } catch (e) {
      view.onError(e.toString());
    }
  }

  Future<void> saveSettings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User is not logged in');
      }

      await model.saveSettings(user.uid);

      view.onSettingsSaved();
    } catch (e) {
      view.onError(e.toString());
    }
  }
}