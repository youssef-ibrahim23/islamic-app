import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/models/Azkar.dart';

class AzkarService {

  static late SharedPreferences _prefs;

  // Initialize SharedPreferences
  static Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Load Azkar data from local JSON asset
  static Future<Map<String, List<Azkar>>> loadAzkarData() async {
    return Azkar.loadLocalAzkar();
  }

  // Save completion count for a specific zikr
  static Future<void> saveCompletionCount(int index, int count) async {
    await _prefs.setInt('azkar_completion_$index', count);
  }

  // Load saved completion count
  static int loadCompletionCount(int index) {
    return _prefs.getInt('azkar_completion_$index') ?? 0;
  }
}
