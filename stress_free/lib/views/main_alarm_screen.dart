import 'package:flutter/material.dart';
import '../presenters/alarm_presenter.dart';
import '../presenters/sleep_session_presenter.dart';
import 'alarm_settings_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../views/homescreen.dart';

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
  late bool _isSleeping;
  bool _wasRinging = false; // Was alarm ringing in previous alarm check

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
    _timer = Timer.periodic(const Duration(seconds: 1), playAlarm); // Calls playAlarm every second
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer.cancel();
    super.dispose(); 
  }

  void playAlarm(Timer timer) {
    _alarmPresenter.checkAlarmTime(); // Check the alarm time (every second)
    if (!_wasRinging  && _alarmPresenter.isRinging) { // If the alarm wasn't already ringing and it is now ringing
      _audioPlayer.play(AssetSource('audio/alarm.wav')); // Play the alarm 
    }
    if (_wasRinging && !_alarmPresenter.isRinging) { // If the alarm was ringing and now its not ringing
      _audioPlayer.stop(); // Stop the audio
    }
     _wasRinging = _alarmPresenter.isRinging; // Screen knows alarm state
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
              onPressed: () {
                _alarmPresenter.stopAlarm();
              },
              child: const Text('Stop Alarm', style: TextStyle(fontSize: 20))
            ),
            SizedBox(height:10),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Snooze', style: TextStyle(fontSize: 20))
            ),
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
