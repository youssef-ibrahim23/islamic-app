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
    Globals.languageState = true;

    await handleFirstRunAndPermissions();
    await _handleExactAlarmPermission();
    await _setupTimezoneOnce();
    await NotificationService().init();
    await scheduleAllAzans();
    await scheduleDailyAzanUpdate();
  }

  static Future<void> handleFirstRunAndPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;

    if (isFirstRun) {
      await prefs.setBool('first_run', false);

      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        debugPrint("Temp directory cleanup failed: $e");
      }
    }
    await _requestEssentialPermissions();
  }

  static Future<void> _requestEssentialPermissions() async {
    await [
      Permission.locationWhenInUse,
      Permission.notification,
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
      final todayKey = "${now.year}-${now.month}-${now.day}";

      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble("lat");
      final savedLon = prefs.getDouble("lon");
      final savedDate = prefs.getString("lastDate");

      if (savedLat == position.latitude &&
          savedLon == position.longitude &&
          savedDate == todayKey) {
        print('🕋 Azans already scheduled for today.');
        return;
      }

      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes(
        coordinates,
        DateComponents.from(now),
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
        if (entry.value.isAfter(now)) {
          await NotificationService()
              .schedulePrayerNotification(entry.key, entry.value);
        }
      }

      await prefs.setDouble("lat", position.latitude);
      await prefs.setDouble("lon", position.longitude);
      await prefs.setString("lastDate", todayKey);

      print('✅ Azans scheduled.');
    } catch (e) {
      print('❌ Error scheduling azans: $e');
    }
  }

  static Future<void> scheduleDailyAzanUpdate() async {
    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = now.add(const Duration(days: 1));
    final nextRun = tz.TZDateTime(
      tz.local,
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      4,
    );

    await NotificationService().scheduleBackgroundTask(nextRun);
    print('⏰ Daily azan update scheduled.');
  }
}
