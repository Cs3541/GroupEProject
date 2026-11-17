import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Stores journals and optional 0–10 stress ratings in Cloud Firestore.
//Firebase must be initialized and a user must be signed in before calling
// these methods. 

class JournalStore {
  JournalStore({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _journals {
    final user = _auth.currentUser;
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

  ///Reads all journal text, using each document's date as the map key.
  Future<Map<String, String>> loadAll() async {
    final snapshot = await _journals.get();
    final entries = <String, String>{};

    for (final document in snapshot.docs) {
      final content = document.data()['content'];
      if (content is String) {
        entries[document.id] = content;
      }
    }

    return entries;
  }

  //Reads ratings for all dates that have valid rating.
  // Journals without a rating are not assigned a default value.
  Future<Map<String, int>> loadAllStressRatings() async {
    final snapshot = await _journals.get();
    final ratings = <String, int>{};

    for (final document in snapshot.docs) {
      final rating = document.data()['stressRating'];
      if (rating is int && rating >= 0 && rating <= 10) {
        ratings[document.id] = rating;
      }
    }

    return ratings;
  }

  /// Returns one day's rating, or null if that day has no saved rating.
  Future<int?> loadStressRating(String date) async {
    final document = await _journals.doc(date).get();
    final rating = document.data()?['stressRating'];
    return rating is int && rating >= 0 && rating <= 10 ? rating : null;
  }

  /// Creates or updates the entry for a date.

  Future<void> saveEntry(
    String date,
    String content, {
    int? stressRating,
  }) async {
    if (stressRating != null && (stressRating < 0 || stressRating > 10)) {
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

  
    await _journals.doc(date).set(data, SetOptions(merge: true));
  }

  // Deletes the entire day's document, including its optional rating.
  Future<void> deleteEntry(String date) async {
    await _journals.doc(date).delete();
  }

  // Deletes the signed-in user's journals
  Future<void> clearAll() async {
    final journals = _journals;

    while (true) {
      final snapshot = await journals.limit(200).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }
}
