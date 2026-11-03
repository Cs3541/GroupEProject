import 'package:flutter/material.dart';

import '../models/journal_preferences_store.dart';
import '../models/journal_store.dart';
import '../presenters/journal_settings_presenter.dart';

class JournalSettingsScreen extends StatefulWidget {
  const JournalSettingsScreen({
    super.key,
    this.presenter,
    this.journals,
    this.preferences,
  });

  final JournalSettingsPresenter? presenter;
  final JournalStore? journals;
  final JournalPreferencesStore? preferences;

  @override
  State<JournalSettingsScreen> createState() => _JournalSettingsScreenState();
}

class _JournalSettingsScreenState extends State<JournalSettingsScreen> {
  late final JournalSettingsPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter =
        widget.presenter ??
        JournalSettingsPresenter(
          journals: widget.journals,
          preferences: widget.preferences,
        );
    _presenter.loadFont();
    _presenter.addListener(_render);
  }

  void _render() => setState(() {});

  Future<bool> _confirmDeletion() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear All Journals?'),
            content: const Text(
              'Are you sure you want to delete all journal entries? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _presenter.removeListener(_render);
    if (widget.presenter == null) _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: !_presenter.working,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Journal Settings'),
          automaticallyImplyLeading: !_presenter.working,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Journal Settings', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 30),
            const Text('Change Font'),
            DropdownButton<JournalFont>(
              value: _presenter.font,
              isExpanded: true,
              items: _presenter.fonts.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font.label,
                    style: TextStyle(fontFamily: font.family),
                  ),
                );
              }).toList(),
              onChanged: _presenter.busy
                  ? null
                  : (font) {
                      if (font != null) _presenter.selectFont(font);
                    },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _presenter.busy
                  ? null
                  : () => _presenter.clearAll(confirm: _confirmDeletion),
              child: const Text('Clear All Journals'),
            ),
            if (_presenter.working) const LinearProgressIndicator(),
            if (_presenter.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_presenter.message!),
              ),
          ],
        ),
      ),
    );
  }
}
