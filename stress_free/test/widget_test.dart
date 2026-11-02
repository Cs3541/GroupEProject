import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/main.dart';
import 'package:stress_free/models/alarm_model.dart';
import 'package:stress_free/models/journal_preferences_store.dart';
import 'package:stress_free/models/journal_store.dart';
import 'package:stress_free/presenters/alarm_presenter.dart';
import 'package:stress_free/views/journal_screen.dart';
import 'package:stress_free/views/main_affirmation_screen.dart';
import 'package:stress_free/views/main_alarm_screen.dart';

import 'support/memory_preferences.dart';

Future<void> chooseAlarmTime(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, '8:00 AM'));
  await tester.pumpAndSettle();
  final dialog = find.byType(TimePickerDialog);
  final localizations = MaterialLocalizations.of(tester.element(dialog));
  await tester.tap(find.byTooltip(localizations.inputTimeModeButtonLabel));
  await tester.pumpAndSettle();
  final fields = find.descendant(of: dialog, matching: find.byType(TextField));
  await tester.enterText(fields.first, '9');
  await tester.enterText(fields.last, '30');
  await tester.tap(find.text(localizations.okButtonLabel));
  await tester.pumpAndSettle();
  expect(find.widgetWithText(ElevatedButton, '9:30 AM'), findsOneWidget);
}

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
  testWidgets('app starts with existing home and bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(const StressFreeApp());
    expect(find.text('Welcome to the Stress Free app!'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets(
    'gear opens settings; cancel preserves entries; delete refreshes list',
    (tester) async {
      final memory = MemoryPreferences();
      final store = JournalStore(preferences: memory);
      await store.saveEntry('2026-10-28', 'My journal content');
      await openJournals(tester, memory);
      expect(find.text('My journal content'), findsOneWidget);
      await tester.tap(find.byTooltip('Journal settings'));
      await tester.pumpAndSettle();
      expect(find.text('Change Font'), findsOneWidget);
      await tester.tap(find.text('Clear All Journals'));
      await tester.pumpAndSettle();
      expect(memory.removals, 0);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await store.loadAll(), isNotEmpty);
      await tester.tap(find.text('Clear All Journals'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('All journal entries deleted.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('My journal content'), findsNothing);
      expect(
        find.text('No journal entries yet. Tap + to start writing.'),
        findsOneWidget,
      );
      expect(await store.loadAll(), isEmpty);
    },
  );

  testWidgets('failed deletion shows useful feedback and keeps entries', (
    tester,
  ) async {
    final memory = MemoryPreferences();
    await JournalStore(preferences: memory)
        .saveEntry('2026-10-28', 'Keep this');
    memory.failRemoval = true;
    await openJournals(tester, memory);
    await tester.tap(find.byTooltip('Journal settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear All Journals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not delete journals. Please try again.'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Keep this'), findsOneWidget);
  });

  testWidgets(
    'font selection persists and styles previews and editor without losing content',
    (tester) async {
      final memory = MemoryPreferences();
      final store = JournalStore(preferences: memory);
      await store.saveEntry('2026-10-28', 'Original content');
      await openJournals(tester, memory);
      await tester.tap(find.byTooltip('Journal settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<JournalFont>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Serif').last);
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Original content')).style?.fontFamily,
        JournalFont.serif.family,
      );
      await tester.tap(find.text('2026-10-28'));
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields.last.style?.fontFamily, JournalFont.serif.family);
      expect(fields.last.controller?.text, 'Original content');
      await tester.tap(find.byTooltip('Save and go back'));
      await tester.pumpAndSettle();
      expect(await store.loadAll(), {'2026-10-28': 'Original content'});
      expect(
        await JournalPreferencesStore(preferences: memory).loadFont(),
        JournalFont.serif,
      );
      // Recreate the screen to verify the preference is loaded on a fresh visit.
      await tester.pumpWidget(const SizedBox());
      await openJournals(tester, memory);
      expect(
        tester.widget<Text>(find.text('Original content')).style?.fontFamily,
        JournalFont.serif.family,
      );
    },
  );

  testWidgets('date lookup and new entry retain existing journal workflow', (
    tester,
  ) async {
    final memory = MemoryPreferences();
    await openJournals(tester, memory);
    await tester.enterText(find.byType(TextField), '2026-02-30');
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid date as YYYY-MM-DD.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '2026-10-27');
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'A new reflection');
    await tester.tap(find.byTooltip('Save and go back'));
    await tester.pumpAndSettle();
    expect(await JournalStore(preferences: memory).loadAll(), {
      '2026-10-27': 'A new reflection',
    });
    expect(find.text('A new reflection'), findsOneWidget);
  });

  testWidgets(
    'affirmations show categories, settings and favorites without navigation',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainAffirmationScreen()));
      for (final label in ['Life', 'Gym', 'Work']) {
        expect(find.widgetWithText(ElevatedButton, label), findsOneWidget);
        await tester.tap(find.text(label));
      }
      await tester.tap(find.byTooltip('Favorite affirmations'));
      await tester.tap(find.byTooltip('Affirmation settings'));
      await tester.pumpAndSettle();
      expect(find.text('Affirmations'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'alarm drafts cancel; invalid Save changes nothing; valid Save updates all settings',
    (tester) async {
      final presenter = AlarmPresenter(
        alarm: Alarm(
          alarmOn: false,
          alarmTime: const TimeOfDay(hour: 8, minute: 0),
          notificationsOn: false,
          alarmName: 'Original alarm',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: MainAlarmScreen(presenter: presenter)),
      );
      expect(find.text('Original alarm'), findsOneWidget);
      expect(find.text('Alarm Off'), findsOneWidget);
      await tester.tap(find.byTooltip('Alarm settings'));
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsNWidgets(2));
      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).initialValue,
        'Original alarm',
      );
      await tester.enterText(find.byType(TextFormField), 'Unsaved name');
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();
      await chooseAlarmTime(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Original alarm'), findsOneWidget);
      expect(find.text('Alarm Off'), findsOneWidget);
      expect(presenter.alarmName, 'Original alarm');
      expect(presenter.alarmOn, false);
      expect(presenter.alarmTime, const TimeOfDay(hour: 8, minute: 0));
      expect(presenter.notificationsOn, false);
      await tester.tap(find.byTooltip('Alarm settings'));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch).first).value, false);
      expect(tester.widget<Switch>(find.byType(Switch).last).value, false);
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();
      await chooseAlarmTime(tester);
      await tester.enterText(find.byType(TextFormField), '  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter an alarm name.'), findsOneWidget);
      expect(find.text('Alarm Settings'), findsOneWidget);
      expect(presenter.alarmName, 'Original alarm');
      expect(presenter.alarmOn, false);
      expect(presenter.alarmTime, const TimeOfDay(hour: 8, minute: 0));
      expect(presenter.notificationsOn, false);
      expect(tester.widget<Switch>(find.byType(Switch).first).value, true);
      expect(tester.widget<Switch>(find.byType(Switch).last).value, true);
      expect(find.widgetWithText(ElevatedButton, '9:30 AM'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '  Morning class  ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Morning class'), findsOneWidget);
      expect(find.text('9:30 AM'), findsOneWidget);
      expect(find.text('Alarm Off'), findsNothing);
      expect(find.text('Stop Alarm'), findsOneWidget);
      expect(presenter.alarmName, 'Morning class');
      expect(presenter.alarmOn, true);
      expect(presenter.alarmTime, const TimeOfDay(hour: 9, minute: 30));
      expect(presenter.notificationsOn, true);
      expect(presenter.error, isNull);
      await tester.tap(find.byTooltip('Alarm settings'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextFormField>(find.byType(TextFormField)).initialValue,
        'Morning class',
      );
      expect(tester.widget<Switch>(find.byType(Switch).first).value, true);
      expect(tester.widget<Switch>(find.byType(Switch).last).value, true);
      expect(find.widgetWithText(ElevatedButton, '9:30 AM'), findsOneWidget);
    },
  );

  testWidgets(
    'Save displays the alarm name while disabled and keeps Alarm Off',
    (tester) async {
      final presenter = AlarmPresenter();
      await tester.pumpWidget(
        MaterialApp(home: MainAlarmScreen(presenter: presenter)),
      );
      expect(find.text('My Alarm'), findsOneWidget);
      expect(find.text('Alarm Off'), findsOneWidget);
      await tester.tap(find.byTooltip('Alarm settings'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField),
        '  Evening reminder  ',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Evening reminder'), findsOneWidget);
      expect(find.text('Alarm Off'), findsOneWidget);
      expect(find.text('Stop Alarm'), findsOneWidget);
      expect(find.text('8:00 AM'), findsNothing);
      expect(presenter.alarmOn, false);
      expect(presenter.notificationsOn, false);
      expect(presenter.alarmTime, const TimeOfDay(hour: 8, minute: 0));
      expect(presenter.alarmName, 'Evening reminder');
    },
  );
}
