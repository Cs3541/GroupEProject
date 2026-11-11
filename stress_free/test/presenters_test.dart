import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/models/alarm_model.dart';
import 'package:stress_free/models/journal_preferences_store.dart';
import 'package:stress_free/models/journal_store.dart';
import 'package:stress_free/presenters/alarm_presenter.dart';
import 'package:stress_free/presenters/journal_settings_presenter.dart';

import 'support/memory_preferences.dart';

void main() {
  late MemoryPreferences memory;
  late JournalStore journals;
  late JournalPreferencesStore preferences;
  late JournalSettingsPresenter presenter;

  setUp(() {
    memory = MemoryPreferences();
    journals = JournalStore(preferences: memory);
    preferences = JournalPreferencesStore(preferences: memory);
    presenter = JournalSettingsPresenter(
      journals: journals,
      preferences: preferences,
    );
  });

  tearDown(() => presenter.dispose());

  test('canceling deletion preserves entries', () async {
    await journals.saveEntry('2026-10-28', 'Keep my thoughts');
    await presenter.clearAll(confirm: () async => false);
    expect(await journals.loadAll(), {'2026-10-28': 'Keep my thoughts'});
    expect(memory.removals, 0);
    expect(presenter.busy, false);
  });

  test(
    'deletion waits for confirmation and ignores duplicate requests',
    () async {
      await journals.saveEntry('2026-10-28', 'Entry');
      final confirmation = Completer<bool>();
      final pending = presenter.clearAll(confirm: () => confirmation.future);
      expect(presenter.busy, true);
      expect(memory.removals, 0);
      await presenter.clearAll(confirm: () => throw StateError('duplicate'));
      confirmation.complete(true);
      await pending;
      expect(await journals.loadAll(), isEmpty);
      expect(memory.removals, 1);
      expect(presenter.message, 'All journal entries deleted.');
      expect(presenter.busy, false);
    },
  );

  test('failed deletion gives feedback and permits retry', () async {
    await journals.saveEntry('2026-10-28', 'Keep this on failure');
    memory.failRemoval = true;
    await presenter.clearAll(confirm: () async => true);
    expect(presenter.message, contains('Could not delete'));
    expect(await journals.loadAll(), isNotEmpty);
    expect(presenter.busy, false);
    memory.failRemoval = false;
    await presenter.clearAll(confirm: () async => true);
    expect(await journals.loadAll(), isEmpty);
  });

  test(
    'font survives a new store and presenter without changing entries',
    () async {
      await journals.saveEntry('2026-10-28', 'Original\ncontent');
      final original = memory.values[JournalStore.storageKey];
      await presenter.selectFont(JournalFont.serif);
      final reloaded = JournalSettingsPresenter(
        journals: journals,
        preferences: JournalPreferencesStore(preferences: memory),
      );
      addTearDown(reloaded.dispose);
      await reloaded.loadFont();
      expect(reloaded.font, JournalFont.serif);
      expect(memory.values[JournalStore.storageKey], original);
      await presenter.clearAll(confirm: () async => true);
      expect(await preferences.loadFont(), JournalFont.serif);
    },
  );

  test('missing and unknown fonts safely use the default', () async {
    expect(await preferences.loadFont(), JournalFont.roboto);
    memory.values[JournalPreferencesStore.fontKey] = 'unsupported';
    expect(await preferences.loadFont(), JournalFont.roboto);
  });

  test(
    'failed font save retains previous selection and can be retried',
    () async {
      memory.failWrites = true;
      await presenter.selectFont(JournalFont.serif);
      expect(presenter.font, JournalFont.roboto);
      expect(presenter.message, contains('Could not save'));
      expect(presenter.busy, false);
      memory.failWrites = false;
      await presenter.selectFont(JournalFont.serif);
      expect(presenter.font, JournalFont.serif);
    },
  );

  test('failed font load gives feedback and permits retry', () async {
    memory.failReads = true;
    await presenter.loadFont();
    expect(presenter.message, contains('Could not load'));
    expect(presenter.busy, false);
    memory.failReads = false;
    await presenter.loadFont();
    expect(presenter.message, isNull);
  });

  test(
    'leaving settings while confirmation is open prevents deletion',
    () async {
      final local = JournalSettingsPresenter(
        journals: journals,
        preferences: preferences,
      );
      final confirmation = Completer<bool>();
      final pending = local.clearAll(confirm: () => confirmation.future);
      local.dispose();
      confirmation.complete(true);
      await pending;
      expect(memory.removals, 0);
    },
  );

  test('alarm presenter preserves the team default settings', () {
    final alarm = AlarmPresenter();
    expect(alarm.alarmOn, false);
    expect(alarm.alarmTime, const TimeOfDay(hour: 8, minute: 0));
    expect(alarm.notificationsOn, false);
    expect(alarm.alarmName, 'My Alarm');
    expect(alarm.error, isNull);
  });

  test(
    'invalid names preserve every setting; valid Save trims and updates',
    () {
      final model = Alarm(
        alarmOn: false,
        alarmTime: const TimeOfDay(hour: 8, minute: 0),
        notificationsOn: false,
        alarmName: 'Original',
      );
      final alarm = AlarmPresenter(alarm: model);
      const newTime = TimeOfDay(hour: 9, minute: 30);
      for (final invalidName in ['', '   ', '\t\n']) {
        expect(alarm.updateAlarm(true, newTime, true, invalidName), false);
        expect(model.alarmOn, false);
        expect(model.alarmTime, const TimeOfDay(hour: 8, minute: 0));
        expect(model.notificationsOn, false);
        expect(model.alarmName, 'Original');
        expect(alarm.error, 'Enter an alarm name.');
      }
      expect(alarm.updateAlarm(true, newTime, true, '  Morning class  '), true);
      expect(model.alarmOn, true);
      expect(model.alarmTime, newTime);
      expect(model.notificationsOn, true);
      expect(model.alarmName, 'Morning class');
      expect(alarm.error, isNull);
      expect(AlarmPresenter(alarm: model).alarmName, 'Morning class');

      expect(
        alarm.updateAlarm(
          false,
          const TimeOfDay(hour: 7, minute: 0),
          false,
          '',
        ),
        false,
      );
      expect(model.alarmOn, true);
      expect(model.alarmTime, newTime);
      expect(model.notificationsOn, true);
      expect(model.alarmName, 'Morning class');
    },
  );
}
