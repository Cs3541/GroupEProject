import 'package:flutter/material.dart';

import '../presenters/alarm_presenter.dart';

class AlarmSettingsScreen extends StatefulWidget {
  const AlarmSettingsScreen({super.key, required AlarmPresenter alarmPresenter})
    : _alarmPresenter = alarmPresenter;

  final AlarmPresenter _alarmPresenter;

  @override
  State<AlarmSettingsScreen> createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  // Stores user inputs until Save succeeds.
  late bool _alarmOn;
  late TimeOfDay _alarmTime;
  late bool _notificationsOn;
  late String _alarmName;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _alarmOn = widget._alarmPresenter.alarmOn;
    _alarmTime = widget._alarmPresenter.alarmTime;
    _notificationsOn = widget._alarmPresenter.notificationsOn;
    _alarmName = widget._alarmPresenter.alarmName;
  }

  void _save() {
    if (widget._alarmPresenter.updateAlarm(
      _alarmOn,
      _alarmTime,
      _notificationsOn,
      _alarmName,
    )) {
      Navigator.pop(context);
    } else {
      setState(() => _nameError = widget._alarmPresenter.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Alarm Settings')),
      body: Column(
        children: [
          Row(
            // Alarm On or Off
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm On or Off:'),
              Switch(
                value: _alarmOn,
                onChanged: (value) => setState(() => _alarmOn = value),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm Time:'),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _alarmTime,
                  );
                  if (!mounted || picked == null) return;
                  setState(() => _alarmTime = picked);
                },
                child: Text(_alarmTime.format(context)),
              ),
            ],
          ),
          Row(
            // Bedtime Notifications
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Bedtime Notifications:'),
              Switch(
                value: _notificationsOn,
                onChanged: (value) => setState(() => _notificationsOn = value),
              ),
            ],
          ),
          Row(
            // Alarm Name
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarm Name:'),
              Expanded(
                child: TextFormField(
                  initialValue: _alarmName,
                  decoration: InputDecoration(
                    hintText: 'Alarm name',
                    errorText: _nameError,
                  ),
                  onChanged: (value) => _alarmName = value,
                  onFieldSubmitted: (_) => _save(),
                ),
              ),
            ],
          ),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
