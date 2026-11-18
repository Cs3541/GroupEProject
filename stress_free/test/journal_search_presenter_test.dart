import 'package:flutter_test/flutter_test.dart';
import 'package:stress_free/presenters/journal_search_presenter.dart';

void main() {
  late JournalSearchPresenter presenter;

  setUp(() {
    presenter = JournalSearchPresenter();
    presenter.updateEntries({
      '2026-11-01': 'A CALM walk after work.',
      '2026-11-03': 'Work felt stressful today.',
      '2026-11-02': 'Feeling calm\nand rested.',
      '2026-11-04': '',
    });
  });

  tearDown(() => presenter.dispose());

  test('searches saved content case-insensitively in newest-first order', () {
    presenter.search('  CaLm  ');
    expect(presenter.searching, isTrue);
    expect(presenter.visibleDates, ['2026-11-02', '2026-11-01']);
    presenter.search('after WORK');
    expect(presenter.visibleDates, ['2026-11-01']);
  });

  test('matches literal text, not date keys or regular expressions', () {
    for (final query in ['2026-11', 'unmatched', '.*']) {
      presenter.search(query);
      expect(presenter.visibleDates, isEmpty);
    }
    expect(presenter.entries, hasLength(4));
  });

  test(
    'clearing and whitespace restore every entry including empty content',
    () {
      presenter.search('calm');
      for (final query in ['', ' \t ']) {
        presenter.search(query);
        expect(presenter.searching, isFalse);
        expect(presenter.visibleDates, [
          '2026-11-04',
          '2026-11-03',
          '2026-11-02',
          '2026-11-01',
        ]);
      }
    },
  );

  test('search includes entries older than the ten most recent', () {
    presenter.updateEntries({
      for (var day = 1; day <= 12; day++)
        '2026-11-${day.toString().padLeft(2, '0')}': 'A calm day $day',
    });
    presenter.search('calm');
    expect(presenter.visibleDates, hasLength(12));
    expect(presenter.visibleDates.last, '2026-11-01');
    presenter.search('');
    expect(presenter.visibleDates, hasLength(12));
  });

  test('refresh after edits or deletion reapplies the active query', () {
    presenter.search('calm');
    presenter.updateEntries({
      '2026-11-01': 'Changed to a busy day.',
      '2026-11-05': 'A new calm reflection.',
    });
    expect(presenter.searching, isTrue);
    expect(presenter.visibleDates, ['2026-11-05']);
    presenter.updateEntries({});
    expect(presenter.visibleDates, isEmpty);
  });

  test('entry snapshots cannot be changed by searches or callers', () {
    final saved = {'2026-11-01': 'Original content'};
    presenter.updateEntries(saved);
    saved.clear();
    presenter.search('original');
    expect(presenter.entries, {'2026-11-01': 'Original content'});
    expect(
      () => presenter.entries['2026-11-01'] = 'Changed',
      throwsUnsupportedError,
    );
  });
}
