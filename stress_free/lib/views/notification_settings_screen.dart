import 'package:flutter/material.dart';
import '../models/notification_settings_model.dart';
import '../presenters/notification_presenter.dart';

class AffirmationSettingsScreen extends StatefulWidget {
  const AffirmationSettingsScreen({super.key});

  @override
  State<AffirmationSettingsScreen> createState() =>
      _AffirmationSettingsScreenState();
}

class _AffirmationSettingsScreenState
    extends State<AffirmationSettingsScreen>
    implements NotificationView {

  late NotificationSettingsModel model;
  late NotificationPresenter presenter;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    model = NotificationSettingsModel();

    presenter = NotificationPresenter(
      view: this,
      model: model,
    );

    presenter.loadSettings();
  }

  // Called when settings finish loading
  @override
  void onSettingsLoaded() {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // Called when settings finish saving
  @override
  void onSettingsSaved() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  // Called when something goes wrong
  @override
  void onError(String message) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _updateSettings(VoidCallback update) {
    setState(update);
    presenter.saveSettings();
  }

  void _showNotificationCategorySelector() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Categories'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _categoryCheckbox(
                    'Motivation',
                    model.isMotivation,
                    (value) {
                      setDialogState(() {
                        model.isMotivation = value!;
                      });
                    },
                  ),
                  _categoryCheckbox(
                    'Self-love',
                    model.isSelfLove,
                    (value) {
                      setDialogState(() {
                        model.isSelfLove = value!;
                      });
                    },
                  ),
                  _categoryCheckbox(
                    'Confidence',
                    model.isConfidence,
                    (value) {
                      setDialogState(() {
                        model.isConfidence = value!;
                      });
                    },
                  ),
                  _categoryCheckbox(
                    'Peace',
                    model.isPeace,
                    (value) {
                      setDialogState(() {
                        model.isPeace = value!;
                      });
                    },
                  ),
                  _categoryCheckbox(
                    'Success',
                    model.isSuccess,
                    (value) {
                      setDialogState(() {
                        model.isSuccess = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    presenter.saveSettings();
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _categoryCheckbox(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications Enabled'),
              Switch(
                value: model.isNotificationsEnabled,
                onChanged: (value) {
                  _updateSettings(() {
                    model.isNotificationsEnabled = value;
                  });
                },
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notification Frequency'),
              DropdownMenu<int>(
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 15, label: '15 Minutes'),
                  DropdownMenuEntry(value: 30, label: '30 Minutes'),
                  DropdownMenuEntry(value: 60, label: '1 Hour'),
                  DropdownMenuEntry(value: 180, label: '3 Hours'),
                  DropdownMenuEntry(value: 480, label: '8 Hours'),
                  DropdownMenuEntry(value: 1440, label: 'Daily'),
                ],
                initialSelection: model.notificationRate,
                onSelected: (value) {
                  if (value == null) return;

                  _updateSettings(() {
                    model.notificationRate = value;
                  });
                },
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notification Categories'),
              TextButton(
                onPressed: _showNotificationCategorySelector,
                child: const Text('Open'),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Only Send Favorites'),
              Switch(
                value: model.isFavoritesOnly,
                onChanged: (value) {
                  _updateSettings(() {
                    model.isFavoritesOnly = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}