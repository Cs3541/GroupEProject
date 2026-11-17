import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Connect to Firebase
class JournalStore {
  JournalStore({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _journals {
    final user = _auth.currentUser;

    // Organize journals by user
    if (user == null) {
      throw StateError(
        'No Firebase user is signed in. Sign in before opening the journal.',
      );
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journal_entries');
  }

  Future<void> saveEntry(
    String date,
    String content, {
    int? stressRating,
  }) async {
    if (stressRating != null &&
        (stressRating < 0 || stressRating > 10)) {
      throw RangeError.range(stressRating, 0, 10, 'stressRating');
    }

    final data = <String, dynamic>{
      'date': date,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (stressRating != null) {
      data['stressRating'] = stressRating;
    }

    await _journals.doc(date).set(
      data,
      SetOptions(merge: true),
    );
  }
}
