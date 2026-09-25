import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

/// Service to ensure background services remain active
class BackgroundServiceManager {
  static const String _lastHeartbeatKey = 'last_background_heartbeat';
  static const String _serviceRestartCountKey = 'service_restart_count';
  static const String _backgroundTaskKey = 'background_prayer_check';

  static Timer? _heartbeatTimer;
  static Timer? _backgroundCheckTimer;
  static bool _isMonitoring = false;
  static int _restartCount = 0;
  static const MethodChannel _backgroundChannel =
      MethodChannel('com.youssef.islamic_app.background');

  /// Initialize background service management
  static Future<void> initialize() async {
    try {
      AppLogger.log(
          '[BackgroundServiceManager] Initializing background service management...');

      // Start heartbeat monitoring
      _startHeartbeatMonitoring();

      // Start periodic background checks
      _startBackgroundChecks();

      // Load restart count
      final prefs = await SharedPreferences.getInstance();
      _restartCount = prefs.getInt(_serviceRestartCountKey) ?? 0;

      AppLogger.log(
          '[BackgroundServiceManager] Background service management initialized');
    } catch (e) {
      AppLogger.log('[BackgroundServiceManager] Error initializing: $e');
    }
  }

  /// Start heartbeat monitoring
  static void _startHeartbeatMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    AppLogger.log(
        '[BackgroundServiceManager] Starting heartbeat monitoring...');

    // Send heartbeat every 15 minutes
    _heartbeatTimer =
        Timer.periodic(const Duration(minutes: 15), (timer) async {
      await _sendHeartbeat();
    });

    // Initial heartbeat
    _sendHeartbeat();
  }

  /// Start periodic background checks
  static void _startBackgroundChecks() {
    AppLogger.log(
        '[BackgroundServiceManager] Starting periodic background checks...');

    // Check every 30 minutes
    _backgroundCheckTimer =
        Timer.periodic(const Duration(minutes: 30), (timer) async {
      await _performBackgroundPrayerCheck();
    });
  }

  /// Send heartbeat to indicate service is alive
  static Future<void> _sendHeartbeat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastHeartbeatKey, now);

      AppLogger.log(
          '[BackgroundServiceManager] Heartbeat sent at ${DateTime.now()}');

      // Check if service needs restart
      await _checkServiceHealth();
    } catch (e) {
      AppLogger.log('[BackgroundServiceManager] Error sending heartbeat: $e');
    }
  }

  /// Check service health and restart if needed
  static Future<void> _checkServiceHealth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastHeartbeat = prefs.getInt(_lastHeartbeatKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // If no heartbeat for more than 45 minutes, service might be dead
      if (now - lastHeartbeat > 45 * 60 * 1000) {
        AppLogger.log(
            '[BackgroundServiceManager] Service appears dead, initiating restart...');
        await _restartBackgroundServices();
      }
    } catch (e) {
      AppLogger.log(
          '[BackgroundServiceManager] Error checking service health: $e');
    }
  }

  /// Restart background services
  static Future<void> _restartBackgroundServices() async {
    try {
      _restartCount++;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_serviceRestartCountKey, _restartCount);

      AppLogger.log(
          '[BackgroundServiceManager] Restarting background services (attempt #$_restartCount)');

      // Restart timers
      _restartTimers();

      // Send new heartbeat
      await _sendHeartbeat();

      // If too many restarts, notify user
      if (_restartCount >= 5) {
        _notifyUserAboutServiceIssues();
      }
    } catch (e) {
      AppLogger.log('[BackgroundServiceManager] Error restarting services: $e');
    }
  }

  /// Restart monitoring timers
  static void _restartTimers() {
    // Cancel existing timers
    _heartbeatTimer?.cancel();
    _backgroundCheckTimer?.cancel();

    // Restart monitoring
    _isMonitoring = false;
    _startHeartbeatMonitoring();
    _startBackgroundChecks();
  }

  /// Notify user about service issues
  static void _notifyUserAboutServiceIssues() {
    AppLogger.log(
        '[BackgroundServiceManager] USER ALERT: Background services having issues. Please restart app.');

    // This would typically show a user notification
    // For now, we'll just log it
  }

  /// Check if background services are healthy
  static Future<bool> isServiceHealthy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastHeartbeat = prefs.getInt(_lastHeartbeatKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Service is healthy if heartbeat was within last 30 minutes
      return (now - lastHeartbeat) < 30 * 60 * 1000;
    } catch (e) {
      AppLogger.log(
          '[BackgroundServiceManager] Error checking service health: $e');
      return false;
    }
  }

  /// Get service statistics
  static Future<Map<String, dynamic>> getServiceStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastHeartbeat = prefs.getInt(_lastHeartbeatKey) ?? 0;
      final restartCount = prefs.getInt(_serviceRestartCountKey) ?? 0;

      final lastHeartbeatTime = lastHeartbeat > 0
          ? DateTime.fromMillisecondsSinceEpoch(lastHeartbeat)
          : null;

      return {
        'isHealthy': await isServiceHealthy(),
        'lastHeartbeat': lastHeartbeatTime?.toIso8601String(),
        'restartCount': restartCount,
        'isMonitoring': _isMonitoring,
      };
    } catch (e) {
      AppLogger.log(
          '[BackgroundServiceManager] Error getting service stats: $e');
      return {};
    }
  }

  /// Manual service restart
  static Future<void> manualRestart() async {
    AppLogger.log(
        '[BackgroundServiceManager] Manual service restart requested');
    await _restartBackgroundServices();
  }

  /// Perform background prayer check
  static Future<void> _performBackgroundPrayerCheck() async {
    try {
      AppLogger.log(
          '[BackgroundServiceManager] Performing background prayer check...');

      // Send heartbeat to indicate service is alive
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('last_background_heartbeat', now);

      // Additional background checks can be added here
      // For example: check if prayer notifications are still scheduled

      AppLogger.log(
          '[BackgroundServiceManager] Background prayer check completed');
    } catch (e) {
      AppLogger.log(
          '[BackgroundServiceManager] Error in background prayer check: $e');
    }
  }

  /// Dispose resources
  static void dispose() {
    _heartbeatTimer?.cancel();
    _backgroundCheckTimer?.cancel();
    _heartbeatTimer = null;
    _backgroundCheckTimer = null;
    _isMonitoring = false;
    AppLogger.log(
        '[BackgroundServiceManager] Background service manager disposed');
  }
}
