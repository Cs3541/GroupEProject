import 'package:flutter/material.dart';
import '../presenters/alarm_presenter.dart';
import '../presenters/sleep_session_presenter.dart';
import 'alarm_settings_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../views/homescreen.dart';

class MainAlarmScreen extends StatefulWidget {
  const MainAlarmScreen({super.key, this.aPresenter, this.sPresenter});

  final AlarmPresenter? aPresenter;
  final SleepSessionPresenter? sPresenter;

  @override
  State<MainAlarmScreen> createState() => _MainAlarmScreenState();
}

class _MainAlarmScreenState extends State<MainAlarmScreen> {
  late final AlarmPresenter _alarmPresenter;
  late final SleepSessionPresenter _sleepPresenter;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  bool _isSleeping = false;
  bool _loadingSessions = true;
  bool _wasRinging = false; // Was alarm ringing in previous alarm check
  bool _loadingAlarm = true;

  @override
  void initState() {
    super.initState();
    _alarmPresenter = widget.aPresenter ?? AlarmPresenter();
    _sleepPresenter = widget.sPresenter ?? SleepSessionPresenter();
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Alarm loops 
    initializeScreen();
  }

  Future<void> initializeScreen() async {
    loadSleepSessions();
    try {
    await _alarmPresenter.loadAlarm();
    if (!mounted) return;
    setState(() {
      _loadingAlarm = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), playAlarm,);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingAlarm = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load alarm settings')),
      );
    }
  }

  Future<void> loadSleepSessions() async {
    try{
      await _sleepPresenter.loadSessions();
      if (!mounted) {return;}
      setState(() {
        _isSleeping = _sleepPresenter.activeSession != null;
        _loadingSessions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingSessions = false;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load sleep sessions')),
      );
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose(); 
  }

  void playAlarm(Timer timer) {
    _alarmPresenter.checkAlarmTime(); // Check the alarm time (every second)
    if (!_wasRinging  && _alarmPresenter.isRinging) { // If the alarm wasn't already ringing and it is now ringing
      _audioPlayer.play(AssetSource(_alarmPresenter.alarmSound)); // Play the alarm 
    }
    if (_wasRinging && !_alarmPresenter.isRinging) { // If the alarm was ringing and now its not ringing
      _audioPlayer.stop(); // Stop the audio
    }
     _wasRinging = _alarmPresenter.isRinging; // Screen knows alarm state
     setState(() {});
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
            if (_alarmPresenter.snoozing) 
              Text("Snoozing Until: ${TimeOfDay.fromDateTime(_alarmPresenter.snoozeTime).format(context)}"),
            SizedBox(
              width: double.infinity,
              height: 90,
              child: 
                ElevatedButton(
                  onPressed: _alarmPresenter.isRinging || _alarmPresenter.snoozing ?() {
                    _alarmPresenter.stopAlarm(); 
                  }: null,
                  child: const Text('Stop Alarm', style: TextStyle(fontSize: 20))
                ),
            ),
        
            SizedBox(height:10),
            SizedBox(
              width: double.infinity,
              height: 90,
              child: 
                ElevatedButton(
                  onPressed: _alarmPresenter.isRinging ? () {
                    _alarmPresenter.snoozeAlarm();
                    }: null,
                  child: const Text('Snooze', style: TextStyle(fontSize: 20))
                ), 
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
                      onPressed: !_isSleeping && !_loadingSessions ? () async {
                        try {
                          await _sleepPresenter.addSession(DateTime.now());
                          if (!mounted) return;
                          setState((){
                            _isSleeping = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Rest Well!")));
                        } catch (e) {
                          if (!mounted) {return;}
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Could not start sleep session")));
                        }
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
                      onPressed: _isSleeping && !_loadingSessions ? () async {
                        try {
                          await _sleepPresenter.endSession(DateTime.now());
                          if (!mounted) {return;}
                          setState(() {
                            _isSleeping = false;
          
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Sleep Session Saved!"),
                            duration: Duration(seconds: 6),
                            persist: false,
                            action: SnackBarAction(
                              label: "UNDO",
                              onPressed: () async {
                                try {
                                  bool undone = await _sleepPresenter.undoWakeUp();
                                  if (!mounted) return;
                                  if(undone) {setState((){_isSleeping = true;});}
                                } catch (e) {
                                  if (!mounted) {return;}
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Could not save sleep session")),
                                    );

                                }
                                
                                },
                            )
                          )
                        );
                        } catch (e) {
                          if (!mounted) {return;}
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Could not save sleep session: $e")),
                          );
                        }  
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
