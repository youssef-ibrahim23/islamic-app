// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/models/hadith.dart';
import 'package:islamic_app/globals.dart';

class HadithService {
  /// Loads hadiths in a specified number range from local assets
  static Future<List<Hadith>> loadHadithsByRange(int start, int end) async {
    try {
      final String response = await rootBundle.loadString('assets/Ahadith.JSON');
      final data = json.decode(response);
      final welcome = Welcome.fromJson(data);

      return welcome.data.hadiths.where((hadith) {
        return hadith.number >= start && hadith.number <= end;
      }).toList();
    } catch (e) {
      print("❌ Error loading hadiths by range: $e");
      return [];
    }
  }

  /// Loads the initial hadith range based on saved prefs
  static Future<void> loadInitialRange(
    Function(bool) setLoading,
    Function() refreshUI,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Globals.currentRangeStart = prefs.getInt("bukhari_range_start") ?? 1;
      Globals.currentRangeEnd = Globals.currentRangeStart + Globals.rangeSize - 1;
    } catch (_) {
      Globals.currentRangeStart = 1;
      Globals.currentRangeEnd = Globals.rangeSize;
    }

    await loadHadiths(
      Globals.currentRangeStart,
      Globals.currentRangeEnd,
      setLoading,
      refreshUI,
    );
  }

  /// Loads hadiths from start to end and updates the global list
  static Future<void> loadHadiths(
    int start,
    int end,
    Function(bool) setLoading,
    Function() refreshUI,
  ) async {
    setLoading(true);
    try {
      final List<Hadith> hadiths = await loadHadithsByRange(start, end);
      Globals.hadiths = hadiths;
    } catch (e) {
      print("❌ Error loading hadiths: $e");
      Globals.hadiths = [];
    } finally {
      setLoading(false);
      refreshUI();
    }
  }

  /// Moves to the next range of hadiths
  static Future<void> loadNextRange(
    Function(bool) setLoading,
    Function() refreshUI,
  ) async {
    final newStart = Globals.currentRangeStart + Globals.rangeSize;
    final newEnd = newStart + Globals.rangeSize - 1;
    await _updateRangeAndLoad(newStart, newEnd, setLoading, refreshUI);
  }

  /// Moves to the previous range of hadiths (if available)
  static Future<void> loadPreviousRange(
    Function(bool) setLoading,
    Function() refreshUI,
  ) async {
    if (Globals.currentRangeStart <= 1) return;

    final newStart = Globals.currentRangeStart - Globals.rangeSize;
    final newEnd = newStart + Globals.rangeSize - 1;
    await _updateRangeAndLoad(newStart, newEnd, setLoading, refreshUI);
  }

  /// Updates the range in prefs and loads hadiths accordingly
  static Future<void> _updateRangeAndLoad(
    int newStart,
    int newEnd,
    Function(bool) setLoading,
    Function() refreshUI,
  ) async {
    Globals.currentRangeStart = newStart;
    Globals.currentRangeEnd = newEnd;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("bukhari_range_start", newStart);
    } catch (e) {
      print("⚠️ Failed to save hadith range: $e");
    }

    await loadHadiths(newStart, newEnd, setLoading, refreshUI);
  }

  /// Converts digits in [input] string to Arabic numerals if not English
  static String convertNumbersToArabic(String input, bool isEnglish) {
    if (isEnglish) return input;

    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    return input.replaceAllMapped(RegExp(r'\d'), (match) {
      final digit = int.parse(match.group(0)!);
      return arabicNumerals[digit];
    });
  }

  /// Shares a Hadith via native share dialog
  static void shareHadith(Hadith hadith, bool isEnglish) {
    final String reference = Globals.referenceUrl.isNotEmpty
        ? '\n\nReference: ${Globals.referenceUrl}'
        : '';

    final hadithNumber = convertNumbersToArabic(hadith.number.toString(), isEnglish);

    final String shareText = isEnglish
        ? '''
Hadith #${hadith.number} - Sahih al-Bukhari

${hadith.arab}

${hadith.id}$reference

Shared via Islamic App
'''
        : '''
حديث رقم $hadithNumber - صحيح البخاري

${hadith.arab}

${hadith.id}$reference

تمت المشاركة عبر تطبيق إسلامي
''';

    Share.share(
      shareText,
      subject: isEnglish ? 'Hadith from Sahih al-Bukhari' : 'حديث من صحيح البخاري',
    );
  }
}
