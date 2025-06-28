import 'package:flutter/services.dart';
import 'dart:convert';

class QuranVerses {
  final List<Verse> verses;

  QuranVerses({required this.verses});

  factory QuranVerses.fromJson(Map<String, dynamic> json) {
    final verses = (json['verses'] as List)
        .map((verseJson) => Verse.fromJson(verseJson))
        .toList();
    return QuranVerses(verses: verses);
  }
}

class Verse {
  final int id;
  final String verseKey;
  final String textUthmani;

  Verse({
    required this.id,
    required this.verseKey,
    required this.textUthmani,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'],
      verseKey: json['verse_key'],
      textUthmani: json['text_uthmani'],
    );
  }
}

class QuranService {
  static Future<QuranVerses> loadLocalVerses(int surahId) async {
    try {
      final String response = await rootBundle.loadString('assets/Surah.JSON');
      final Map<String, dynamic> data = json.decode(response);
      
      // Filter verses by surahId (verse_key format is "surahId:verseNumber")
      final allVerses = (data['verses'] as List)
          .map((verseJson) => Verse.fromJson(verseJson))
          .toList();
      
      final filteredVerses = allVerses.where((verse) {
        final parts = verse.verseKey.split(':');
        return parts.isNotEmpty && int.parse(parts[0]) == surahId;
      }).toList();

      return QuranVerses(verses: filteredVerses);
    } catch (e) {
      print("Error loading local verses: $e");
      throw Exception("Failed to load Quran verses for surah $surahId");
    }
  }
}