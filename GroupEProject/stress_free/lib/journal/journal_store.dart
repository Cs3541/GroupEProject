import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores one journal entry per date (YYYY-MM-DD) on this device.
/// Amin can reuse clearAll() when implementing journal settings.
class JournalStore {
  static const String storageKey = 'stress_free_journal_entries';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<Map<String, String>> loadAll() async {
    final saved = await _prefs.getString(storageKey);
    if (saved == null || saved.isEmpty) return {};

    try {
      final decoded = jsonDecode(saved);
      if (decoded is! Map) return {};
      return decoded.map<String, String>(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } on FormatException {
      return {};
    }
  }

  Future<void> saveEntry(String date, String content) async {
    final entries = await loadAll();
    entries[date] = content;
    await _prefs.setString(storageKey, jsonEncode(entries));
  }

  Future<void> clearAll() async {
    await _prefs.remove(storageKey);
  }
}
