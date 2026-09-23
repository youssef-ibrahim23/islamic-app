import 'package:shared_preferences/shared_preferences.dart';

class CounterService {
  static const String _counterKey = 'counter';
  SharedPreferences? _prefs;

  /// Initializes SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Loads the current counter value from SharedPreferences
  Future<int> loadCounter() async {
    await _ensurePrefsReady();
    return _prefs?.getInt(_counterKey) ?? 0;
  }

  /// Saves a new counter value to SharedPreferences
  Future<void> saveCounter(int value) async {
    await _ensurePrefsReady();
    await _prefs?.setInt(_counterKey, value);
  }

  /// Increments the counter by 1 and returns the new value
  Future<int> incrementCounter() async {
    final current = await loadCounter();
    final updated = current + 1;
    await saveCounter(updated);
    return updated;
  }

  /// Resets the counter to 0
  Future<void> resetCounter() async {
    await saveCounter(0);
  }

  /// Ensures SharedPreferences is initialized before use
  Future<void> _ensurePrefsReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
