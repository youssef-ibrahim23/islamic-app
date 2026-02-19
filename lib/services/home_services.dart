import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {
  static Map<int, Map<String, String>>? _chapterNameCache;

  static Future<Map<int, Map<String, String>>> _loadChapterNameCache() async {
    if (_chapterNameCache != null) return _chapterNameCache!;

    final jsonString = await rootBundle.loadString('assets/data/Quran.JSON');
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final List<dynamic> chapters = (data['chapters'] as List<dynamic>?) ?? [];

    final map = <int, Map<String, String>>{};
    for (final raw in chapters) {
      if (raw is Map<String, dynamic>) {
        final id = raw['id'];
        if (id is int) {
          map[id] = {
            'en': (raw['name_simple'] ?? '').toString(),
            'ar': (raw['name_arabic'] ?? '').toString(),
          };
        }
      }
    }

    _chapterNameCache = map;
    return map;
  }

  static int? _surahIdFromVerseKey(String verseKey) {
    if (verseKey.isEmpty) return null;
    if (!verseKey.contains(':')) return null;
    final parts = verseKey.split(':');
    if (parts.isEmpty) return null;
    return int.tryParse(parts.first);
  }

  /// ✅ New Future-based method for use with FutureBuilder
  static Future<Map<String, dynamic>> loadLastSurahAsync() async {
    try {
      // Return cached daily ayah if already loaded during splash
      if (Globals.dailyAyatAr != null || Globals.dailyAyatEn != null) {
        return {
          'id': Globals.surahId ?? 1,
          'name': Globals.currentSora,
          'ayatAr': Globals.dailyAyatAr,
          'ayatEn': Globals.dailyAyatEn,
          'translationName': Globals.dailyTranslationName,
          'verseNumber': Globals.dailyVerseNumber,
          'verseKey': Globals.dailyVerseKey,
        };
      }
      final prefs = await SharedPreferences.getInstance();

      final int lastSurahId = prefs.getInt('lastSurahId') ?? 1;
      final String lastSurahName =
          prefs.getString('lastSurahName') ?? 'Al-Fatiha';
      final String lastSurahArabicName =
          prefs.getString('lastSurahArabicName') ?? 'الفاتحة';

      final bool isEnglish = Globals.languageState ?? true;
      final String name = isEnglish ? lastSurahName : lastSurahArabicName;

      Globals.surahId = lastSurahId;
      Globals.currentSora = name;

      // Load verses from the bundled Surah.JSON and pick a deterministic
      // "random" verse for today (changes daily but is repeatable).
      try {
        final jsonString =
            await rootBundle.loadString('assets/data/Surah.JSON');
        final Map<String, dynamic> data = jsonDecode(jsonString);
        final List<dynamic> verses = data['verses'] ?? [];

        if (verses.isNotEmpty) {
          final now = DateTime.now();
          final int dateSeed = now.year * 10000 + now.month * 100 + now.day;
          final int index = dateSeed % verses.length;
          final Map<String, dynamic> selected =
              Map<String, dynamic>.from(verses[index]);

          final String ayatAr =
              (selected['text_uthmani'] ?? '').toString().trim();
          final String verseKey = (selected['verse_key'] ?? '').toString();

          final int? verseSurahId = _surahIdFromVerseKey(verseKey);
          int resolvedSurahId = verseSurahId ?? lastSurahId;
          String resolvedSurahName = name;

          if (verseSurahId != null) {
            final chapterNames = await _loadChapterNameCache();
            final found = chapterNames[verseSurahId];
            if (found != null) {
              final en = found['en'] ?? '';
              final ar = found['ar'] ?? '';
              resolvedSurahName = isEnglish ? en : ar;
              resolvedSurahId = verseSurahId;
            }
          }

          int? verseNumber;
          if (verseKey.contains(':')) {
            final parts = verseKey.split(':');
            if (parts.length == 2) {
              verseNumber = int.tryParse(parts[1]);
            }
          }

          // Cache into Globals so other parts of the app can use it immediately
          Globals.dailyAyatAr = ayatAr;
          Globals.dailyAyatEn = null;
          Globals.dailyTranslationName = null;
          Globals.dailyVerseKey = verseKey;
          Globals.dailyVerseNumber = verseNumber;
          Globals.surahId = resolvedSurahId;
          Globals.currentSora = resolvedSurahName;

          return {
            'id': resolvedSurahId,
            'name': resolvedSurahName,
            'ayatAr': ayatAr,
            'ayatEn': null,
            'translationName': null,
            'verseNumber': verseNumber,
            'verseKey': verseKey,
          };
        }
      } catch (e) {
        print('❌ Error loading Surah.JSON for daily ayah: $e');
      }

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
