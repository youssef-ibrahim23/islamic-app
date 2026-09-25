import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/models/verse.dart';

class QuranServices {
  /// Loads verses from local JSON and filters them by the given surahId
  static Future<QuranVerses> loadLocalVerses(int surahId) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/Surah.JSON');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final List<dynamic> rawVerses = jsonMap['verses'];
      final List<Verse> allVerses =
          rawVerses.map((verseJson) => Verse.fromJson(verseJson)).toList();

      final List<Verse> filteredVerses = allVerses.where((verse) {
        try {
          final parts = verse.verseKey.split(':');
          if (parts.length != 2) return false;
          final int verseSurahId = int.parse(parts[0]);
          return verseSurahId == surahId;
        } catch (_) {
          return false;
        }
      }).toList();

      return QuranVerses(verses: filteredVerses);
    } catch (e, stackTrace) {
      print("❌ Error loading Quran verses for surah ID $surahId: $e");
      print("📍 StackTrace: $stackTrace");
      throw QuranVerseLoadException(
          "Failed to load verses for Surah $surahId.");
    }
  }
}

/// Custom exception for Quran verse loading issues
class QuranVerseLoadException implements Exception {
  final String message;
  const QuranVerseLoadException(this.message);

  @override
  String toString() => "QuranVerseLoadException: $message";
}
