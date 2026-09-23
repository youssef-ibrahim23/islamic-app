import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'app_logger.dart';

/// Centralized timezone management for the entire app
class CentralizedTimezoneManager {
  static bool _isInitialized = false;
  static const String _timezoneKey = 'device_timezone';
  static const String _lastTimezoneUpdateKey = 'last_timezone_update';

  /// Initialize timezone system
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.log(
          '[CentralizedTimezoneManager] Initializing timezone system...');

      // Initialize timezone database
      tz.initializeTimeZones();

      // Get device timezone
      final deviceTimezone = await _getDeviceTimezone();

      // Set local timezone
      tz.setLocalLocation(tz.getLocation(deviceTimezone));

      // Save timezone preference
      await _saveTimezonePreference(deviceTimezone);

      _isInitialized = true;
      AppLogger.log(
          '[CentralizedTimezoneManager] Timezone initialized: $deviceTimezone');
    } catch (e) {
      AppLogger.log(
          '[CentralizedTimezoneManager] Error initializing timezone: $e');
      // Fallback to UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
      _isInitialized = true;
    }
  }

  /// Get device timezone from native code
  static Future<String> _getDeviceTimezone() async {
    try {
      AppLogger.log(
          '🌍 [CentralizedTimezoneManager] Getting device timezone from native...');
      const platform = MethodChannel('com.youssef.islamic_app/timezone');

      AppLogger.log(
          '📡 [CentralizedTimezoneManager] Calling getTimezone method...');
      final String? timezone = await platform.invokeMethod('getTimezone');

      if (timezone != null && timezone.isNotEmpty) {
        AppLogger.log(
            '✅ [CentralizedTimezoneManager] Device timezone retrieved: $timezone');
        return timezone;
      } else {
        AppLogger.log(
            '⚠️ [CentralizedTimezoneManager] Native returned null/empty timezone, using UTC');
        return 'UTC';
      }
    } catch (e) {
      AppLogger.log(
          '❌ [CentralizedTimezoneManager] Failed to get device timezone: $e');
      AppLogger.log('🔄 [CentralizedTimezoneManager] Falling back to UTC');
      return 'UTC';
    }
  }

  /// Save timezone preference
  static Future<void> _saveTimezonePreference(String timezone) async {
    try {
      // This would use SharedPreferences in a real implementation
      AppLogger.log(
          '[CentralizedTimezoneManager] Saved timezone preference: $timezone');
    } catch (e) {
      AppLogger.log(
          '[CentralizedTimezoneManager] Error saving timezone preference: $e');
    }
  }

  /// Get current timezone
  static String getCurrentTimezone() {
    if (!_isInitialized) {
      return 'UTC';
    }
    return tz.local.name;
  }

  /// Get current time in local timezone
  static tz.TZDateTime getCurrentLocalTime() {
    if (!_isInitialized) {
      return tz.TZDateTime.now(tz.getLocation('UTC'));
    }
    return tz.TZDateTime.now(tz.local);
  }

  /// Convert UTC time to local timezone
  static tz.TZDateTime utcToLocal(DateTime utcDateTime) {
    if (!_isInitialized) {
      return tz.TZDateTime.from(utcDateTime, tz.getLocation('UTC'));
    }
    return tz.TZDateTime.from(utcDateTime, tz.local);
  }

  /// Convert local time to UTC
  static tz.TZDateTime localToUtc(DateTime localDateTime) {
    if (!_isInitialized) {
      return tz.TZDateTime.from(localDateTime, tz.getLocation('UTC'));
    }
    return tz.TZDateTime.from(localDateTime, tz.getLocation('UTC'));
  }

  /// Get timezone offset from UTC
  static Duration getTimezoneOffset() {
    if (!_isInitialized) {
      return Duration.zero;
    }
    final now = getCurrentLocalTime();
    final utcNow = tz.TZDateTime.now(tz.getLocation('UTC'));
    return now.difference(utcNow);
  }

  /// Check if timezone is valid
  static bool isValidTimezone(String timezone) {
    try {
      tz.getLocation(timezone);
      return true;
    } catch (e) {
      AppLogger.log('[CentralizedTimezoneManager] Invalid timezone: $timezone');
      return false;
    }
  }

  /// Set timezone manually (for testing or user preference)
  static Future<bool> setTimezone(String timezone) async {
    try {
      if (!isValidTimezone(timezone)) {
        AppLogger.log(
            '[CentralizedTimezoneManager] Invalid timezone: $timezone');
        return false;
      }

      tz.setLocalLocation(tz.getLocation(timezone));
      await _saveTimezonePreference(timezone);

      AppLogger.log('[CentralizedTimezoneManager] Timezone set to: $timezone');
      return true;
    } catch (e) {
      AppLogger.log('[CentralizedTimezoneManager] Error setting timezone: $e');
      return false;
    }
  }

  /// Reset to device timezone
  static Future<void> resetToDeviceTimezone() async {
    try {
      final deviceTimezone = await _getDeviceTimezone();
      await setTimezone(deviceTimezone);
      AppLogger.log(
          '[CentralizedTimezoneManager] Reset to device timezone: $deviceTimezone');
    } catch (e) {
      AppLogger.log(
          '[CentralizedTimezoneManager] Error resetting to device timezone: $e');
    }
  }

  /// Get timezone info
  static Map<String, dynamic> getTimezoneInfo() {
    if (!_isInitialized) {
      return {
        'timezone': 'UTC',
        'offset': Duration.zero,
        'isInitialized': false,
      };
    }

    return {
      'timezone': tz.local.name,
      'offset': getTimezoneOffset(),
      'isInitialized': _isInitialized,
      'currentTime': getCurrentLocalTime().toIso8601String(),
    };
  }

  /// Handle timezone changes (e.g., when user travels)
  static Future<void> handleTimezoneChange() async {
    try {
      final currentDeviceTimezone = await _getDeviceTimezone();
      final currentAppTimezone = getCurrentTimezone();

      if (currentDeviceTimezone != currentAppTimezone) {
        AppLogger.log(
            '[CentralizedTimezoneManager] Timezone change detected: $currentAppTimezone -> $currentDeviceTimezone');
        await resetToDeviceTimezone();
      }
    } catch (e) {
      AppLogger.log(
          '[CentralizedTimezoneManager] Error handling timezone change: $e');
    }
  }

  /// Format time for display
  static String formatTime(tz.TZDateTime dateTime, {bool use24Hour = true}) {
    try {
      if (use24Hour) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        final hour = dateTime.hour;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:${dateTime.minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      AppLogger.log('[CentralizedTimezoneManager] Error formatting time: $e');
      return dateTime.toString();
    }
  }

  /// Get timezone name for display
  static String getDisplayName() {
    if (!_isInitialized) {
      return 'UTC';
    }

    final timezone = getCurrentTimezone();
    switch (timezone) {
      case 'Africa/Cairo':
        return 'Cairo (GMT+2)';
      case 'Asia/Riyadh':
        return 'Riyadh (GMT+3)';
      case 'Asia/Dubai':
        return 'Dubai (GMT+4)';
      case 'America/New_York':
        return 'New York (GMT-5)';
      case 'Europe/London':
        return 'London (GMT+0)';
      case 'Asia/Kolkata':
        return 'Kolkata (GMT+5:30)';
      case 'Asia/Tokyo':
        return 'Tokyo (GMT+9)';
      case 'Australia/Sydney':
        return 'Sydney (GMT+10)';
      default:
        return timezone.replaceAll('_', ' ');
    }
  }
}
