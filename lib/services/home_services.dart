import 'dart:async';
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {

  /// ✅ New Future-based method for use with FutureBuilder
  static Future<Map<String, dynamic>> loadLastSurahAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final int lastSurahId = prefs.getInt('lastSurahId') ?? 1;
      final String lastSurahName = prefs.getString('lastSurahName') ?? 'Al-Fatiha';
      final String lastSurahArabicName = prefs.getString('lastSurahArabicName') ?? 'الفاتحة';

      final bool isEnglish = Globals.languageState ?? true;
      final String name = isEnglish ? lastSurahName : lastSurahArabicName;

      Globals.surahId = lastSurahId;
      Globals.currentSora = name;

      return {
        'id': lastSurahId,
        'name': name,
      };
    } catch (e) {
      print('❌ Error in loadLastSurahAsync: $e');
      return {
        'id': 1,
        'name': 'Al-Fatiha',
      };
    }
  }

}
