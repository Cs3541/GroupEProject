import 'package:shared_preferences/shared_preferences.dart';

/// Each option corresponds to a bundled font that also works offline.
enum JournalFont {
  roboto('Roboto', 'JournalRoboto'),
  serif('Serif', 'JournalSerif');

  const JournalFont(this.label, this.family);
  final String label;
  final String family;
}

class JournalPreferencesStore {
  JournalPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const fontKey = 'stress_free_journal_font';
  final SharedPreferencesAsync _preferences;

  Future<JournalFont> loadFont() async {
    final saved = await _preferences.getString(fontKey);
    return JournalFont.values.firstWhere(
      (font) => font.name == saved,
      orElse: () => JournalFont.roboto,
    );
  }

  Future<void> saveFont(JournalFont font) =>
      _preferences.setString(fontKey, font.name);
}
