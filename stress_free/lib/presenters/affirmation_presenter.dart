import '../models/affirmation_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AffirmationPresenter {
  Future<List<Affirmation>> loadAffirmations() async {
    final String response = await rootBundle.loadString('assets/affirmation.json');
    final List<dynamic> data = jsonDecode(response);

    return data.map((json) => Affirmation.fromJson(json)).toList();
  }
  
}