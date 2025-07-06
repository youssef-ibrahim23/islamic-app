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

  static Future<void> initializeApp() async {
    Globals.languageState = false;

    await handleFirstRunAndPermissions();
    await _handleExactAlarmPermission();
    await _setupTimezoneOnce();
    await NotificationService().init();
    await scheduleAllAzans();
    await scheduleDailyAzkarReminders();
    await scheduleMonthlyAzanUpdate();
  }

  static Future<void> handleFirstRunAndPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;

    if (isFirstRun) {
      // Clear all saved preferences
      await prefs.clear();

      // Set 'first_run' to false AFTER clearing
      await prefs.setBool('first_run', false);

      try {
        // Delete temp cache directory
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
    await [
      Permission.locationWhenInUse,
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();
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

    Position? position;
    String timezoneName = 'Africa/Cairo'; // Fallback

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.requestPermission();
      }

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('⚠️ Failed to get location: $e');
    }

    if (position != null) {
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final countryCode = placemarks.first.isoCountryCode;
          const tzMap = {
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

          if (countryCode != null && tzMap.containsKey(countryCode)) {
            timezoneName = tzMap[countryCode]!;
          }
        }
      } catch (e) {
        print('❌ Geocoding error: $e');
      }
    }

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(timezoneName));
      print('⏰ Timezone set: $timezoneName');
    } catch (e) {
      print('❌ Failed to initialize timezone: $e');
    }
  }

  static Future<void> scheduleAllAzans() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final now = DateTime.now();
      final monthKey = "${now.year}-${now.month}"; // e.g., "2025-7"

      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble("lat");
      final savedLon = prefs.getDouble("lon");
      final savedMonth = prefs.getString("lastScheduledMonth");

      // Skip if already scheduled for this month and same location
      if (savedLat == position.latitude &&
          savedLon == position.longitude &&
          savedMonth == monthKey) {
        print('🕋 Azans already scheduled for this month.');
        return;
      }

      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;

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
          if (entry.value.isAfter(DateTime.now())) {
            await NotificationService()
                .schedulePrayerNotification(entry.key, entry.value);
          }
        }
      }

      await prefs.setDouble("lat", position.latitude);
      await prefs.setDouble("lon", position.longitude);
      await prefs.setString("lastScheduledMonth", monthKey);

      print('✅ All azans scheduled for this month.');
    } catch (e) {
      print('❌ Error scheduling monthly azans: $e');
    }
  }

  static Future<void> scheduleDailyAzkarReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScheduled = prefs.getBool('azkar_scheduled') ?? false;

    if (lastScheduled) {
      print('🔄 Azkar reminders already scheduled');
      return;
    }

    try {
      // Schedule morning azkar at sunrise (adjust time as needed)
      await NotificationService().scheduleAzkarReminder(
        id: NotificationService.morningAzkarId,
        time: const TimeOfDay(hour: 6, minute: 0),
        isMorning: true,
      );

      // Schedule evening azkar at sunset (adjust time as needed)
      await NotificationService().scheduleAzkarReminder(
        id: NotificationService.eveningAzkarId,
        time: const TimeOfDay(hour: 18, minute: 0),
        isMorning: false,
      );

      await prefs.setBool('azkar_scheduled', true);
      print('✅ Morning and evening azkar reminders scheduled');
    } catch (e) {
      print('❌ Error scheduling azkar reminders: $e');
    }
  }

  static Future<void> scheduleMonthlyAzanUpdate() async {
    final now = tz.TZDateTime.now(tz.local);
    final nextMonth = now.month == 12 ? 1 : now.month + 1;
    final nextYear = now.month == 12 ? now.year + 1 : now.year;

    final prefs = await SharedPreferences.getInstance();
    final lastScheduled = prefs.getString("lastMonthlyAzanUpdate");

    final nextKey = "$nextYear-$nextMonth";
    if (lastScheduled == nextKey) {
      print('🔄 Monthly azan update already scheduled for $nextKey.');
      return;
    }

    final nextRun = tz.TZDateTime(
      tz.local,
      nextYear,
      nextMonth,
      1,
      4, // 4:00 AM
    );

    await NotificationService().scheduleBackgroundTask(nextRun);
    await prefs.setString("lastMonthlyAzanUpdate", nextKey);

    print('📅 Monthly azan update scheduled for: $nextRun');
  }

  static Future<void> rescheduleAllNotifications() async {
    try {
      // Cancel all existing notifications
      await NotificationService().cancelAllPrayerNotifications();
      await NotificationService().cancelAzkarReminders();

      // Clear scheduling flags
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastScheduledMonth');
      await prefs.remove('azkar_scheduled');
      await prefs.remove('lastMonthlyAzanUpdate');

      // Reschedule everything
      await scheduleAllAzans();
      await scheduleDailyAzkarReminders();
      await scheduleMonthlyAzanUpdate();

      print('🔄 All notifications rescheduled successfully');
    } catch (e) {
      print('❌ Error rescheduling notifications: $e');
    }
  }
}