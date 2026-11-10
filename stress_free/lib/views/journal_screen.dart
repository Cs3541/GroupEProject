import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/journal_preferences_store.dart';
import '../models/journal_store.dart';
import '../presenters/journal_settings_presenter.dart';
import 'journal_edit_screen.dart';
import 'journal_settings_screen.dart';

class JournalScreen extends StatefulWidget {
  /// navigate to this screen from Home.
  /// supply a callback to open settings screen.
  const JournalScreen({
    super.key,
    this.onOpenSettings,
    this.store,
    this.preferences,
  });

  final FutureOr<void> Function()? onOpenSettings;
  final JournalStore? store;
  final JournalPreferencesStore? preferences;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  late final JournalStore _store;
  late final JournalPreferencesStore _preferences;
  late final JournalSettingsPresenter _settings;
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> _entries = {};
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? JournalStore();
    _preferences = widget.preferences ?? JournalPreferencesStore();
    _settings = JournalSettingsPresenter(
      journals: _store,
      preferences: _preferences,
    );
    _refreshEntries();
  }

  Future<void> _refreshEntries() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final entries = await _store.loadAll();
      await _settings.loadFont();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
      if (_settings.message != null) _showMessage(_settings.message!);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _openSettings() async {
    if (widget.onOpenSettings != null) {
      await widget.onOpenSettings!();
    } else {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => JournalSettingsScreen(
            journals: _store,
            preferences: _preferences,
          ),
        ),
      );
    }
    if (mounted) await _refreshEntries();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDeleteEntry(String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete journal entry?'),
        content: Text('Are you sure you want to delete the entry for $date?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _store.deleteEntry(date);
    if (mounted) await _refreshEntries();
  }

  Future<void> _openEditor(String date) async {
    if (_loading || _loadFailed) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => JournalEditorScreen(
          store: _store,
          initialDate: date,
          initialText: _entries[date] ?? '',
          font: _settings.font,
        ),
      ),
    );
    if (mounted) await _refreshEntries();
  }

  // Opens an iOS-style scrolling date picker (year / month / day).
  Future<void> _pickSearchDate() async {
    final initialDate =
        DateTime.tryParse(_searchController.text.trim()) ?? DateTime.now();
    DateTime selectedDate = initialDate;

    final pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SizedBox(
          height: 340,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  const Text(' Please Select a date'),
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(selectedDate),
                    child: const Text('Done'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.ymd,
                  minimumYear: 1900,
                  maximumYear: 2100,
                  initialDateTime: initialDate,
                  onDateTimeChanged: (date) => selectedDate = date,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || pickedDate == null) return;

    final year = pickedDate.year.toString().padLeft(4, '0');
    final month = pickedDate.month.toString().padLeft(2, '0');
    final day = pickedDate.day.toString().padLeft(2, '0');
    setState(() => _searchController.text = '$year-$month-$day');
  }

  void _viewByDate() {
    // Per user story 2: an empty search does nothing for now.
    if (_searchController.text.trim().isEmpty) return;

    final date = validatedDate(_searchController.text);
    if (date == null) {
      _showMessage('Enter a valid date as YYYY-MM-DD.');
      return;
    }
    _openEditor(date);
  }

  void _createNew() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    // One entry per date: if today's entry already exists, reopen it.
    _openEditor(today);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dates = _entries.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflective Journaling'),
        actions: [
          IconButton(
            tooltip: 'Journal settings',
            icon: const Icon(Icons.settings),
            onPressed: _loading ? null : _openSettings,
          ),
        ],
      ),
      body: _loading || _loadFailed
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Could not load journals. Please try again.',
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshEntries,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Find an entry by date'),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  readOnly: true,
                  onTap: _pickSearchDate,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Entry date',
                    hintText: 'YYYY-MM-DD',
                    suffixIcon: IconButton(
                      tooltip: 'Select date',
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _pickSearchDate,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _viewByDate,
                  child: const Text('View'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent entries',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (dates.isEmpty)
                  const Text('No journal entries yet. Tap + to start writing.')
                else
                  ...dates
                      .take(10)
                      .map(
                        (date) => Card(
                          child: ListTile(
                            title: Text(
                              date,
                              style: TextStyle(
                                fontFamily: _settings.font.family,
                              ),
                            ),
                            subtitle: Text(
                              _entries[date]!.trim().isEmpty
                                  ? '(Empty entry)'
                                  : _entries[date]!.replaceAll('\n', ' '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: _settings.font.family,
                              ),
                            ),
                            trailing: IconButton(
                              tooltip: 'Delete entry for $date',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _confirmDeleteEntry(date),
                            ),
                            onTap: () => _openEditor(date),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Text(
                  'Favorite journals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text('Favorites will be added in a future user story.'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading || _loadFailed ? null : _createNew,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

}
