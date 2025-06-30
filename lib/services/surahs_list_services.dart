// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:islamic_app/models/surah.dart';

class SurahsListServices {
  /// Load Quran chapters from local JSON asset
  static Future<QuranChapters> loadLocalChapters() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/Quran.JSON');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return QuranChapters.fromJson(jsonMap);
    } catch (e, stackTrace) {
      print("❌ Error loading Quran chapters: $e");
      print("📍 StackTrace: $stackTrace");
      throw const QuranDataException("Failed to load Quran chapters from assets.");
    }
  }

}

/// Custom exception for Quran data loading issues
class QuranDataException implements Exception {
  final String message;
  const QuranDataException(this.message);

  @override
  String toString() => "QuranDataException: $message";
}
