import 'dart:io';
import 'package:adhan/adhan.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;
import 'app_logger.dart';
import '../globals.dart';

class PrayerTimeCalculationService {
  static const String _lastTimezoneKey = 'last_timezone';
  static const String _lastLocationKey = 'last_location';
  static const String _calculationMethodKey = 'calculation_method';
  static const platform = MethodChannel('com.youssef.islamic_app.timezone');

  static PrayerTimes? _cachedPrayerTimes;
  static DateTime? _lastCalculationDate;
  static String? _currentTimezone;

  /// Initialize timezone system with dynamic detection
  static Future<void> initializeTimezone() async {
    try {
      AppLogger.log(
          '[PrayerTimeCalculationService] Initializing timezone system...');

      // Initialize timezone data
      tzData.initializeTimeZones();

      // Get device timezone using native method
      String timezone = await _getDeviceTimezone();
      AppLogger.log(
          '[PrayerTimeCalculationService] Device timezone: $timezone');

      // Fallback to UTC if detection fails
      if (timezone.isEmpty) {
        timezone = 'UTC';
        AppLogger.log(
            '[PrayerTimeCalculationService] Timezone detection failed, using UTC fallback');
      }

      // Set local timezone
      tz.setLocalLocation(tz.getLocation(timezone));
      _currentTimezone = timezone;

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastTimezoneKey, timezone);

      AppLogger.log(
          '[PrayerTimeCalculationService] Timezone initialized: $timezone');
    } catch (e) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Timezone initialization failed: $e');
      // Fallback to Africa/Cairo for backward compatibility
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      _currentTimezone = 'Africa/Cairo';
    }
  }

  /// Get device timezone using native method
  static Future<String> _getDeviceTimezone() async {
    try {
      if (Platform.isAndroid) {
        final String timezone = await platform.invokeMethod('getTimezone');
        return timezone;
      } else if (Platform.isIOS) {
        // For iOS, use DateTime.now().timeZoneName
        return DateTime.now().timeZoneName;
      } else {
        return 'UTC';
      }
    } catch (e) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Error getting timezone: $e');
      return 'UTC';
    }
  }

  /// Check if timezone has changed
  static Future<bool> hasTimezoneChanged() async {
    try {
      final currentTz = await _getDeviceTimezone();
      final prefs = await SharedPreferences.getInstance();
      final lastTz = prefs.getString(_lastTimezoneKey);

      return currentTz.isNotEmpty && currentTz != lastTz;
    } catch (e) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Error checking timezone change: $e');
      return false;
    }
  }

  /// Get current timezone
  static String getCurrentTimezone() {
    return _currentTimezone ?? tz.local.name;
  }

  /// Validate GPS coordinates
  static bool _isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        latitude != 0 &&
        longitude != 0; // Exclude (0,0) which is invalid
  }

  /// Get fallback location when GPS fails
  static Future<Position> getFallbackLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to get saved location first
      final savedLat = prefs.getDouble('last_valid_latitude');
      final savedLng = prefs.getDouble('last_valid_longitude');

      if (savedLat != null &&
          savedLng != null &&
          _isValidCoordinates(savedLat, savedLng)) {
        AppLogger.log(
            '[PrayerTimeCalculationService] Using saved valid location: $savedLat, $savedLng');
        return Position(
          latitude: savedLat,
          longitude: savedLng,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }

      // Use Egypt's capital as ultimate fallback
      AppLogger.log(
          '[PrayerTimeCalculationService] Using Cairo as fallback location');
      return Position(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: DateTime.now(),
        accuracy: 1000.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    } catch (e) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Error getting fallback location: $e');
      // Ultimate fallback to Cairo
      return Position(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: DateTime.now(),
        accuracy: 1000.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }
  }

  /// Save valid location to preferences
  static Future<void> _saveValidLocation(
      double latitude, double longitude) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_valid_latitude', latitude);
      await prefs.setDouble('last_valid_longitude', longitude);
      AppLogger.log(
          '[PrayerTimeCalculationService] Saved valid location: $latitude, $longitude');
    } catch (e) {
      AppLogger.log('[PrayerTimeCalculationService] Error saving location: $e');
    }
  }

  /// Get current location
  static Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.log(
            '[PrayerTimeCalculationService] Location services disabled, using fallback');
        return await getFallbackLocation();
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        AppLogger.log(
            '[PrayerTimeCalculationService] Location permission denied, using fallback');
        return await getFallbackLocation();
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Validate coordinates
      if (!_isValidCoordinates(position.latitude, position.longitude)) {
        AppLogger.log(
            '[PrayerTimeCalculationService] Invalid coordinates detected: ${position.latitude}, ${position.longitude}');
        return await getFallbackLocation();
      }

      // Save valid location for future use
      await _saveValidLocation(position.latitude, position.longitude);

      AppLogger.log(
          '[PrayerTimeCalculationService] Valid location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Error getting location: $e, using fallback');
      return await getFallbackLocation();
    }
  }

  /// Get calculation method based on user preference or location
  static CalculationMethod getCalculationMethod() {
    // Default to Egyptian method, can be extended based on user preferences
    return CalculationMethod.egyptian;
  }

  /// Calculate prayer times for today
  static Future<PrayerTimes?> calculateTodayPrayerTimes(
      {Position? position}) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final today = DateTime(now.year, now.month, now.day);

      // Check if we have cached results for today
      if (_cachedPrayerTimes != null &&
          _lastCalculationDate != null &&
          _isSameDay(_lastCalculationDate!, today)) {
        AppLogger.log(
            '[PrayerTimeCalculationService] Using cached prayer times');
        return _cachedPrayerTimes;
      }

      // Get location if not provided
      position ??= await getCurrentLocation();

      // Calculate prayer times
      final coords = Coordinates(position.latitude, position.longitude);
      final method = getCalculationMethod().getParameters()
        ..madhab = Madhab.shafi;

      final prayerTimes =
          PrayerTimes(coords, DateComponents.from(today), method);

      // Cache results
      _cachedPrayerTimes = prayerTimes;
      _lastCalculationDate = today;

      AppLogger.log(
          '[PrayerTimeCalculationService] Prayer times calculated for today');
      return prayerTimes;
    } catch (e) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Error calculating prayer times: $e');
      return null;
    }
  }

  /// Get all prayer times for today as a map
  static Future<Map<String, tz.TZDateTime>?> getTodayPrayerTimesMap(
      {Position? position}) async {
    final prayerTimes = await calculateTodayPrayerTimes(position: position);
    if (prayerTimes == null) return null;

    final now = tz.TZDateTime.now(tz.local);

    return {
      'Fajr': tz.TZDateTime.from(prayerTimes.fajr, tz.local),
      'Dhuhr': tz.TZDateTime.from(prayerTimes.dhuhr, tz.local),
      'Asr': tz.TZDateTime.from(prayerTimes.asr, tz.local),
      'Maghrib': tz.TZDateTime.from(prayerTimes.maghrib, tz.local),
      'Isha': tz.TZDateTime.from(prayerTimes.isha, tz.local),
    };
  }

  /// Get the next upcoming prayer
  static Future<MapEntry<String, tz.TZDateTime>?> getNextPrayer(
      {Position? position}) async {
    final prayerTimes = await getTodayPrayerTimesMap(position: position);
    if (prayerTimes == null) return null;

    final now = tz.TZDateTime.now(tz.local);
    MapEntry<String, tz.TZDateTime>? nextPrayer;

    // Check each prayer time
    for (final entry in prayerTimes.entries) {
      if (entry.value.isAfter(now)) {
        if (nextPrayer == null || entry.value.isBefore(nextPrayer.value)) {
          nextPrayer = entry;
        }
      }
    }

    // If no prayer left today, get tomorrow's Fajr
    if (nextPrayer == null) {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPrayerTimes =
          await calculateTomorrowPrayerTimes(position: position);
      if (tomorrowPrayerTimes != null) {
        final fajr = tz.TZDateTime.from(tomorrowPrayerTimes.fajr, tz.local);
        nextPrayer = MapEntry('Fajr', fajr);
      }
    }

    if (nextPrayer != null) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Next prayer: ${nextPrayer.key} at ${nextPrayer.value}');
    }

    return nextPrayer;
  }

  /// Calculate prayer times for tomorrow
  static Future<PrayerTimes?> calculateTomorrowPrayerTimes(
      {Position? position}) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      position ??= await getCurrentLocation();

      final coords = Coordinates(position.latitude, position.longitude);
      final method = getCalculationMethod().getParameters()
        ..madhab = Madhab.shafi;

      return PrayerTimes(coords, DateComponents.from(tomorrow), method);
    } catch (e) {
      AppLogger.log(
          '[PrayerTimeCalculationService] Error calculating tomorrow prayer times: $e');
      return null;
    }
  }

  /// Clear cached prayer times
  static void clearCache() {
    _cachedPrayerTimes = null;
    _lastCalculationDate = null;
    AppLogger.log('[PrayerTimeCalculationService] Cache cleared');
  }

  /// Check if two dates are the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get prayer name in Arabic/English based on app language
  static String getPrayerName(String prayerKey) {
    final isEnglish = Globals.languageState ?? true;

    final prayerNames = {
      'Fajr': isEnglish ? 'Fajr' : 'الفجر',
      'Dhuhr': isEnglish ? 'Dhuhr' : 'الظهر',
      'Asr': isEnglish ? 'Asr' : 'العصر',
      'Maghrib': isEnglish ? 'Maghrib' : 'المغرب',
      'Isha': isEnglish ? 'Isha' : 'العشاء',
    };

    return prayerNames[prayerKey] ?? prayerKey;
  }
}
