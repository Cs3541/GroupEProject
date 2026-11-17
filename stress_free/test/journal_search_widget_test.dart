import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/models/journal_preferences_store.dart';
import 'package:stress_free/models/journal_store.dart';
import 'package:stress_free/views/journal_screen.dart';

import 'support/memory_preferences.dart';

final searchField = find.widgetWithText(TextField, 'Search journal content');

Future<void> openJournals(WidgetTester tester, MemoryPreferences memory) async {
  // Keep the date controls, search and first results visible together.
  tester.view.physicalSize = const Size(1000, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: JournalScreen(
        store: JournalStore(preferences: memory),
        preferences: JournalPreferencesStore(preferences: memory),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> search(WidgetTester tester, String query) async {
  await tester.enterText(searchField, query);
  await tester.pumpAndSettle();
}

void main() {
  late MemoryPreferences memory;
  late JournalStore store;

  setUp(() async {
    memory = MemoryPreferences();
    store = JournalStore(preferences: memory);
    await store.saveEntry('2026-11-01', 'A CALM walk after work.');
    await store.saveEntry('2026-11-02', 'Feeling calm and rested.');
    await store.saveEntry('2026-11-03', 'A busy morning.');
  });

  testWidgets('typing filters saved content case-insensitively', (
    tester,
  ) async {
    final saved = memory.values[JournalStore.storageKey];
    await openJournals(tester, memory);
    await search(tester, '  CaLm  ');
    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('A CALM walk after work.'), findsOneWidget);
    expect(find.text('Feeling calm and rested.'), findsOneWidget);
    expect(find.text('A busy morning.'), findsNothing);
    expect(memory.values[JournalStore.storageKey], saved);
  });

  testWidgets('clear button and erasing the query restore all entries', (
    tester,
  ) async {
    await openJournals(tester, memory);
    await search(tester, 'calm');
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(searchField).controller!.text, isEmpty);
    expect(find.text('All entries'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
    await search(tester, 'busy');
    expect(find.byType(ListTile), findsOneWidget);
    await search(tester, '');
    expect(find.byType(ListTile), findsNWidgets(3));
    await search(tester, '   ');
    expect(find.byType(ListTile), findsNWidgets(3));
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  testWidgets('no matches gives feedback and clearing restores the list', (
    tester,
  ) async {
    await openJournals(tester, memory);
    await search(tester, '2026-11');
    expect(find.text('No journal entries match your search.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('No journal entries match your search.'), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(3));
  });

  testWidgets('opens the selected result, edits, saves and reapplies search', (
    tester,
  ) async {
    await openJournals(tester, memory);
    await search(tester, 'calm');
    await tester.tap(find.text('2026-11-01'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    expect(
      tester.widget<TextField>(fields.first).controller!.text,
      '2026-11-01',
    );
    expect(
      tester.widget<TextField>(fields.last).controller!.text,
      'A CALM walk after work.',
    );
    expect(find.text('Stress Level: 5 / 10'), findsOneWidget);
    tester.widget<Slider>(find.byType(Slider)).onChanged!(8);
    await tester.pump();
    expect(find.text('Stress Level: 8 / 10'), findsOneWidget);
    await tester.enterText(fields.last, 'An energetic walk.');
    await tester.tap(find.byTooltip('Save and go back'));
    await tester.pumpAndSettle();
    expect((await store.loadAll())['2026-11-01'], 'An energetic walk.');
    expect(tester.widget<TextField>(searchField).controller!.text, 'calm');
    expect(find.text('2026-11-01'), findsNothing);
    expect(find.text('Feeling calm and rested.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('An energetic walk.'), findsOneWidget);
  });

  testWidgets(
    'deleting a result refreshes search and preserves other entries',
    (tester) async {
      await openJournals(tester, memory);
      await search(tester, 'busy');
      await tester.tap(find.byTooltip('Delete entry for 2026-11-03'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await store.loadAll(), hasLength(3));
      await tester.tap(find.byTooltip('Delete entry for 2026-11-03'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        find.text('No journal entries match your search.'),
        findsOneWidget,
      );
      expect(await store.loadAll(), hasLength(2));
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNWidgets(2));
    },
  );

  testWidgets('settings changes preserve the query and result font', (
    tester,
  ) async {
    await openJournals(tester, memory);
    await search(tester, 'busy');
    await tester.tap(find.byTooltip('Journal settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<JournalFont>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serif').last);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(searchField).controller!.text, 'busy');
    expect(find.byType(ListTile), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('A busy morning.')).style!.fontFamily,
      JournalFont.serif.family,
    );
    expect(await store.loadAll(), hasLength(3));
  });

  testWidgets('empty saved journal list supports searching and clearing', (
    tester,
  ) async {
    await store.clearAll();
    await openJournals(tester, memory);
    expect(
      find.text('No journal entries yet. Tap + to start writing.'),
      findsOneWidget,
    );
    await search(tester, 'calm');
    expect(find.text('No journal entries match your search.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(
      find.text('No journal entries yet. Tap + to start writing.'),
      findsOneWidget,
    );
    expect(await store.loadAll(), isEmpty);
  });

  testWidgets('date lookup can open a saved entry excluded by the keyword', (
    tester,
  ) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await store.saveEntry(today, 'Today was energetic.');
    await openJournals(tester, memory);
    await search(tester, 'calm');
    await tester.tap(find.byTooltip('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).last).controller!.text,
      'Today was energetic.',
    );
    await tester.tap(find.byTooltip('Save and go back'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(searchField).controller!.text, 'calm');
    expect(find.text('Today was energetic.'), findsNothing);
  });

  testWidgets('date creation still confirms before saving during a search', (
    tester,
  ) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await openJournals(tester, memory);
    await search(tester, 'new reflection');
    await tester.tap(find.byTooltip('Select date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.text('No journal found'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((await store.loadAll()).containsKey(today), isFalse);
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes, create'));
    await tester.pumpAndSettle();
    expect((await store.loadAll())[today], '');
    await tester.enterText(find.byType(TextField).last, 'My new reflection.');
    await tester.tap(find.byTooltip('Save and go back'));
    await tester.pumpAndSettle();
    expect(find.text('My new reflection.'), findsOneWidget);
    expect(
      tester.widget<TextField>(searchField).controller!.text,
      'new reflection',
    );
  });

  testWidgets('New Entry still creates and saves while searching', (
    tester,
  ) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await openJournals(tester, memory);
    await search(tester, 'new reflection');
    await tester.tap(find.text('New Entry'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      today,
    );
    await tester.enterText(find.byType(TextField).last, 'A new reflection.');
    await tester.tap(find.byTooltip('Save and go back'));
    await tester.pumpAndSettle();
    expect((await store.loadAll())[today], 'A new reflection.');
    expect(find.text('A new reflection.'), findsOneWidget);
  });
}
