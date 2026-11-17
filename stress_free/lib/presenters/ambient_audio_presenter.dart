import 'package:stress_free/models/ambient_audio_model.dart';

class AmbientAudioPresenter {
  final List<AmbientAudio> _audioList = [
    AmbientAudio(name: 'Rain', filePath: 'audio/ambient/rain.wav'),
    AmbientAudio(name: 'Ocean', filePath: 'audio/ambient/ocean.mp3'),
    // Add more ambient audio options here
  ];
  late AmbientAudio _selectedAudio = _audioList[0];
  AmbientAudio get selectedAudio => _selectedAudio;

  List<AmbientAudio> get audioList => _audioList;

/*TODO

  Future<void> loadAudio() async {
    // In a real application, you might load audio data from a database or API.
    // For this example, we are using a hardcoded list of ambient audio.
  } 
*/

void selectAudio(AmbientAudio audio) {
    // In a real application, you might save the selected audio to a database or API.
    // For this example, we are simply updating the selected audio in memory.
    _selectedAudio = audio;
  }
/*TODO

  Future<void> addAudio(AmbientAudio audio) async {
    // In a real application, you might save the new audio to a database or API.
    // For this example, we are simply adding it to the local list.
    _audioList.add(audio);
  }

*/

  }


