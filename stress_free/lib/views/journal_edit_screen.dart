import 'package:flutter/material.dart';
import '../models/journal_store.dart'; 

String? validatedDate(String value) {
  final dateText = value.trim();
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateText);
  if (match == null) return null;

  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (year < 1) return null;

  final parsed = DateTime(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }
  return dateText;
}
class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({
    super.key,
    required this.store,
    required this.initialDate,
    required this.initialText,
  });

  final JournalStore store;
  final String initialDate;
  final String initialText;

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late final TextEditingController _dateController;
  late final TextEditingController _entryController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.initialDate);
    _entryController = TextEditingController(text: widget.initialText);
  }

  Future<void> _saveAndGoBack() async {
    if (_saving) return;

    final date = validatedDate(_dateController.text);
    if (date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid date as YYYY-MM-DD.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.store.saveEntry(date, _entryController.text);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save entry: $error')),
      );
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      // Also intercept the Android system Back button to save the entry.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndGoBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Save and go back',
            icon: const Icon(Icons.arrow_back),
            onPressed: _saving ? null : _saveAndGoBack,
          ),
          title: const Text('Journal Entry'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Date (YYYY-MM-DD)',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _entryController,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Write your thoughts here...',
                  ),
                ),
              ),
              if (_saving) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
