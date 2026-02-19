import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan/adhan.dart';

import 'package:islamic_app/services/notification_services.dart';
import 'package:islamic_app/services/home_services.dart';
import 'package:islamic_app/globals.dart';

class AppLaunchService {
  static bool _timezoneInitialized = false;

  static const Map<String, String> _tzMap = {
    'EG': 'Africa/Cairo',
    'SA': 'Asia/Riyadh',
    'US': 'America/New_York',
    'IN': 'Asia/Kolkata',
    'ID': 'Asia/Jakarta',
    'TR': 'Europe/Istanbul',
    'MA': 'Africa/Casablanca',
    'PK': 'Asia/Karachi',
    'DZ': 'Africa/Algiers',
    'IQ': 'Asia/Baghdad',
  };

  static Future<void> initializeApp() async {
    try {
      Globals.languageState = false;

      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        _handleFirstRun(prefs),
        _setupTimezoneOnce(prefs),
        _loadLanguageState(prefs),
        HomeServices.loadLastSurahAsync(),
      ]);
      await NotificationService().init();
      unawaited(_scheduleStartupTasks());
    } catch (e) {}
  }

  static Future<void> requestPermissions() async {
    final permissions = [
      Permission.locationWhenInUse,
      Permission.notification,
      Permission.scheduleExactAlarm,
    ];

    final statuses = await permissions.request();
    for (final entry in statuses.entries) {
      if (!entry.value.isGranted) {}
    }
  }

  static Future<void> _handleFirstRun(SharedPreferences prefs) async {
    if (prefs.getBool('first_run') ?? true) {
      await prefs.setBool('first_run', false);
      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {}
    }
  }

  static Future<void> _loadLanguageState(SharedPreferences prefs) async {
    Globals.languageState = prefs.getBool("language") ?? false;
  }

  static Future<void> _setupTimezoneOnce(SharedPreferences prefs) async {
    if (_timezoneInitialized) return;
    _timezoneInitialized = true;

    String tzName = 'Africa/Cairo';

    try {
      if (await _checkLocationPermission()) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 30),
        );

        prefs
          ..setDouble("lat", position.latitude)
          ..setDouble("lng", position.longitude);

        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        final countryCode = placemarks.first.isoCountryCode;
        if (countryCode != null && _tzMap.containsKey(countryCode)) {
          tzName = _tzMap[countryCode]!;
        }
      }
    } catch (e) {}

    try {
      tzData.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e) {}
  }

  static Future<bool> _checkLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<void> _scheduleStartupTasks() async {
    try {
      await Future.wait([
        scheduleAllAzans(),
        scheduleDailyAzkarReminders(),
        scheduleMonthlyAzanUpdate(),
      ]);
    } catch (e) {}
  }

  static Future<void> scheduleAllAzans() async {
    try {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final key = "${now.year}-${now.month}";

      final position = await Geolocator.getCurrentPosition();
      final prevLat = prefs.getDouble("lat");
      final prevLon = prefs.getDouble("lon");
      final lastMonth = prefs.getString("lastScheduledMonth");

      if (prevLat == position.latitude &&
          prevLon == position.longitude &&
          lastMonth == key) {
        return;
      }

      final coords = Coordinates(position.latitude, position.longitude);
      final method = CalculationMethod.egyptian.getParameters()
        ..madhab = Madhab.shafi;

      final days = DateUtils.getDaysInMonth(now.year, now.month);
      final notificationService = NotificationService();

      for (int day = 1; day <= days; day++) {
        final date = DateTime(now.year, now.month, day);
        final prayers = PrayerTimes(coords, DateComponents.from(date), method);

        final times = {
          "الفجر": prayers.fajr,
          "الظهر": prayers.dhuhr,
          "العصر": prayers.asr,
          "المغرب": prayers.maghrib,
          "العشاء": prayers.isha,
        };

        for (final entry in times.entries) {
          if (entry.value.isAfter(now)) {
            await notificationService.schedulePrayerNotification(
              entry.key,
              entry.value,
            );
          }
        }
      }

      prefs
        ..setDouble("lat", position.latitude)
        ..setDouble("lon", position.longitude)
        ..setString("lastScheduledMonth", key);
    } catch (e) {}
  }

  static Future<void> scheduleDailyAzkarReminders() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('azkar_scheduled') ?? false) return;

    try {
      final notificationService = NotificationService();

      await Future.wait([
        notificationService.scheduleAzkarReminder(
          id: NotificationService.morningAzkarId,
          time: const TimeOfDay(hour: 6, minute: 0),
          type: AzkarType.morning,
        ),
        notificationService.scheduleAzkarReminder(
          id: NotificationService.eveningAzkarId,
          time: const TimeOfDay(hour: 18, minute: 0),
          type: AzkarType.evening,
        ),
        notificationService.scheduleAzkarReminder(
          id: NotificationService.sleepingAzkarId,
          time: const TimeOfDay(hour: 23, minute: 0),
          type: AzkarType.sleeping,
        ),
        notificationService.scheduleDailyQuranReminder(
          const TimeOfDay(hour: 15, minute: 30),
        ),
      ]);

      await prefs.setBool('azkar_scheduled', true);
    } catch (e) {}
  }

  static Future<void> scheduleMonthlyAzanUpdate() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      final nextKey = "$nextYear-$nextMonth";

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString("lastMonthlyAzanUpdate") == nextKey) return;

      final runTime = tz.TZDateTime(tz.local, nextYear, nextMonth, 1, 4);
      await NotificationService().scheduleBackgroundTask(runTime);
      await prefs.setString("lastMonthlyAzanUpdate", nextKey);
    } catch (e) {}
  }
}
