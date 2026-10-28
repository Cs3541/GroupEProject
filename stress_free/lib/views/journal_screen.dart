import 'package:flutter/material.dart';
import '../models/journal_store.dart';
import 'journal_edit_screen.dart';

class JournalScreen extends StatefulWidget {
  /// navigate to this screen from Home.
  /// supply a callback to open settings screen.
  const JournalScreen({super.key, this.onOpenSettings});

  final VoidCallback? onOpenSettings;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalStore _store = JournalStore();
  final TextEditingController _searchController = TextEditingController();
  Map<String, String> _entries = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshEntries();
  }

  Future<void> _refreshEntries() async {
    final entries = await _store.loadAll();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openEditor(String date) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => JournalEditorScreen(
          store: _store,
          initialDate: date,
          initialText: _entries[date] ?? '',
        ),
      ),
    );
    if (mounted) await _refreshEntries();
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
            onPressed: () {
              if (widget.onOpenSettings != null) {
                widget.onOpenSettings!();
              } else {
                _showMessage('Navigate to Journal settings page');
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Find an entry by date'),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Entry date',
                    hintText: 'YYYY-MM-DD',
                  ),
                  onSubmitted: (_) => _viewByDate(),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _viewByDate,
                  child: const Text('View'),
                ),
                const SizedBox(height: 24),
                Text('Recent entries',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (dates.isEmpty)
                  const Text('No journal entries yet. Tap + to start writing.')
                else
                  ...dates.take(10).map(
                    (date) => Card(
                      child: ListTile(
                        title: Text(date),
                        subtitle: Text(
                          _entries[date]!.trim().isEmpty
                              ? '(Empty entry)'
                              : _entries[date]!.replaceAll('\n', ' '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openEditor(date),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Favorite journals',
                    style: Theme.of(context).textTheme.titleLarge),
                const Text('Favorites will be added in a future user story.'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNew,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }
}

