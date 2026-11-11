import 'package:flutter/material.dart';
import '../presenters/alarm_presenter.dart';
import '../presenters/sleep_session_presenter.dart';
import 'alarm_settings_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MainAlarmScreen extends StatefulWidget {
  const MainAlarmScreen({super.key, this.aPresenter, this.ssPresenter});

  final AlarmPresenter? aPresenter;
  final SleepSessionPresenter? ssPresenter;

  @override
  State<MainAlarmScreen> createState() => _MainAlarmScreenState();
}

class _MainAlarmScreenState extends State<MainAlarmScreen> {
  late final AlarmPresenter _alarmPresenter;
  late final SleepSessionPresenter _sleepPresenter;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final Timer _timer;
  bool _alarmStopped = false;
  bool _isRinging = false; 
  late bool _isSleeping;

  @override
  void initState() {
    super.initState();
    _alarmPresenter = widget.aPresenter ?? AlarmPresenter();
    _sleepPresenter = widget.ssPresenter ?? SleepSessionPresenter();
    if (_sleepPresenter.activeSession != null) {
      _isSleeping = true;
    } else {
      _isSleeping = false;
    }
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
        title: const Text('Bedtime Alarm', style: TextStyle(fontSize: 22)),
        actions: [
          IconButton(
            tooltip: 'Alarm settings',
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AlarmSettingsScreen(alarmPresenter: _alarmPresenter, sleepPresenter: _sleepPresenter),
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
              child: const Text('Stop Alarm', style: TextStyle(fontSize: 20))
            ),
            SizedBox(height:10),
            Row(
              children: [
                Expanded(
                  child: 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 120)
                      ),
                      onPressed: !_isSleeping ? () {
                        _sleepPresenter.addSession(DateTime.now());
                        _isSleeping = true;
                        setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Rest Well!"))
                        );
                      }: null, // disable the button
                      child: Text('Sleep')
                    ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 120)
                      ),
                      onPressed: _isSleeping ? () {
                        _sleepPresenter.endSession(DateTime.now());
                        _isSleeping = false;
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Sleep Session Saved!"),
                            duration: Duration(seconds: 6),
                            persist: false,
                            action: SnackBarAction(
                              label: "UNDO",
                              onPressed: () {
                                bool undone = _sleepPresenter.undoWakeUp();
                                if(undone) {setState((){_isSleeping = true;});}
                                },
                            )
                          )
                        );
                      }: null,
                      child: Text('Wake Up')
                    ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
