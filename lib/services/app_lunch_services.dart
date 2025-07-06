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
import 'package:islamic_app/models/Azkar.dart';
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
    Globals.languageState = false;

    await _handleFirstRunAndPermissions();
    await _handleExactAlarmPermission();
    await NotificationService().init();
    await _setupTimezoneOnce();

    // Defer long-running operations
    Future.microtask(() async {
      await _trySetupLocationAndSchedule();
    });
  }

  static Future<void> _handleFirstRunAndPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;

    if (isFirstRun) {
      await prefs.clear();
      await prefs.setBool('first_run', false);

      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
          debugPrint("✅ Temp directory cleared on first run.");
        }
      } catch (e) {
        debugPrint("❌ Temp directory cleanup failed: $e");
      }
    }

    await _requestEssentialPermissions();
  }

  static Future<void> _requestEssentialPermissions() async {
    final statuses = await [
      Permission.locationWhenInUse,
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();

    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        debugPrint('⚠️ Permission not granted: $permission');
      }
    });
  }

  static Future<void> _handleExactAlarmPermission() async {
    final exactAllowed = await ExactAlarmPermission.isExactAlarmAllowed();
    if (!exactAllowed) {
      await ExactAlarmPermission.requestExactAlarmPermission();
    }
  }

  static Future<void> _setupTimezoneOnce() async {
    if (_timezoneInitialized) return;
    _timezoneInitialized = true;

    String timezoneName = 'Africa/Cairo'; // default
    final prefs = await SharedPreferences.getInstance();

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied");
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      await prefs.setDouble("lat", position.latitude);
      await prefs.setDouble("lng", position.longitude);

      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final countryCode = placemarks.first.isoCountryCode;
      if (countryCode != null && _tzMap.containsKey(countryCode)) {
        timezoneName = _tzMap[countryCode]!;
      }
    } catch (e) {
      debugPrint("⚠️ Failed to fetch location, using saved or default: $e");
      final lat = prefs.getDouble("lat");
      final lng = prefs.getDouble("lng");
      if (lat != null && lng != null) {
        debugPrint('✅ Using saved location: ($lat, $lng)');
      }
    }

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      debugPrint('⏰ Timezone set to: $timezoneName');
    } catch (e) {
      debugPrint('❌ Failed to set timezone: $e');
    }
  }

  static Future<void> _trySetupLocationAndSchedule() async {
    try {
      await _setupTimezoneOnce();
      await scheduleAllAzans();
      await scheduleDailyAzkarReminders();
      await scheduleMonthlyAzanUpdate();
    } catch (e) {
      debugPrint('❌ Failed deferred setup: $e');
    }
  }

  static Future<void> scheduleAllAzans() async {
    try {
      final now = DateTime.now();
      final monthKey = "${now.year}-${now.month}";
      final position = await Geolocator.getCurrentPosition();
      final prefs = await SharedPreferences.getInstance();

      final savedLat = prefs.getDouble("lat");
      final savedLon = prefs.getDouble("lon");
      final savedMonth = prefs.getString("lastScheduledMonth");

      if (savedLat == position.latitude &&
          savedLon == position.longitude &&
          savedMonth == monthKey) {
        debugPrint('🕋 Azans already scheduled for this month.');
        return;
      }

      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.egyptian.getParameters()
        ..madhab = Madhab.shafi;

      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(now.year, now.month, day);
        final prayerTimes = PrayerTimes(
          coordinates,
          DateComponents.from(date),
          params,
        );

        final prayers = {
          "الفجر": prayerTimes.fajr,
          "الظهر": prayerTimes.dhuhr,
          "العصر": prayerTimes.asr,
          "المغرب": prayerTimes.maghrib,
          "العشاء": prayerTimes.isha,
        };

        for (final entry in prayers.entries) {
          final prayerTime = entry.value;
          final diff = prayerTime.difference(DateTime.now()).inMinutes;
          if (diff > 1) {
            await NotificationService()
                .schedulePrayerNotification(entry.key, prayerTime);
          }
        }
      }

      prefs
        ..setDouble("lat", position.latitude)
        ..setDouble("lon", position.longitude)
        ..setString("lastScheduledMonth", monthKey);

      debugPrint('✅ Azans scheduled for $monthKey');
    } catch (e) {
      debugPrint('❌ Error scheduling azans: $e');
    }
  }

  static Future<void> scheduleDailyAzkarReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyScheduled = prefs.getBool('azkar_scheduled') ?? false;

    if (alreadyScheduled) return;

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

      await prefs.setBool('azkar_scheduled', true);
      debugPrint('✅ Azkar reminders scheduled');
    } catch (e) {
      debugPrint('❌ Failed to schedule azkar: $e');
    }
  }

  static Future<void> scheduleMonthlyAzanUpdate() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      final nextKey = "$nextYear-$nextMonth";
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString("lastMonthlyAzanUpdate") == nextKey) return;

      final nextRun = tz.TZDateTime(tz.local, nextYear, nextMonth, 1, 4);
      await NotificationService().scheduleBackgroundTask(nextRun);
      await prefs.setString("lastMonthlyAzanUpdate", nextKey);

      debugPrint('📅 Monthly azan update scheduled: $nextRun');
    } catch (e) {
      debugPrint('❌ Monthly azan update failed: $e');
    }
  }

  static Future<void> rescheduleAllNotifications() async {
    try {
      await NotificationService().cancelAllPrayerNotifications();
      await NotificationService().cancelAzkarReminders();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastScheduledMonth');
      await prefs.remove('azkar_scheduled');
      await prefs.remove('lastMonthlyAzanUpdate');

      await scheduleAllAzans();
      await scheduleDailyAzkarReminders();
      await scheduleMonthlyAzanUpdate();

      debugPrint('🔁 Rescheduled all notifications');
    } catch (e) {
      debugPrint('❌ Rescheduling failed: $e');
    }
  }
}
