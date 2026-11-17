import '../models/sleep_session_model.dart';

class SleepSessionPresenter {
  final List<SleepSession> _sleepSessions = [];
  SleepSession? _activeSession;

  List<SleepSession> get sleepSessions => _sleepSessions;
  SleepSession? get activeSession => _activeSession;

  Future<void> loadSessions() async {
    final sessions = await SleepSession.fetchSessions();
    _sleepSessions.clear();
    _activeSession = null;
    for (final session in sessions) {
      if (session.wakeUpTime == null) {
        if (_activeSession != null) {
          throw StateError('ERROR: Multiple active sessions found');
        }
        _activeSession = session;
      } else {
        _sleepSessions.add(session);
      }
    }
  }

  Future<void> addSession(DateTime sleep) async {
    if (_activeSession == null) {
      final newSession = SleepSession(sleepTime: sleep);
      await newSession.addSession();
      _activeSession = newSession;
    } else {
      print("ERROR: Sleep session already in progress");
      return;
    }
  }

  Future<void> endSession(DateTime wakeUp) async {
    if (_activeSession != null) {
      final finished = _activeSession!; // ! -> Assured activeSession is not null
      finished.wakeUpTime = wakeUp;
      try {
        await finished.updateSession();
        _sleepSessions.add(finished);
        _activeSession = null;
      } catch (e) {
        finished.wakeUpTime = null;
        rethrow;
      } 
    } else {
      print("ERROR: No active session to end");
      return;
    }
  }

  Future<bool> undoWakeUp()  async {
    if (_sleepSessions.isNotEmpty && _activeSession == null) { // If there are sleep sessions and no active session
      final previous = _sleepSessions.last;
      final originalWakeUpTime = previous.wakeUpTime;
      previous.wakeUpTime = null;
      try {
        await previous.updateSession();
        _sleepSessions.removeLast();
        _activeSession = previous;
        return true;
      } catch (e) {
        previous.wakeUpTime = originalWakeUpTime;
        rethrow;
        
      }
    } else {
      return false;
    } 
  }
}