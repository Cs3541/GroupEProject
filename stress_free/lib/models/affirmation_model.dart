
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Affirmation {
  final String text;
  bool isFavorite;
  final String category;

  Affirmation({
    required this.text,
    this.isFavorite = false,
    required this.category,
  });

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  factory Affirmation.fromJson(Map<String, dynamic> json) {
    return Affirmation(
      text: json['text'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      category: json['category'] as String,
    );
  }

  factory Affirmation.fromFirestore(Map<String, dynamic> data) {
    return Affirmation(
      text: data['text'] as String,
      isFavorite: data['isFavorite'] as bool? ?? true,
      category: data['category'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isFavorite': isFavorite,
      'category': category,
    };
  }

  static Future<List<Affirmation>> loadAffirmations(String userId) async {
    final String response = await rootBundle.loadString('assets/affirmation.json');
    final List<dynamic> data = jsonDecode(response);
    List<Affirmation> affirmations = data
        .map((json) => Affirmation.fromJson(json))
        .toList();
    final favoritesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
    final favoriteTexts = favoritesSnapshot.docs
        .map((doc) => doc.data()['text'] as String)
        .toSet();
    for (var affirmation in affirmations) {
      affirmation.isFavorite = favoriteTexts.contains(affirmation.text);
    }
    return affirmations;
  }

  Future<void> saveFavorite(String userId) async {
    final documentId = Uri.encodeComponent(text);
    final favoriteRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(documentId);
    if (isFavorite) {
      await favoriteRef.set(toFirestore());
    } else {
      await favoriteRef.delete();
    }
  }
}
