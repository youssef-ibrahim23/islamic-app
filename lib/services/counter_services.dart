import 'package:shared_preferences/shared_preferences.dart';

class CounterService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<int> loadCounter() async {
    return _prefs.getInt('counter') ?? 0;
  }

  Future<void> saveCounter(int value) async {
    await _prefs.setInt('counter', value);
  }

  static String toArabicNumber(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicNumerals[digit] : char;
    }).join('');
  }
}
