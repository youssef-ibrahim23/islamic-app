// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'dart:core';
import 'package:adhan/adhan.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/models/hadith.dart';
import 'package:islamic_app/models/surah.dart';
import 'package:islamic_app/models/verse.dart';

class Globals {
  /// ----------------------------
  /// Compass & Qibla Directions
  /// ----------------------------
  static double? compassHeading = 0;
  static double? qiblaDirection = 0;

  /// ----------------------------
  /// Location Permission
  /// ----------------------------
  static bool hasPermissions = false;

  /// ----------------------------
  /// Routing & Navigation
  /// ----------------------------
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// ----------------------------
  /// Calendar Month Translations
  /// ----------------------------
  static final Map<String, String> hijriArabicMonths = {
    "Sha'aban": "شعبان",
  };

  static final Map<String, String> gregorianArabicMonths = {
    "February": "فبراير",
  };

  /// ----------------------------
  /// User Info & Preferences
  /// ----------------------------
  static String? accountName;
  static String currentSora = "Al-Fatiha";
  static int surahId = 1;
  static bool? languageState = false;

  /// ----------------------------
  /// Surah & Search Management
  /// ----------------------------
  static List<Chapter> chapters = [];
  static List<Chapter>? filteredChapters;
  static Map<int, String> favoriteSurahIds = {};
  static bool surahsListIsLoading = false;
  static bool hasError = false;

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

  static String get fontFamily => languageState! ? 'Roboto' : 'Tajawal';

  static TextDirection get textDirection => languageState! ? TextDirection.ltr : TextDirection.rtl;

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
  static String collectionName = Globals.languageState! ? "Ahadiths" : "الأحاديث";
  static bool hadithIsLoading = true;
  static DateTime focusedDay = DateTime.now();
  static DateTime? selectedDay = DateTime.now();
  static final List<String> languages = ['English', 'العربية'];
  static String selectedLanguage = Globals.languageState! ? 'English' : 'العربية';
  static String get arabicFontFamily => 'Scheherazade New';
  static double fontSize = 24.0;

  static List<Verse>? verses;
  static List<Verse>? filteredVerses;
  static String? allVersesText;
  static int? lastClickedVerse;

  static String errorMessage = '';
  static PlayerState playerState = PlayerState.stopped;
  static double playbackSpeed = 1.0;
  static Duration duration = Duration.zero;
  static Duration position = Duration.zero;
  static bool isPlaying = false;
  static bool showAudioControls = false;
  static bool isDownloaded = false;
  static bool isDownloading = false;
  static bool isPlayButtonLoading = false;
  static double downloadProgress = 0.0;
  static String? localAudioPath;
  static double lastScrollPosition = 0.0;
  static int? selectedVerse;
  static bool isSearching = false;
  static String searchQuery = '';
  static bool verseIsLoading = true;
  static String downloadStatus = '';

  static String? userCountry;
  static String? userGovernorate;


}
