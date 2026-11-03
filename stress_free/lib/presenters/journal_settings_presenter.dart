import 'package:flutter/foundation.dart';

import '../models/journal_preferences_store.dart';
import '../models/journal_store.dart';

/// Owns settings state; views supply dialogs and render the results.
class JournalSettingsPresenter extends ChangeNotifier {
  JournalSettingsPresenter({
    JournalStore? journals,
    JournalPreferencesStore? preferences,
  }) : _journals = journals ?? JournalStore(),
       _preferences = preferences ?? JournalPreferencesStore();

  final JournalStore _journals;
  final JournalPreferencesStore _preferences;
  JournalFont _font = JournalFont.roboto;
  bool _busy = false;
  bool _confirming = false;
  bool _disposed = false;
  String? _message;

  JournalFont get font => _font;
  List<JournalFont> get fonts => JournalFont.values;
  bool get busy => _busy || _confirming;
  bool get working => _busy;
  String? get message => _message;

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadFont() async {
    if (busy || _disposed) return;
    _busy = true;
    _message = null;
    _publish();
    try {
      _font = await _preferences.loadFont();
    } catch (_) {
      _message = 'Could not load the journal font. Try reopening settings.';
    } finally {
      _busy = false;
      _publish();
    }
  }

  Future<void> selectFont(JournalFont font) async {
    if (busy || _disposed || font == _font) return;
    _busy = true;
    _message = null;
    _publish();
    try {
      await _preferences.saveFont(font);
      _font = font;
      _message = 'Journal font saved.';
    } catch (_) {
      _message =
          'Could not save the font. Your previous font is still selected.';
    } finally {
      _busy = false;
      _publish();
    }
  }

  Future<void> clearAll({required Future<bool> Function() confirm}) async {
    if (busy || _disposed) return;
    _confirming = true;
    _message = null;
    _publish();
    try {
      if (await confirm() && !_disposed) {
        _confirming = false;
        _busy = true;
        _publish();
        await _journals.clearAll();
        _message = 'All journal entries deleted.';
      }
    } catch (_) {
      _message = 'Could not delete journals. Please try again.';
    } finally {
      _confirming = false;
      _busy = false;
      _publish();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
