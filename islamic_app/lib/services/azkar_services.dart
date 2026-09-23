// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/models/Azkar.dart';

class AzkarService {
  static late SharedPreferences _prefs;

  static Future<Map<String, List<Azkar>>> loadLocalAzkar() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/Azkar.JSON');
      final Map<String, dynamic> data = json.decode(response);

      Map<String, List<Azkar>> azkarCategories = {};

      data.forEach((key, value) {
        if (value is List) {
          List<Azkar> azkarList = value
              .whereType<Map<String, dynamic>>()
              .map((item) => Azkar.fromJson(item))
              .toList();

          azkarCategories[key] = azkarList;
        }
      });

      return azkarCategories;
    } catch (e) {
      return {};
    }
  }

  // Initialize SharedPreferences
  static Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Load Azkar data from local JSON asset
  static Future<Map<String, List<Azkar>>> loadAzkarData() async {
    return loadLocalAzkar();
  }

  // Get today's date string for daily reset
  static String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // Check if it's a new day
  static bool _isNewDay() {
    final lastResetDate = _prefs.getString('azkar_last_reset_date');
    final todayKey = _getTodayKey();
    return lastResetDate != todayKey;
  }

  // Reset daily completion counts if it's a new day
  static Future<void> _checkAndResetDaily() async {
    if (_isNewDay()) {
      // Clear all daily keys for new day
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('azkar_completion_')) {
          await _prefs.remove(key);
        }
        if (key.startsWith('azkar_current_')) {
          await _prefs.remove(key);
        }
        if (key.startsWith('azkar_card_locked_')) {
          await _prefs.remove(key);
        }
        if (key.startsWith('azkar_completion_dialog_shown_')) {
          await _prefs.remove(key);
        }
      }
      // Update last reset date
      await _prefs.setString('azkar_last_reset_date', _getTodayKey());
      print('🔄 Azkar data reset for new day: ${_getTodayKey()}');
    }
  }

  // Save completion count for a specific zikr (daily)
  static Future<void> saveCompletionCount(
      String category, int index, int count) async {
    await _checkAndResetDaily();
    final todayKey = _getTodayKey();
    await _prefs.setInt(
        'azkar_completion_${category}_${index}_$todayKey', count);
  }

  // Load completion count for a specific zikr (daily)
  static int loadCompletionCount(String category, int index) {
    final todayKey = _getTodayKey();
    return _prefs.getInt('azkar_completion_${category}_${index}_$todayKey') ??
        0;
  }

  // Save current remaining count for a specific zikr (daily)
  static Future<void> saveCurrentCount(
      String category, int index, int current) async {
    await _checkAndResetDaily();
    final todayKey = _getTodayKey();
    await _prefs.setInt(
        'azkar_current_${category}_${index}_$todayKey', current);
  }

  // Load current remaining count for a specific zikr (daily)
  static int loadCurrentCount(String category, int index, int defaultCount) {
    final todayKey = _getTodayKey();
    return _prefs.getInt('azkar_current_${category}_${index}_$todayKey') ??
        defaultCount;
  }

  static String _cardLockedKey(String category, int index) {
    final todayKey = _getTodayKey();
    return 'azkar_card_locked_${category}_${index}_$todayKey';
  }

  static bool isCardLocked(String category, int index) {
    return _prefs.getBool(_cardLockedKey(category, index)) ?? false;
  }

  static Future<void> setCardLocked(
      String category, int index, bool locked) async {
    await _checkAndResetDaily();
    await _prefs.setBool(_cardLockedKey(category, index), locked);
  }

  static String _completionDialogShownKey(String category) {
    final todayKey = _getTodayKey();
    return 'azkar_completion_dialog_shown_${category}_$todayKey';
  }

  static bool isCompletionDialogShown(String category) {
    return _prefs.getBool(_completionDialogShownKey(category)) ?? false;
  }

  static Future<void> markCompletionDialogShown(String category) async {
    await _prefs.setBool(_completionDialogShownKey(category), true);
  }

  // Check if new day reset occurred and mark welcome dialog shown
  static String _newDayWelcomeKey() {
    final todayKey = _getTodayKey();
    return 'azkar_new_day_welcome_$todayKey';
  }

  static bool shouldShowNewDayWelcome() {
    return _prefs.getBool(_newDayWelcomeKey()) ?? true;
  }

  static Future<void> markNewDayWelcomeShown() async {
    await _prefs.setBool(_newDayWelcomeKey(), false);
  }

  // Force check and reset daily data (call on app start)
  static Future<bool> forceCheckAndResetDaily() async {
    final wasNewDay = _isNewDay();
    if (wasNewDay) {
      await _checkAndResetDaily();
    }
    return wasNewDay;
  }
}
