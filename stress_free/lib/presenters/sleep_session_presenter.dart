import '../models/sleep_session_model.dart';

class SleepSessionPresenter {
  final List<SleepSession> _sleepSessions = [];
  SleepSession? _activeSession = null;

  List<SleepSession> get sleepSessions => _sleepSessions;
  SleepSession? get activeSession => _activeSession;

  void addSession(DateTime sleep) {
    if (_activeSession == null) {
      SleepSession newSession = SleepSession(sleepTime: sleep);
      _activeSession = newSession;
    } else {
      print("ERROR: Sleep session already in progress");
    }
  }

  void endSession(DateTime wakeUp) {
    if (_activeSession != null) {
      SleepSession finished = _activeSession!; // ! -> Assured activeSession is not null
      finished.wakeUpTime = wakeUp;
      _sleepSessions.add(finished);
      _activeSession = null;
    } else {
      print("ERROR: No active session to end");
    }
  }

  bool undoWakeUp() {
    if (_sleepSessions.isNotEmpty && _activeSession == null) { // If there are sleep sessions and no active session
      SleepSession previous = _sleepSessions.last;
      _sleepSessions.removeLast();
      previous.wakeUpTime = null;
      _activeSession = previous;
      return true;
    }
    return false;
  }

  // bool deleteLastSession() {
  //   if (_sleepSessions.isNotEmpty) {
  //     _sleepSessions.removeLast();
  //     return true;
  //   } 
  //   return false;
  // }
}