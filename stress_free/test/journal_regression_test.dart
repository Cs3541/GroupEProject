import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/models/journal_preferences_store.dart';
import 'package:stress_free/models/journal_store.dart';
import 'package:stress_free/views/journal_screen.dart';

import 'support/memory_preferences.dart';

Future<void> openJournals(WidgetTester tester, MemoryPreferences memory) async {
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

void main() {
  testWidgets(
    'failed load blocks editing until retry verifies existing entries',
    (tester) async {
      final memory = MemoryPreferences();
      final store = JournalStore(preferences: memory);
      final date = DateTime.now().toIso8601String().substring(0, 10);
      await store.saveEntry(date, 'Existing reflection');
      final original = memory.values[JournalStore.storageKey];
      memory.failReads = true;

      await openJournals(tester, memory);
      expect(
        find.text('Could not load journals. Please try again.'),
        findsOneWidget,
      );
      expect(
        find.text('No journal entries yet. Tap + to start writing.'),
        findsNothing,
      );
      expect(find.byType(TextField), findsNothing);
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .onPressed,
        isNull,
      );

      // A recovered backend alone must not make the unverified cache editable.
      memory.failReads = false;
      await tester.tap(find.text('New Entry'));
      await tester.pumpAndSettle();
      expect(find.text('Journal Entry'), findsNothing);
      expect(memory.values[JournalStore.storageKey], original);

      final load = Completer<void>();
      memory.readDelays[JournalStore.storageKey] = load.future;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('New Entry'));
      await tester.pump();
      expect(find.text('Journal Entry'), findsNothing);
      expect(memory.values[JournalStore.storageKey], original);

      load.complete();
      await tester.pumpAndSettle();
      expect(find.text('Existing reflection'), findsOneWidget);
      await tester.tap(find.text('New Entry'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).controller?.text,
        'Existing reflection',
      );
      await tester.tap(find.byTooltip('Save and go back'));
      await tester.pumpAndSettle();
      expect(memory.values[JournalStore.storageKey], original);
      expect(await store.loadAll(), {date: 'Existing reflection'});
    },
  );

  for (final fails in [false, true]) {
    testWidgets(
      'delayed deletion blocks Back and reports ${fails ? 'failure' : 'success'}',
      (tester) async {
        final memory = MemoryPreferences();
        final store = JournalStore(preferences: memory);
        await store.saveEntry('2026-10-28', 'Keep until deletion finishes');
        await openJournals(tester, memory);
        await tester.tap(find.byTooltip('Journal settings'));
        await tester.pumpAndSettle();

        final deletion = Completer<void>();
        memory.removalDelays[JournalStore.storageKey] = deletion.future;
        memory.failRemoval = fails;
        await tester.tap(find.text('Clear All Journals'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Change Font'), findsOneWidget);
        expect(memory.removals, 0);

        deletion.complete();
        await tester.pumpAndSettle();
        expect(
          find.text(
            fails
                ? 'Could not delete journals. Please try again.'
                : 'All journal entries deleted.',
          ),
          findsOneWidget,
        );
        expect(find.byType(BackButton), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        if (fails) {
          expect(find.text('Keep until deletion finishes'), findsOneWidget);
          expect(await store.loadAll(), isNotEmpty);
        } else {
          expect(find.text('Keep until deletion finishes'), findsNothing);
          expect(
            find.text('No journal entries yet. Tap + to start writing.'),
            findsOneWidget,
          );
          expect(await store.loadAll(), isEmpty);
        }
      },
    );

    testWidgets(
      'delayed font save blocks Back and reports ${fails ? 'failure' : 'success'}',
      (tester) async {
        final memory = MemoryPreferences();
        final store = JournalStore(preferences: memory);
        await store.saveEntry('2026-10-28', 'Font preview');
        final original = memory.values[JournalStore.storageKey];
        await openJournals(tester, memory);
        await tester.tap(find.byTooltip('Journal settings'));
        await tester.pumpAndSettle();

        final saving = Completer<void>();
        memory.writeDelays[JournalPreferencesStore.fontKey] = saving.future;
        memory.failWrites = fails;
        await tester.tap(find.byType(DropdownButton<JournalFont>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Serif').last);
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.byType(BackButton), findsNothing);
        await tester.binding.handlePopRoute();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Change Font'), findsOneWidget);
        expect(memory.values[JournalPreferencesStore.fontKey], isNull);

        saving.complete();
        await tester.pumpAndSettle();
        expect(
          find.text(
            fails
                ? 'Could not save the font. Your previous font is still selected.'
                : 'Journal font saved.',
          ),
          findsOneWidget,
        );
        expect(find.byType(BackButton), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        final expectedFont = fails ? JournalFont.roboto : JournalFont.serif;
        expect(
          tester.widget<Text>(find.text('Font preview')).style?.fontFamily,
          expectedFont.family,
        );
        expect(
          await JournalPreferencesStore(preferences: memory).loadFont(),
          expectedFont,
        );
        expect(memory.values[JournalStore.storageKey], original);
      },
    );
  }
}
