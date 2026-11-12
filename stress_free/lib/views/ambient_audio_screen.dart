import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:stress_free/presenters/ambient_audio_presenter.dart';

class AmbientAudioScreen extends StatefulWidget {
  const AmbientAudioScreen({super.key});

  @override
  State<AmbientAudioScreen> createState() => _AmbientAudioScreenState();
}

class _AmbientAudioScreenState extends State<AmbientAudioScreen>{
  final AmbientAudioPresenter _presenter = AmbientAudioPresenter();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Duration _duration = const Duration();
  Duration _position = const Duration();

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the audio

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(()  => _position = _duration);
    });
  }

 @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /* TODO

  Future<void> _loadAudio() async {
    await _presenter.loadAudio();
    setState(() {
      _isLoading = false;
    });
  }
*/



  void _toggleAudio() {
    if (_isPlaying) {
      _audioPlayer.pause();
    }  
    else {
      _audioPlayer.play(AssetSource(_presenter.selectedAudio.filePath));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambient Audio', style: TextStyle(fontSize: 22)),
      ),
      body: 
          Column(
            children: [
                DropdownButton<String>(
                value: _presenter.selectedAudio.name,
                items: _presenter.audioList.map((audio) {
                  return DropdownMenuItem<String>(
                    value: audio.name,
                    child: Text(audio.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _presenter.selectAudio(_presenter.audioList.firstWhere((audio) => audio.name == newValue));
                    if (_isPlaying) {
                      _audioPlayer.stop();
                      _audioPlayer.play(AssetSource(_presenter.selectedAudio.filePath));
                    }
                  });
                },
              ),
              
              Spacer(),

              Stack(
                alignment: Alignment.center,
                children: [ 
                  Spacer(),
                  IconButton(
                      onPressed: _toggleAudio,
                      icon: Icon(_isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline, size: 50),
                      ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:[
                    Icon(Icons.volume_down),
                  Slider(
                    value: _audioPlayer.volume,
                    onChanged: (value) {
                      setState(() {
                        _audioPlayer.setVolume(value);
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 5,
                    label: 'Volume',
                  ),
                  Icon(Icons.volume_up),
                  ]
                  )
                ],
              ),

              Slider(
                value: _position.inSeconds.toDouble(),
                onChanged: (value) async {
                  await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  setState(() {});
                },
                min: 0.0,
                max: _duration.inSeconds.toDouble()
                ,
              ),
            ],
          ),
    );
  }
}