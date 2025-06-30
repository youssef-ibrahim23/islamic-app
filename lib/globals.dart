// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'dart:core';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/models/hadith.dart';
import 'package:islamic_app/models/surah.dart';

class Globals {
  /// ----------------------------
  /// Routing & Navigation
  /// ----------------------------
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// ----------------------------
  /// User Info & Preferences
  /// ----------------------------
  static String currentSora = languageState! ? "Al-Fatiha" : "الفاتحة";
  static int? surahId;
  static bool? languageState;

  /// ----------------------------
  /// Azkar & Counters
  /// ----------------------------
  static Map<String, List<Azkar>> azkarCategories = {};
  static Map<String, Map<int, int>> currentCounts = {};
  static Map<String, Map<int, int>> completionCounts = {};

  /// ----------------------------
  /// Prayer Time & Location
  /// ----------------------------
  static String nextPrayer = '';
  static String nextPrayerTime = '';
  static String timeRemaining = '';
  static bool locationSelected = false;
  static String? currentLocation;
  static Coordinates coordinates = Coordinates(30.0444, 31.2357);
  static Map<String, String>? prayerTimes;
  static Timer? timer;
  static String? nextArabicPrayer;
  static bool prayerTimesIsLoading = true;

  /// ----------------------------
  /// Country & Governorate
  /// ----------------------------
  static String? selectedCountry;
  static String? selectedGovernorate;
  static bool showGovernorates = false;

  /// ----------------------------
  /// Utility Functions
  /// ----------------------------
  /// Converts English numerals to Arabic-Indic numerals
  static String toArabicNumber(String input) {
    const englishToArabicDigits = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return input.split('').map((e) => englishToArabicDigits[e] ?? e).join();
  }

  static String referenceUrl = "https://sunnah.com/bukhari";
  static List<Hadith> hadiths = [];
  static int currentRangeStart = 1;
  static int currentRangeEnd = 30;
  static final int rangeSize = 30;
  static String collectionName =
      Globals.languageState! ? "Ahadiths" : "الأحاديث";
  static bool hadithIsLoading = true;

  static final List<String> languages = ['English', 'العربية'];

  static String selectedLanguage =
      Globals.languageState! ? 'English' : 'العربية';

  static bool isSearching = false;
}
