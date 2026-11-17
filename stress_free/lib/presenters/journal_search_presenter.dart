import 'package:flutter/foundation.dart';

/// Filters saved journal content while leaving storage and navigation unchanged.
class JournalSearchPresenter extends ChangeNotifier {
  Map<String, String> _entries = const {};
  String _query = '';

  Map<String, String> get entries => _entries;
  bool get searching => _query.isNotEmpty;

  /// Newest first, including older entries beyond the recent-entry list.
  List<String> get visibleDates {
    final dates = _entries.entries
        .where((entry) => entry.value.toLowerCase().contains(_query))
        .map((entry) => entry.key)
        .toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  void updateEntries(Map<String, String> entries) {
    _entries = Map.unmodifiable(entries);
    notifyListeners();
  }

  /// A trimmed, case-insensitive literal keyword or phrase within the content.
  void search(String query) {
    _query = query.trim().toLowerCase();
    notifyListeners();
  }
}
