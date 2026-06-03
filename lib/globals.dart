// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'dart:core';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/models/hadith.dart';

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
  // Daily verse cached during app launch (populated at splash time)
  static String? dailyAyatAr;
  static String? dailyAyatEn;
  static String? dailyTranslationName;
  static String? dailyVerseKey;
  static int? dailyVerseNumber;

  /// ----------------------------
  /// Azkar & Counters
  /// ----------------------------
  static Map<String, Map<int, int>> currentCounts = {};
  static Map<String, Map<int, int>> completionCounts = {};
  static Map<String, Map<int, bool>> azkarCardLocked = {};

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
  static String? selectedCountry; // For prayer times calculation
  static String? selectedGovernorate; // For prayer times calculation
  static bool showGovernorates = false;

  // Device location for Hijri date (independent of location selection)
  static String? deviceCountry;

  /// ----------------------------
  /// Regional Hijri Date Settings
  /// ----------------------------
  // Hijri date adjustment by country (days to add/subtract from standard calculation)
  static const Map<String, int> hijriDateAdjustments = {
    'Saudi Arabia': 0, // Reference - no adjustment
    'Egypt': -1, // Egypt typically observes one day earlier
    'UAE': 0, // UAE follows Saudi sighting
    'Kuwait': 0, // Kuwait follows Saudi sighting
    'Qatar': 0, // Qatar follows Saudi sighting
    'Bahrain': 0, // Bahrain follows Saudi sighting
    'Oman': -1, // Oman sometimes observes one day earlier
    'Jordan': -1, // Jordan often follows Egypt
    'Lebanon': -1, // Lebanon often follows Egypt
    'Syria': -1, // Syria often follows Egypt
    'Iraq': -1, // Iraq often follows Egypt
    'Yemen': 0, // Yemen follows Saudi sighting
    'Sudan': -1, // Sudan often follows Egypt
    'Libya': -1, // Libya often follows Egypt
    'Tunisia': -1, // Tunisia often follows Egypt
    'Algeria': -1, // Algeria often follows Egypt
    'Morocco': -1, // Morocco often follows Egypt
    'Mauritania': -1, // Mauritania often follows Egypt
    'Palestine': -1, // Palestine often follows Egypt
    'Turkey': -1, // Turkey often follows Egypt
    'Iran': 0, // Iran has its own calculation method
    'Pakistan': -1, // Pakistan often observes one day earlier
    'India': -1, // India often observes one day earlier
    'Bangladesh': -1, // Bangladesh often observes one day earlier
    'Indonesia': -1, // Indonesia often observes one day earlier
    'Malaysia': -1, // Malaysia often observes one day earlier
    'Singapore': -1, // Singapore often follows Malaysia
  };

  // Get Hijri date adjustment for selected country (for prayer times)
  static int get hijriDateAdjustment {
    if (selectedCountry == null) return 0;
    return hijriDateAdjustments[selectedCountry] ?? 0;
  }

  // Get Hijri date adjustment for device location (for Hijri date display)
  static int get deviceHijriDateAdjustment {
    if (deviceCountry == null) return 0;
    return hijriDateAdjustments[deviceCountry] ?? 0;
  }

  // User-adjustable Hijri offset (in addition to regional adjustment)
  // This allows users to fine-tune the date based on local moon sighting
  static int userHijriAdjustment = 0;

  // Get total Hijri adjustment (regional + user)
  static int get totalHijriAdjustment =>
      deviceHijriDateAdjustment + userHijriAdjustment;

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
