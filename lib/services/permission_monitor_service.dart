import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

/// Service to monitor and manage app permissions
class PermissionMonitorService {
  static const String _lastPermissionCheckKey = 'last_permission_check';
  static const String _permissionRevokedKey = 'permission_revoked_count';
  static Timer? _monitoringTimer;
  static bool _isMonitoring = false;
  static final Map<Permission, PermissionStatus> _lastKnownStatus = {};

  /// Start monitoring permissions
  static void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    AppLogger.log('[PermissionMonitorService] Starting permission monitoring...');
    
    // Check permissions every hour
    _monitoringTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await _checkAllPermissions();
    });
    
    // Initial check
    _checkAllPermissions();
  }

  /// Stop monitoring permissions
  static void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
    AppLogger.log('[PermissionMonitorService] Permission monitoring stopped');
  }

  /// Check all critical permissions
  static Future<void> _checkAllPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastPermissionCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Only check if at least 30 minutes have passed since last check
      if (now - lastCheck < 30 * 60 * 1000) {
        return;
      }

      AppLogger.log('[PermissionMonitorService] Checking all permissions...');
      
      final criticalPermissions = [
        Permission.notification,
        Permission.location,
        Permission.scheduleExactAlarm,
        Permission.ignoreBatteryOptimizations,
      ];

      bool needsRequest = false;
      
      for (final permission in criticalPermissions) {
        final currentStatus = await permission.status;
        final lastStatus = _lastKnownStatus[permission];
        
        // Check if permission was revoked
        if (lastStatus != null && 
            lastStatus.isGranted && 
            !currentStatus.isGranted) {
          AppLogger.log('[PermissionMonitorService] Permission revoked: $permission');
          await _handlePermissionRevoked(permission);
          needsRequest = true;
        }
        
        _lastKnownStatus[permission] = currentStatus;
      }

      if (needsRequest) {
        await _requestMissingPermissions();
      }

      // Update last check time
      await prefs.setInt(_lastPermissionCheckKey, now);
      
    } catch (e) {
      AppLogger.log('[PermissionMonitorService] Error checking permissions: $e');
    }
  }

  /// Handle permission revocation
  static Future<void> _handlePermissionRevoked(Permission permission) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final revokedCount = prefs.getInt(_permissionRevokedKey) ?? 0;
      await prefs.setInt(_permissionRevokedKey, revokedCount + 1);
      
      AppLogger.log('[PermissionMonitorService] Permission $permission revoked (count: ${revokedCount + 1})');
      
      // If revoked multiple times, show user notification
      if (revokedCount >= 2) {
        _showPermissionRevokedNotification(permission);
      }
      
    } catch (e) {
      AppLogger.log('[PermissionMonitorService] Error handling permission revocation: $e');
    }
  }

  /// Request missing permissions
  static Future<void> _requestMissingPermissions() async {
    try {
      AppLogger.log('[PermissionMonitorService] Requesting missing permissions...');
      
      final permissions = [
        Permission.notification,
        Permission.location,
        Permission.scheduleExactAlarm,
        Permission.ignoreBatteryOptimizations,
      ];

      final statuses = await permissions.request();
      
      for (final entry in statuses.entries) {
        final permission = entry.key;
        final status = entry.value;
        
        AppLogger.log('[PermissionMonitorService] Permission $permission: $status');
        
        if (status.isGranted) {
          _lastKnownStatus[permission] = status;
        }
      }
      
    } catch (e) {
      AppLogger.log('[PermissionMonitorService] Error requesting permissions: $e');
    }
  }

  /// Show notification about permission revocation
  static void _showPermissionRevokedNotification(Permission permission) {
    AppLogger.log('[PermissionMonitorService] Showing permission revocation notification for $permission');
    
    // This would typically show a user-friendly notification
    // For now, we'll just log it
    final permissionName = _getPermissionDisplayName(permission);
    AppLogger.log('[PermissionMonitorService] USER ALERT: $permissionName permission was revoked. Please re-enable in app settings.');
  }

  /// Get user-friendly permission name
  static String _getPermissionDisplayName(Permission permission) {
    switch (permission) {
      case Permission.notification:
        return 'Notifications';
      case Permission.location:
        return 'Location';
      case Permission.scheduleExactAlarm:
        return 'Exact Alarms';
      case Permission.ignoreBatteryOptimizations:
        return 'Battery Optimization';
      default:
        return permission.toString();
    }
  }

  /// Get current permission status
  static Future<Map<Permission, PermissionStatus>> getCurrentPermissionStatus() async {
    final permissions = [
      Permission.notification,
      Permission.location,
      Permission.scheduleExactAlarm,
      Permission.ignoreBatteryOptimizations,
    ];

    final Map<Permission, PermissionStatus> statuses = {};
    
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }
    
    return statuses;
  }

  /// Check if all critical permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    final statuses = await getCurrentPermissionStatus();
    return statuses.values.every((status) => status.isGranted);
  }

  /// Initialize permission monitoring
  static Future<void> initialize() async {
    try {
      // Initialize last known status
      final statuses = await getCurrentPermissionStatus();
      _lastKnownStatus.clear();
      _lastKnownStatus.addAll(statuses);
      
      AppLogger.log('[PermissionMonitorService] Initialized with ${statuses.length} permissions');
      
      // Start monitoring
      startMonitoring();
      
    } catch (e) {
      AppLogger.log('[PermissionMonitorService] Error initializing: $e');
    }
  }

  /// Dispose resources
  static void dispose() {
    stopMonitoring();
    _lastKnownStatus.clear();
  }
}
