import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

class PermissionManager {
  static const String _lastPermissionCheckKey = 'last_permission_check';
  static const String _exactAlarmPermissionKey = 'exact_alarm_granted';

  static bool _isInitialized = false;
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;

  /// Initialize the permission manager
  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    if (_isInitialized) return;

    _notificationsPlugin = plugin;
    _isInitialized = true;

    AppLogger.log('[PermissionManager] Initialized');
  }

  /// Check and request all required permissions
  static Future<PermissionStatus> checkAndRequestAllPermissions() async {
    AppLogger.log('[PermissionManager] Checking all permissions...');

    final permissions = <Permission>[
      Permission.notification,
      if (Platform.isAndroid) Permission.scheduleExactAlarm,
      if (Platform.isAndroid) Permission.ignoreBatteryOptimizations,
    ];

    // Check current status
    final statuses = await permissions.request();

    // Log results
    for (final entry in statuses.entries) {
      final status = entry.value;
      if (status.isGranted) {
        AppLogger.log('[PermissionManager] ✅ GRANTED: ${entry.key}');
      } else if (status.isDenied) {
        AppLogger.log('[PermissionManager] ❌ DENIED: ${entry.key}');
      } else if (status.isPermanentlyDenied) {
        AppLogger.log('[PermissionManager] ⛔ PERMANENTLY DENIED: ${entry.key}');
      } else if (status.isLimited) {
        AppLogger.log('[PermissionManager] ⚠️ LIMITED: ${entry.key}');
      } else if (status.isRestricted) {
        AppLogger.log('[PermissionManager] 🔒 RESTRICTED: ${entry.key}');
      }
    }

    // Check exact alarm permission specifically for Android
    if (Platform.isAndroid) {
      await _checkExactAlarmPermission();
    }

    // Return overall status
    final allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted ? PermissionStatus.granted : PermissionStatus.denied;
  }

  /// Check exact alarm permission for Android 14+
  static Future<bool> _checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidPlugin =
          _notificationsPlugin?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) {
        AppLogger.log('[PermissionManager] Android plugin not available');
        return false;
      }

      final canScheduleExact =
          await androidPlugin.canScheduleExactNotifications() ?? false;
      AppLogger.log(
          '[PermissionManager] Exact alarm permission: $canScheduleExact');

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_exactAlarmPermissionKey, canScheduleExact);

      return canScheduleExact;
    } catch (e) {
      AppLogger.log(
          '[PermissionManager] Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Request exact alarm permission specifically
  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidPlugin =
          _notificationsPlugin?.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) {
        AppLogger.log(
            '[PermissionManager] Android plugin not available for exact alarm request');
        return false;
      }

      // First check current status
      final currentStatus =
          await androidPlugin.canScheduleExactNotifications() ?? false;
      if (currentStatus) {
        AppLogger.log(
            '[PermissionManager] Exact alarm permission already granted');
        return true;
      }

      // Request permission
      AppLogger.log('[PermissionManager] Requesting exact alarm permission...');
      await androidPlugin.requestExactAlarmsPermission();

      // Check again after request
      final newStatus =
          await androidPlugin.canScheduleExactNotifications() ?? false;
      AppLogger.log(
          '[PermissionManager] Exact alarm permission after request: $newStatus');

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_exactAlarmPermissionKey, newStatus);

      return newStatus;
    } catch (e) {
      AppLogger.log(
          '[PermissionManager] Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// Check if exact alarm permission is granted
  static Future<bool> hasExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // Check cached value first
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getBool(_exactAlarmPermissionKey);
      if (cached != null) {
        AppLogger.log(
            '[PermissionManager] Using cached exact alarm permission: $cached');
        return cached;
      }

      // Check actual permission
      return await _checkExactAlarmPermission();
    } catch (e) {
      AppLogger.log(
          '[PermissionManager] Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Check notification permission
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    AppLogger.log('[PermissionManager] Notification permission: $status');
    return status.isGranted;
  }

  /// Check battery optimization permission
  static Future<bool> hasBatteryOptimizationPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.ignoreBatteryOptimizations.status;
    AppLogger.log(
        '[PermissionManager] Battery optimization permission: $status');
    return status.isGranted;
  }

  /// Check if all critical permissions are granted
  static Future<bool> areAllCriticalPermissionsGranted() async {
    final hasNotification = await hasNotificationPermission();
    final hasExactAlarm = await hasExactAlarmPermission();

    final allGranted = hasNotification && hasExactAlarm;
    AppLogger.log(
        '[PermissionManager] All critical permissions granted: $allGranted');
    return allGranted;
  }

  /// Get permission status summary
  static Future<Map<String, bool>> getPermissionStatus() async {
    final Map<String, bool> status = {};

    status['notification'] = await hasNotificationPermission();
    status['exactAlarm'] = await hasExactAlarmPermission();
    status['batteryOptimization'] = await hasBatteryOptimizationPermission();

    return status;
  }

  /// Open app settings for permissions
  static Future<void> openAppSettings() async {
    AppLogger.log('[PermissionManager] Opening app settings...');
    await openAppSettings();
  }

  /// Should show permission rationale
  static bool shouldShowPermissionRationale() {
    // This can be enhanced based on your app's logic
    return false;
  }

  /// Handle permission denial gracefully
  static Future<void> handlePermissionDenial() async {
    AppLogger.log('[PermissionManager] Handling permission denial...');

    // Save current state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _lastPermissionCheckKey, DateTime.now().toIso8601String());

    // You can show a dialog or navigate to settings here
  }

  /// Check if permissions need to be rechecked (e.g., after app update)
  static Future<bool> shouldRecheckPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString(_lastPermissionCheckKey);

    if (lastCheck == null) return true;

    final lastCheckDate = DateTime.parse(lastCheck);
    final now = DateTime.now();

    // Recheck if more than 7 days have passed
    return now.difference(lastCheckDate).inDays > 7;
  }
}
