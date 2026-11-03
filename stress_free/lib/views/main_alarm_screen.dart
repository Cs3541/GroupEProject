import 'package:flutter/material.dart';
import '../presenters/alarm_presenter.dart';
import 'alarm_settings_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MainAlarmScreen extends StatefulWidget {
  const MainAlarmScreen({super.key, this.presenter});

  final AlarmPresenter? presenter;

  @override
  State<MainAlarmScreen> createState() => _MainAlarmScreenState();
}

class _MainAlarmScreenState extends State<MainAlarmScreen> {
  late final AlarmPresenter _alarmPresenter;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _alarmPresenter = widget.presenter ?? AlarmPresenter();
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Alarm loops 
    _timer = Timer.periodic(const Duration(seconds: 1), _checkAlarmTime);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer.cancel();
    super.dispose(); 
  }

  void _checkAlarmTime(Timer timer) {
    print(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bedtime Alarm', style: TextStyle(fontSize: 22)),
        actions: [
          IconButton(
            tooltip: 'Alarm settings',
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AlarmSettingsScreen(alarmPresenter: _alarmPresenter),
                ),
              );
              if (!mounted) return;
              setState(() {});
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _alarmPresenter.alarmName,
              style: const TextStyle(fontSize: 20),
            ),
            if (_alarmPresenter.alarmOn)
              Text(
                _alarmPresenter.alarmTime.format(context),
                style: const TextStyle(fontSize: 60),
              )
            else
              const Text('Alarm Off', style: TextStyle(fontSize: 60)),
            ElevatedButton(
              onPressed: () async {
                // testing if the alarm sound works
                await _audioPlayer.stop();
              },
              child: const Text('Stop Alarm', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
