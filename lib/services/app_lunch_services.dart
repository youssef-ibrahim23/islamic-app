import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'app_initializer.dart';
import 'app_logger.dart';

/// Legacy app launch service - DEPRECATED
/// Use AppInitializer instead for new implementations
class AppLaunchService {
  static bool _initialized = false;

  /// Initialize app using new AppInitializer
  static Future<void> initializeApp() async {
    if (_initialized) {
      AppLogger.log("🔄 App already initialized, skipping",
          name: "AppLaunchService");
      return;
    }

    AppLogger.log("🔄 Initializing app using new AppInitializer...",
        name: "AppLaunchService");

    try {
      // Use the new AppInitializer
      await AppInitializer.initialize();

      _initialized = true;
      AppLogger.log("✅ App initialization completed successfully!",
          name: "AppLaunchService");
    } catch (e) {
      AppLogger.log("❌ App initialization failed: $e",
          name: "AppLaunchService");
    }
  }

  /// Request permissions - DEPRECATED
  /// Use CentralizedPermissionManager instead
  @Deprecated(
      'Use CentralizedPermissionManager.checkAndRequestAllPermissions() instead')
  static Future<void> requestPermissions() async {
    AppLogger.log("⚠️ Using deprecated permission request method",
        name: "AppLaunchService");
    // This method is deprecated - permissions are now handled by AppInitializer
  }

  /// Schedule daily Azkar reminders - DEPRECATED
  /// Use ReminderScheduler instead
  @Deprecated('Use ReminderScheduler.scheduleAllDailyReminders() instead')
  static Future<void> scheduleDailyAzkarReminders() async {
    AppLogger.log("⚠️ Using deprecated Azkar scheduling method",
        name: "AppLaunchService");
    // This method is deprecated - reminders are now handled by AppInitializer
  }

  /// Schedule monthly Azan update - DEPRECATED
  /// This method is no longer needed
  @Deprecated('This method is no longer needed')
  static Future<void> scheduleMonthlyAzanUpdate() async {
    AppLogger.log("⚠️ Monthly Azan update is deprecated",
        name: "AppLaunchService");
    // This method is no longer needed since we use daily scheduling
  }
}
