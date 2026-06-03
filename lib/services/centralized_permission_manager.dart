import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app_logger.dart';

/// Centralized permission management for all app permissions
class CentralizedPermissionManager {
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;
  static bool _isInitialized = false;

  /// Initialize the permission manager
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin? plugin) async {
    if (_isInitialized) return;

    _notificationsPlugin = plugin;
    _isInitialized = true;
    AppLogger.log('[CentralizedPermissionManager] Initialized');
  }

  /// Check and request all critical permissions
  static Future<PermissionStatus> checkAndRequestAllPermissions() async {
    try {
      AppLogger.log(
          '[CentralizedPermissionManager] Checking all permissions...');

      // Request notification permission
      final notificationStatus = await _requestNotificationPermission();

      // Request exact alarm permission (Android 12+)
      final exactAlarmStatus = await _requestExactAlarmPermission();

      // Request location permission
      final locationStatus = await _requestLocationPermission();

      // Request battery optimization permission
      final batteryStatus = await _requestBatteryOptimizationPermission();

      // Determine overall status
      final allGranted = notificationStatus == PermissionStatus.granted &&
          exactAlarmStatus == PermissionStatus.granted &&
          locationStatus == PermissionStatus.granted &&
          batteryStatus == PermissionStatus.granted;

      AppLogger.log(
          '[CentralizedPermissionManager] All permissions granted: $allGranted');
      return allGranted ? PermissionStatus.granted : PermissionStatus.denied;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error checking permissions: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check if all critical permissions are granted
  static Future<bool> areAllCriticalPermissionsGranted() async {
    try {
      final hasNotification = await hasNotificationPermission();
      final hasExactAlarm = await hasExactAlarmPermission();
      final hasLocation = await hasLocationPermission();

      final allGranted = hasNotification && hasExactAlarm && hasLocation;
      AppLogger.log(
          '[CentralizedPermissionManager] All critical permissions granted: $allGranted');
      return allGranted;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error checking permissions: $e');
      return false;
    }
  }

  /// Request notification permission
  static Future<PermissionStatus> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      AppLogger.log(
          '[CentralizedPermissionManager] Notification permission: $status');
      return status;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error requesting notification permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Request exact alarm permission (Android 12+)
  static Future<PermissionStatus> _requestExactAlarmPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.scheduleExactAlarm.request();
        AppLogger.log(
            '[CentralizedPermissionManager] Exact alarm permission: $status');
        return status;
      }
      return PermissionStatus.granted;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error requesting exact alarm permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Request location permission
  static Future<PermissionStatus> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      AppLogger.log(
          '[CentralizedPermissionManager] Location permission: $status');
      return status;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error requesting location permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Request battery optimization permission
  static Future<PermissionStatus>
      _requestBatteryOptimizationPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.ignoreBatteryOptimizations.request();
        AppLogger.log(
            '[CentralizedPermissionManager] Battery optimization permission: $status');
        return status;
      }
      return PermissionStatus.granted;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error requesting battery optimization permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      AppLogger.log(
          '[CentralizedPermissionManager] Notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error checking notification permission: $e');
      return false;
    }
  }

  /// Check if exact alarm permission is granted
  static Future<bool> hasExactAlarmPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      // Use Flutter Local Notifications plugin for exact alarm check
      if (_notificationsPlugin != null) {
        final androidPlugin = _notificationsPlugin!
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          final canScheduleExact =
              await androidPlugin.canScheduleExactNotifications() ?? false;
          AppLogger.log(
              '[CentralizedPermissionManager] Exact alarm permission: $canScheduleExact');
          return canScheduleExact;
        }
      }

      // Fallback to permission_handler
      final status = await Permission.scheduleExactAlarm.status;
      AppLogger.log(
          '[CentralizedPermissionManager] Exact alarm permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error checking exact alarm permission: $e');
      return false;
    }
  }

  /// Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    try {
      final status = await Permission.location.status;
      AppLogger.log(
          '[CentralizedPermissionManager] Location permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error checking location permission: $e');
      return false;
    }
  }

  /// Check if battery optimization permission is granted
  static Future<bool> hasBatteryOptimizationPermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final status = await Permission.ignoreBatteryOptimizations.status;
      AppLogger.log(
          '[CentralizedPermissionManager] Battery optimization permission status: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error checking battery optimization permission: $e');
      return false;
    }
  }

  /// Open app settings for permissions
  static Future<void> openAppSettings() async {
    try {
      // TODO: Implement proper app settings opening
      AppLogger.log(
          '[CentralizedPermissionManager] App settings opening not implemented yet');
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error opening app settings: $e');
    }
  }

  /// Get permission status summary
  static Future<Map<String, bool>> getPermissionStatusSummary() async {
    try {
      final summary = {
        'notification': await hasNotificationPermission(),
        'exactAlarm': await hasExactAlarmPermission(),
        'location': await hasLocationPermission(),
        'batteryOptimization': await hasBatteryOptimizationPermission(),
      };

      AppLogger.log(
          '[CentralizedPermissionManager] Permission summary: $summary');
      return summary;
    } catch (e) {
      AppLogger.log(
          '[CentralizedPermissionManager] Error getting permission summary: $e');
      return {};
    }
  }
}
