// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/surah.dart';
import 'package:islamic_app/screens/verses.dart';
import 'package:islamic_app/widgets/surahs/error_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurahsListServices {
  /// Save the last opened Surah info in SharedPreferences
  static Future<void> saveLastSurah(Chapter chapter) async {
    Globals.currentSora = Globals.languageState! ? chapter.nameSimple : chapter.nameArabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSurahId', chapter.id);
    await prefs.setString('lastSurahName', chapter.nameSimple);
    await prefs.setString('lastSurahArabicName', chapter.nameArabic);
  }

  /// Navigate to the Surah detail screen
  static void navigateToSurahDetail(BuildContext context, Chapter chapter) {
    saveLastSurah(chapter);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailPage(
          chapter.nameSimple,
          chapter.id,
          chapter.nameArabic,
        ),
      ),
    );
  }

  /// Add or remove Surah from favorites and store in SharedPreferences
  static Future<void> toggleFavorite(Chapter chapter) async {
    final prefs = await SharedPreferences.getInstance();

    if (Globals.favoriteSurahIds.containsKey(chapter.id)) {
      Globals.favoriteSurahIds.remove(chapter.id);
    } else {
      Globals.favoriteSurahIds[chapter.id] =
          '${chapter.nameSimple} | ${chapter.nameArabic}';
    }

    await prefs.setStringList(
      'favorites',
      Globals.favoriteSurahIds.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .toList(),
    );
  }

  /// Load chapters and handle errors
  static Future<List<Chapter>> loadChaptersWithResult(
      BuildContext context) async {
    try {
      final data = await QuranChapters.loadLocalChapters();
      return data.chapters;
    } catch (e) {
      ErrorSnackBar.show(
        context,
        Globals.languageState! ? "Failed to load Surahs" : "فشل تحميل السور",
      );
      return [];
    }
  }

  /// Load favorite chapters from SharedPreferences
  static Future<Map<int, String>> loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    final loadedFavorites = <int, String>{};
    for (var entry in favorites) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final id = int.tryParse(parts[0]);
        if (id != null) {
          loadedFavorites[id] = parts[1];
        }
      }
    }
    return loadedFavorites;
  }

  /// Filter chapters by query and language
  static List<Chapter> filterChapters({
    required List<Chapter> chapters,
    required String query,
    required bool languageIsEnglish,
  }) {
    return chapters.where((chapter) {
      final name = languageIsEnglish ? chapter.nameSimple : chapter.nameArabic;
      return name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
