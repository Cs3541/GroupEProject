import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SleepSession {
  DateTime _sleepTime;
  DateTime? _wakeUpTime;
  String? _documentId;
 

  DateTime get sleepTime => _sleepTime;
  DateTime? get wakeUpTime => _wakeUpTime;
  String? get documentId => _documentId;
 
  set wakeUpTime(DateTime? wakeUp) {
    this._wakeUpTime = wakeUp;
  }

  SleepSession({required DateTime sleepTime, DateTime? wakeUpTime, String? documentId}) : 
    _sleepTime = sleepTime,
    _wakeUpTime = wakeUpTime,
    _documentId = documentId;

  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

    Future<void> addSession() async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {return;}
      final doc = await _firestore.collection('sleepSessions').add({
        'sleepTime': Timestamp.fromDate(_sleepTime),
        'wakeUpTime': null,
        'userId': userId,
      });

      _documentId = doc.id;
    }
    static Future<List<SleepSession>> fetchSessions() async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];
      final snapshot = await _firestore
      .collection('sleepSessions')
      .where('userId', isEqualTo: userId)
      .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SleepSession(
          sleepTime: (data['sleepTime'] as Timestamp).toDate(),
          wakeUpTime: (data['wakeUpTime'] as Timestamp?)?.toDate(),
          documentId: doc.id,
        );
      }).toList();
    }
    Future<void> updateSession() async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {return;}
      if(_documentId == null) {return;}
      await _firestore
      .collection('sleepSessions')
      .doc(_documentId)
      .update({
        'wakeUpTime': _wakeUpTime == null
          ? null
          : Timestamp.fromDate(_wakeUpTime!),
      });
    }
}