
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stress_free/views/homescreen.dart';

import '../models/journal_preferences_store.dart';
import '../models/journal_store.dart';
import '../presenters/journal_search_presenter.dart';
import '../presenters/journal_settings_presenter.dart';
import 'journal_edit_screen.dart';
import 'journal_settings_screen.dart';
import 'stress_statistics_screen.dart';

class JournalScreen extends StatefulWidget {
  /// navigate to this screen from Home.

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
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();
  final JournalSearchPresenter _search = JournalSearchPresenter();
  Map<String, String> get _entries => _search.entries;
  bool _loading = true;
  bool _loadFailed = false;
  bool _searchBusy = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(_renderSearch);
    _store = widget.store ?? JournalStore();
    _preferences = widget.preferences ?? JournalPreferencesStore();

    _settings = JournalSettingsPresenter(
      journals: _store,
      preferences: _preferences,
    );

    _refreshEntries();
  }

  // Load all journal entries.
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

      if (_settings.message != null) {
        _showMessage(_settings.message!);
      }
    } catch (error) {
      debugPrint('Could not load journals: $error');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  void _renderSearch() => setState(() {});

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

  // Display messages.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Delete an existing journal.
  Future<void> _confirmDeleteEntry(String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete journal entry?'),
        content: Text(
          'Are you sure you want to delete the entry for $date?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _store.deleteEntry(date);

      if (mounted) await _refreshEntries();
    } catch (error) {
      if (mounted) {
        _showMessage('Could not delete journal: $error');
      }
    }
  }

  // Open the journal editor.
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


  // SHARED CALENDAR FUNCTIONS
 

  // Convert a date into YYYY-MM-DD format.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // Shared calendar used by Search and New Entry.
  Future<DateTime?> _showJournalCalendar({
    required DateTime initialDate,
    required String title,
  }) {
    final firstDate = DateTime(1900);
    final lastDate = DateTime(2100, 12, 31);

    final validInitialDate = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate.isAfter(lastDate)
            ? lastDate
            : initialDate;

    return showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      helpText: title,
    );
  }

  // Select a date for searching journals.
  Future<void> _pickSearchDate() async {
    final initialDate =
        DateTime.tryParse(_searchController.text.trim()) ??
        DateTime.now();

    final selectedDate = await _showJournalCalendar(
      initialDate: initialDate,
      title: 'Select Journal Date',
    );

    if (!mounted || selectedDate == null) return;

    final year = pickedDate.year.toString().padLeft(4, '0');
    final month = pickedDate.month.toString().padLeft(2, '0');
    final day = pickedDate.day.toString().padLeft(2, '0');
    setState(() => _dateController.text = '$year-$month-$day');
  }

  
  // SEARCH JOURNALS
  

  Future<void> _viewByDate() async {
    if (_loading || _loadFailed || _searchBusy) return;

    if (_searchController.text.trim().isEmpty) return;

    final date = validatedDate(_searchController.text);

    if (date == null) {
      _showMessage('Enter a valid date as YYYY-MM-DD.');
      return;
    }

    // Open journal if it already exists.
    if (_entries.containsKey(date)) {
      await _openEditor(date);
      return;
    }

    // If no journal exists, ask for confirmation.
    setState(() => _searchBusy = true);

    try {
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No journal found'),
          content: Text(
            'No journal exists for $date. '
            'Would you like to create a new journal?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(true),
              child: const Text('Yes, create'),
            ),
          ],
        ),
      );

      // Cancel: do not create anything.
      if (!mounted || shouldCreate != true) return;

      try {
        await _store.saveEntry(date, '');
      } catch (error) {
        if (mounted) {
          _showMessage('Could not create journal: $error');
        }
        return;
      }

      if (!mounted) return;

      setState(() => _entries[date] = '');

      await _openEditor(date);
    } finally {
      if (mounted) {
        setState(() => _searchBusy = false);
      }
    }
  }

  
  // CREATE NEW JOURNAL
  

  Future<void> _createNew() async {
    if (_loading || _loadFailed || _searchBusy) return;

    final today = DateTime.now();
    final todayString = _formatDate(today);

    // If today's journal doesn't exist, open a new one.
    if (!_entries.containsKey(todayString)) {
      await _openEditor(todayString);
      return;
    }

    // If today's journal exists, use the shared calendar.
    final selectedDate = await _showJournalCalendar(
      initialDate: today,
      title: 'Select a date for your new journal',
    );

    if (!mounted || selectedDate == null) return;

    final dateString = _formatDate(selectedDate);

    // Prevent opening an existing entry as a new journal.
    if (_entries.containsKey(dateString)) {
      _showMessage(
        'A journal already exists for this date. '
        'Please select another date.',
      );
      return;
    }

    // Open a new, empty journal editor.
    await _openEditor(dateString);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _keywordController.dispose();
    _search.removeListener(_renderSearch);
    _search.dispose();
    _settings.dispose();
    super.dispose();
  }

  
  // JOURNAL SCREEN UI
 

  @override
  Widget build(BuildContext context) {
    final dates = _entries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 203, 182),
        title: const Text('Reflective Journaling'),
        centerTitle: true,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text(
            'Home',
            style: TextStyle(color: Colors.black),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
            iconColor: Colors.black,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Journal settings',
            icon: const Icon(Icons.settings),
            onPressed: _loading ? null : _openSettings,
          ),
        ],
      ),

   
      // JOURNAL BODY
    

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
                // Search section.
                const Text('Find an entry by date'),
                const SizedBox(height: 8),

                TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _searchBusy ? null : _pickSearchDate,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Entry date',
                    hintText: 'YYYY-MM-DD',
                    suffixIcon: IconButton(
                      tooltip: 'Select date',
                      icon: const Icon(Icons.calendar_month),
                      onPressed:
                          _searchBusy ? null : _pickSearchDate,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _searchBusy ? null : _viewByDate,
                  child: const Text('View'),
                ),

                const SizedBox(height: 24),

                // Recent entries.
                Text(
                  _search.searching ? 'Search results' : 'All entries',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 8),

                if (dates.isEmpty)
                  const Text(
                    'No journal entries yet. Tap + to start writing.',
                  )
                else
                  ...dates.take(10).map(
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
                              : _entries[date]!
                                  .replaceAll('\n', ' '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _settings.font.family,
                          ),
                        ),

                        // Delete icon.
                        trailing: IconButton(
                          tooltip: 'Delete entry for $date',
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              _confirmDeleteEntry(date),
                        ),

                        onTap: () => _openEditor(date),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Favorite journals placeholder.
                Text(
                  'Favorite journals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const Text(
                  'Favorites will be added in a future user story.',
                ),
              ],
            ),

     
      // BOTTOM-RIGHT BUTTONS
    

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // New Entry button.
          FloatingActionButton.extended(
            heroTag: 'journal_new_entry',
            onPressed:
                _loading || _loadFailed ? null : _createNew,
            icon: const Icon(Icons.add),
            label: const Text('New Entry'),
          ),

          const SizedBox(height: 12),

          // Statistics button.
          FloatingActionButton.small(
            heroTag: 'journal_statistics',
            tooltip: 'View stress statistics',
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) =>
                      const StressStatisticsScreen(),
                ),
              );
            },
            child: const Icon(Icons.bar_chart),
          ),
        ],
      ),
    );
  }
}
