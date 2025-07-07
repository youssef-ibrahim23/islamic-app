import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan/adhan.dart';

import 'package:islamic_app/services/exact_alarm_permission.dart';
import 'package:islamic_app/services/notification_services.dart';
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

  /// Initialize all app services on first launch
  static Future<void> initializeApp() async {
    Globals.languageState = false;

    await _handleFirstRun();
    await _requestPermissions();
    await _handleExactAlarmPermission();
    await NotificationService().init();
    await _setupTimezoneOnce();

    Future.microtask(() async {
      await _scheduleStartupTasks();
    });
  }

  /// Handle app first run logic: clear prefs & temp files
  static Future<void> _handleFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;

    if (isFirstRun) {
      await prefs.clear();
      await prefs.setBool('first_run', false);

      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
          debugPrint("✅ Temp files cleared on first run.");
        }
      } catch (e) {
        debugPrint("❌ Failed to clear temp: $e");
      }
    }
  }

  /// Request core app permissions
  static Future<void> _requestPermissions() async {
    final results = await [
      Permission.locationWhenInUse,
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();

    results.forEach((perm, status) {
      if (!status.isGranted) {
        debugPrint("⚠️ Missing permission: $perm");
      }
    });
  }

  /// Check & request exact alarm permission
  static Future<void> _handleExactAlarmPermission() async {
    if (!await ExactAlarmPermission.isExactAlarmAllowed()) {
      await ExactAlarmPermission.requestExactAlarmPermission();
    }
  }

  /// Set up timezone for scheduling notifications
  static Future<void> _setupTimezoneOnce() async {
    if (_timezoneInitialized) return;
    _timezoneInitialized = true;

    String tzName = 'Africa/Cairo'; // default fallback
    final prefs = await SharedPreferences.getInstance();

    try {
      if (await _checkLocationPermission()) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5)
        );

        await prefs.setDouble("lat", position.latitude);
        await prefs.setDouble("lng", position.longitude);

        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        final countryCode = placemarks.first.isoCountryCode;
        if (countryCode != null && _tzMap.containsKey(countryCode)) {
          tzName = _tzMap[countryCode]!;
        }
      }
    } catch (e) {
      debugPrint("⚠️ Timezone fallback due to location error: $e");
    }

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(tzName));
      debugPrint('⏰ Timezone set to: $tzName');
    } catch (e) {
      debugPrint('❌ Timezone initialization failed: $e');
    }
  }

  /// Checks and requests location permission if needed
  static Future<bool> _checkLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Schedule all background jobs
  static Future<void> _scheduleStartupTasks() async {
    try {
      await scheduleAllAzans();
      await scheduleDailyAzkarReminders();
      await scheduleMonthlyAzanUpdate();
    } catch (e) {
      debugPrint("❌ Background setup failed: $e");
    }
  }

  /// Schedule all Azan notifications for the current month
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
        debugPrint("📆 Azans already scheduled for $key");
        return;
      }

      final coords = Coordinates(position.latitude, position.longitude);
      final method = CalculationMethod.egyptian.getParameters()
        ..madhab = Madhab.shafi;

      final days = DateUtils.getDaysInMonth(now.year, now.month);
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
          final prayerTime = entry.value;
          if (prayerTime.difference(DateTime.now()).inMinutes > 1) {
            await NotificationService()
                .schedulePrayerNotification(entry.key, prayerTime);
          }
        }
      }

      prefs
        ..setDouble("lat", position.latitude)
        ..setDouble("lon", position.longitude)
        ..setString("lastScheduledMonth", key);

      debugPrint("✅ Azan schedule complete for $key");
    } catch (e) {
      debugPrint("❌ Failed to schedule azans: $e");
    }
  }

  /// Schedule daily Azkar reminders
  static Future<void> scheduleDailyAzkarReminders() async {
    NotificationService notificationService = NotificationService();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('azkar_scheduled') ?? false) return;

    try {
      await NotificationService().scheduleAzkarReminder(
        id: NotificationService.morningAzkarId,
        time: const TimeOfDay(hour: 6, minute: 0),
        type: AzkarType.morning,
      );
      await NotificationService().scheduleAzkarReminder(
        id: NotificationService.eveningAzkarId,
        time: const TimeOfDay(hour: 18, minute: 0),
        type: AzkarType.evening,
      );
      await NotificationService().scheduleAzkarReminder(
        id: NotificationService.sleepingAzkarId,
        time: const TimeOfDay(hour: 23, minute: 0),
        type: AzkarType.sleeping,
      );

      await notificationService.scheduleDailyQuranReminder(const TimeOfDay(hour: 15, minute: 30));

      await prefs.setBool('azkar_scheduled', true);
      debugPrint('✅ Daily azkar reminders scheduled.');
    } catch (e) {
      debugPrint('❌ Error in azkar scheduling: $e');
    }
  }

  /// Schedule task to reschedule azans for next month
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

      debugPrint("📅 Monthly update scheduled: $runTime");
    } catch (e) {
      debugPrint("❌ Failed monthly azan update: $e");
    }
  }
}
