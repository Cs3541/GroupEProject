import 'package:shared_preferences/shared_preferences.dart';

/// Storage boundary fake; exercises the production stores and presenters.
class MemoryPreferences implements SharedPreferencesAsync {
  final values = <String, String>{};
  final readDelays = <String, Future<void>>{};
  final writeDelays = <String, Future<void>>{};
  final removalDelays = <String, Future<void>>{};
  final _failures = <String, bool>{};
  final _removed = <String>[];

  bool get failReads => _failures['read'] ?? false;
  set failReads(bool value) => _failures['read'] = value;
  bool get failWrites => _failures['write'] ?? false;
  set failWrites(bool value) => _failures['write'] = value;
  bool get failRemoval => _failures['remove'] ?? false;
  set failRemoval(bool value) => _failures['remove'] = value;
  int get removals => _removed.length;

  @override
  Future<String?> getString(String key) async {
    await readDelays[key];
    if (failReads) throw StateError('read failed');
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    await writeDelays[key];
    if (failWrites) throw StateError('write failed');
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    await removalDelays[key];
    if (failRemoval) throw StateError('delete failed');
    _removed.add(key);
    values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
