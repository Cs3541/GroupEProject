import 'package:flutter/material.dart';
import '../presenters/alarm_presenter.dart';
import 'alarm_settings_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../views/homescreen.dart';

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
  bool _alarmStopped = false;
  bool _isRinging = false; 

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
    DateTime currentTime = DateTime.now();
    if (currentTime.hour != _alarmPresenter.alarmTime.hour ||
        currentTime.minute != _alarmPresenter.alarmTime.minute) {
      _alarmStopped = false;
      _isRinging = false;
    } else if (_alarmPresenter.alarmOn &&
        !_alarmStopped &&
        !_isRinging) {
      _audioPlayer.play(AssetSource('audio/alarm.wav'));
      _isRinging = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text('Bedtime Alarm', style: TextStyle(fontSize: 22)),
        centerTitle: true,
        leadingWidth: 100, 
        leading: TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Home', style: TextStyle(color: Colors.black),),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            iconColor: Colors.black
          ),
        ),
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
                await _audioPlayer.stop(); // Stop the alarm
                _alarmStopped = true; // The alarm should be stopped
                _isRinging = false;  // The alarm shouldn't ring
              },
              child: const Text('Stop Alarm', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
