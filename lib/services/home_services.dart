import 'dart:async';
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {

  /// Loads last visited Surah info
static Future<void> loadLastSurah(Function(int, String) onLoaded) async {
  final prefs = await SharedPreferences.getInstance();

  final lastSurahId = prefs.getInt('lastSurahId') ?? 1;
  final lastSurahName = prefs.getString('lastSurahName') ?? "Al-Fatiha";
  final lastSurahArabicName = prefs.getString("lastSurahArabicName") ?? "الفاتحة";

  Globals.surahId = lastSurahId;
  Globals.currentSora = Globals.languageState! ? lastSurahName : lastSurahArabicName;

  onLoaded(Globals.surahId!, Globals.currentSora);
}

}
