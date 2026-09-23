import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';
import 'permission_monitor_service.dart';
import 'background_service_manager.dart';
import 'memory_manager.dart';
import 'prayer_time_calculation_service.dart';

/// Comprehensive health monitoring for all app systems
class HealthMonitor {
  static const String _lastHealthCheckKey = 'last_health_check';
  static Timer? _healthCheckTimer;
  static bool _isMonitoring = false;
  static Map<String, dynamic> _lastHealthReport = {};
  
  /// Initialize health monitoring
  static Future<void> initialize() async {
    try {
      AppLogger.log('[HealthMonitor] Initializing health monitoring...');
      
      // Start periodic health checks
      _startHealthMonitoring();
      
      // Perform initial health check
      await _performHealthCheck();
      
      AppLogger.log('[HealthMonitor] Health monitoring initialized');
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error initializing: $e');
    }
  }

  /// Start health monitoring
  static void _startHealthMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    AppLogger.log('[HealthMonitor] Starting health monitoring...');
    
    // Check health every 10 minutes
    _healthCheckTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      await _performHealthCheck();
    });
  }

  /// Perform comprehensive health check
  static Future<void> _performHealthCheck() async {
    try {
      AppLogger.log('[HealthMonitor] Performing comprehensive health check...');
      
      final healthReport = <String, dynamic>{};
      
      // Check permissions
      healthReport['permissions'] = await _checkPermissionsHealth();
      
      // Check background services
      healthReport['backgroundServices'] = await _checkBackgroundServicesHealth();
      
      // Check memory usage
      healthReport['memory'] = await _checkMemoryHealth();
      
      // Check location services
      healthReport['location'] = await _checkLocationHealth();
      
      // Check notification system
      healthReport['notifications'] = await _checkNotificationHealth();
      
      // Overall health score
      healthReport['overallHealth'] = _calculateOverallHealth(healthReport);
      healthReport['timestamp'] = DateTime.now().toIso8601String();
      
      _lastHealthReport = healthReport;
      
      // Save health report
      await _saveHealthReport(healthReport);
      
      // Log health status
      _logHealthStatus(healthReport);
      
      // Handle any critical issues
      await _handleHealthIssues(healthReport);
      
      AppLogger.log('[HealthMonitor] Health check completed');
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error during health check: $e');
    }
  }

  /// Check permissions health
  static Future<Map<String, dynamic>> _checkPermissionsHealth() async {
    try {
      final allGranted = await PermissionMonitorService.areAllPermissionsGranted();
      final statuses = await PermissionMonitorService.getCurrentPermissionStatus();
      
      return {
        'allGranted': allGranted,
        'statuses': statuses.map((key, value) => MapEntry(key.toString(), value.toString())),
        'health': allGranted ? 'healthy' : 'warning',
        'score': allGranted ? 100 : 50,
      };
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error checking permissions health: $e');
      return {
        'health': 'error',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  /// Check background services health
  static Future<Map<String, dynamic>> _checkBackgroundServicesHealth() async {
    try {
      final isHealthy = await BackgroundServiceManager.isServiceHealthy();
      final stats = await BackgroundServiceManager.getServiceStats();
      
      return {
        'isHealthy': isHealthy,
        'stats': stats,
        'health': isHealthy ? 'healthy' : 'warning',
        'score': isHealthy ? 100 : 60,
      };
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error checking background services health: $e');
      return {
        'health': 'error',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  /// Check memory health
  static Future<Map<String, dynamic>> _checkMemoryHealth() async {
    try {
      final stats = await MemoryManager.getMemoryStats();
      final currentUsage = stats['currentUsage'] as double? ?? 0.0;
      final threshold = stats['warningThreshold'] as int? ?? 100;
      final isHighUsage = stats['isHighUsage'] as bool? ?? false;
      
      return {
        'currentUsage': currentUsage,
        'threshold': threshold,
        'isHighUsage': isHighUsage,
        'health': isHighUsage ? 'warning' : 'healthy',
        'score': isHighUsage ? 70 : 100,
      };
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error checking memory health: $e');
      return {
        'health': 'error',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  /// Check location services health
  static Future<Map<String, dynamic>> _checkLocationHealth() async {
    try {
      final position = await PrayerTimeCalculationService.getCurrentLocation();
      final isValid = position.latitude != 0 && position.longitude != 0;
      
      return {
        'hasLocation': true,
        'coordinates': '${position.latitude}, ${position.longitude}',
        'isValid': isValid,
        'health': isValid ? 'healthy' : 'warning',
        'score': isValid ? 100 : 60,
      };
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error checking location health: $e');
      return {
        'health': 'error',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  /// Check notification system health
  static Future<Map<String, dynamic>> _checkNotificationHealth() async {
    try {
      // This would check if notifications are working properly
      // For now, we'll assume they're healthy if no errors are reported
      
      return {
        'health': 'healthy',
        'score': 100,
        'lastCheck': DateTime.now().toIso8601String(),
      };
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error checking notification health: $e');
      return {
        'health': 'error',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  /// Calculate overall health score
  static int _calculateOverallHealth(Map<String, dynamic> healthReport) {
    try {
      int totalScore = 0;
      int componentCount = 0;
      
      healthReport.forEach((key, value) {
        if (value is Map<String, dynamic> && value.containsKey('score')) {
          totalScore += value['score'] as int;
          componentCount++;
        }
      });
      
      return componentCount > 0 ? (totalScore ~/ componentCount) : 0;
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error calculating overall health: $e');
      return 0;
    }
  }

  /// Save health report
  static Future<void> _saveHealthReport(Map<String, dynamic> healthReport) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastHealthCheckKey, healthReport['timestamp'] as String);
      
      // Save detailed report (in a real app, you might save this to a file or database)
      AppLogger.log('[HealthMonitor] Health report saved');
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error saving health report: $e');
    }
  }

  /// Log health status
  static void _logHealthStatus(Map<String, dynamic> healthReport) {
    try {
      final overallScore = healthReport['overallHealth'] as int;
      final timestamp = healthReport['timestamp'] as String;
      
      AppLogger.log('[HealthMonitor] 📊 Health Report - $timestamp');
      AppLogger.log('[HealthMonitor] 🎯 Overall Score: $overallScore/100');
      
      healthReport.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final health = value['health'] as String? ?? 'unknown';
          final score = value['score'] as int? ?? 0;
          final icon = _getHealthIcon(health);
          AppLogger.log('[HealthMonitor] $icon $key: $health ($score/100)');
        }
      });
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error logging health status: $e');
    }
  }

  /// Get health icon based on status
  static String _getHealthIcon(String health) {
    switch (health.toLowerCase()) {
      case 'healthy':
        return '✅';
      case 'warning':
        return '⚠️';
      case 'error':
        return '❌';
      default:
        return '❓';
    }
  }

  /// Handle health issues
  static Future<void> _handleHealthIssues(Map<String, dynamic> healthReport) async {
    try {
      bool hasCriticalIssues = false;
      
      healthReport.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final health = value['health'] as String? ?? 'unknown';
          final score = value['score'] as int? ?? 100;
          
          if (health == 'error' || score < 50) {
            hasCriticalIssues = true;
            AppLogger.log('[HealthMonitor] 🚨 Critical issue detected in $key: $health');
          }
        }
      });
      
      if (hasCriticalIssues) {
        await _handleCriticalHealthIssues();
      }
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error handling health issues: $e');
    }
  }

  /// Handle critical health issues
  static Future<void> _handleCriticalHealthIssues() async {
    try {
      AppLogger.log('[HealthMonitor] 🚨 Handling critical health issues...');
      
      // Attempt to recover systems
      await _attemptSystemRecovery();
      
      AppLogger.log('[HealthMonitor] Recovery attempts completed');
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error handling critical issues: $e');
    }
  }

  /// Attempt system recovery
  static Future<void> _attemptSystemRecovery() async {
    try {
      AppLogger.log('[HealthMonitor] Attempting system recovery...');
      
      // Restart background services
      await BackgroundServiceManager.manualRestart();
      
      // Perform memory cleanup
      await MemoryManager.manualAggressiveCleanup();
      
      // Check permissions again
      await PermissionMonitorService.getCurrentPermissionStatus();
      
      AppLogger.log('[HealthMonitor] System recovery completed');
      
    } catch (e) {
      AppLogger.log('[HealthMonitor] Error during system recovery: $e');
    }
  }

  /// Get current health report
  static Map<String, dynamic> getCurrentHealthReport() {
    return Map.from(_lastHealthReport);
  }

  /// Get health summary
  static Map<String, dynamic> getHealthSummary() {
    if (_lastHealthReport.isEmpty) {
      return {
        'status': 'unknown',
        'score': 0,
        'lastCheck': null,
      };
    }
    
    final overallScore = _lastHealthReport['overallHealth'] as int? ?? 0;
    final timestamp = _lastHealthReport['timestamp'] as String?;
    
    String status;
    if (overallScore >= 90) {
      status = 'excellent';
    } else if (overallScore >= 70) {
      status = 'good';
    } else if (overallScore >= 50) {
      status = 'fair';
    } else {
      status = 'poor';
    }
    
    return {
      'status': status,
      'score': overallScore,
      'lastCheck': timestamp,
      'isMonitoring': _isMonitoring,
    };
  }

  /// Manual health check
  static Future<void> manualHealthCheck() async {
    AppLogger.log('[HealthMonitor] Manual health check requested');
    await _performHealthCheck();
  }

  /// Dispose resources
  static void dispose() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    _isMonitoring = false;
    _lastHealthReport.clear();
    AppLogger.log('[HealthMonitor] Health monitor disposed');
  }
}
