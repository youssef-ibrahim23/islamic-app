import 'dart:async';
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {
  /// Loads the last visited Surah ID and name from SharedPreferences,
  /// then calls [onLoaded] with the appropriate language version.
  static Future<void> loadLastSurah(Function(int id, String name) onLoaded) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final int lastSurahId = prefs.getInt('lastSurahId') ?? 1;
      final String lastSurahName = prefs.getString('lastSurahName') ?? 'Al-Fatiha';
      final String lastSurahArabicName = prefs.getString('lastSurahArabicName') ?? 'الفاتحة';

      Globals.surahId = lastSurahId;
      final bool isEnglish = Globals.languageState ?? true;
      Globals.currentSora = isEnglish ? lastSurahName : lastSurahArabicName;

      try {
        onLoaded(Globals.surahId!, Globals.currentSora);
      } catch (callbackError) {
        print('Callback execution error in loadLastSurah: $callbackError');
      }
    } catch (e) {
      print('❌ Error loading last Surah from SharedPreferences: $e');
    }
  }
}
