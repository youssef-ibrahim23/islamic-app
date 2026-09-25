import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

import 'centralized_permission_manager.dart';
import 'centralized_timezone_manager.dart';
import 'unified_prayer_scheduler.dart';
import 'reminder_scheduler.dart';
import 'error_handler.dart';
import 'app_logger.dart';
import 'background_service_handler.dart';
import 'home_services.dart';
import 'permission_monitor_service.dart';
import 'background_service_manager.dart';
import 'memory_manager.dart';
import 'health_monitor.dart';
import '../globals.dart';

/// Unified app initializer that orchestrates all initialization tasks
class AppInitializer {
  static bool _isInitialized = false;
  static final List<Function()> _initializationCallbacks = [];

  /// Initialize the entire application
  static Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.log('[AppInitializer] App already initialized, skipping');
      return;
    }

    AppLogger.log('[AppInitializer] Starting app initialization...');

    try {
      // Initialize error handler first
      ErrorHandler.initialize();

      // Initialize all services in the correct order
      await _initializeServices();

      // Run parallel initialization tasks
      await _runParallelTasks();

      // Initialize notification systems
      await _initializeNotificationSystems();

      // Initialize permission monitoring
      await PermissionMonitorService.initialize();

      // Initialize background service management
      await BackgroundServiceManager.initialize();

      // Initialize memory management
      await MemoryManager.initialize();

      // Initialize health monitoring
      await HealthMonitor.initialize();

      // Schedule startup tasks
      await _scheduleStartupTasks();

      _isInitialized = true;
      AppLogger.log(
          '[AppInitializer] ✅ App initialization completed successfully!');

      // Notify all callbacks
      _notifyInitializationComplete();
    } catch (e, stack) {
      AppLogger.log('[AppInitializer] ❌ App initialization failed: $e');
      ErrorHandler.handleCustomError('AppInitialization', e, stack);
      rethrow;
    }
  }

  /// Add initialization callback
  static void addInitializationCallback(Function() callback) {
    _initializationCallbacks.add(callback);
  }

  /// Notify all initialization callbacks
  static void _notifyInitializationComplete() {
    for (final callback in _initializationCallbacks) {
      try {
        callback();
      } catch (e) {
        AppLogger.log('[AppInitializer] Error in initialization callback: $e');
      }
    }
  }

  /// Initialize core services
  static Future<void> _initializeServices() async {
    AppLogger.log('[AppInitializer] 📦 Initializing core services...');

    await Future.wait([
      _initializeBackgroundService(),
      _initializeLanguage(),
      _initializePermissions(),
      _initializeTimezone(),
    ]);
  }

  /// Initialize background service handler
  static Future<void> _initializeBackgroundService() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[AppInitializer] 🔧 Initializing background service handler...');
        BackgroundServiceHandler.initialize();
      },
      'initializeBackgroundService',
    );
  }

  /// Initialize language settings
  static Future<void> _initializeLanguage() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 🌐 Setting default language to Arabic');
        Globals.languageState = false;

        final prefs = await SharedPreferences.getInstance();
        final savedLanguage = prefs.getBool("language");
        if (savedLanguage != null) {
          Globals.languageState = savedLanguage;
        }

        final languageName = Globals.languageState! ? "English" : "Arabic";
        AppLogger.log(
            '[AppInitializer] 🌐 Language loaded: $languageName (saved=$savedLanguage)');
      },
      'initializeLanguage',
    );
  }

  /// Initialize permissions
  static Future<void> _initializePermissions() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 🔐 Requesting permissions...');
        final permissionStatus =
            await CentralizedPermissionManager.checkAndRequestAllPermissions();

        if (permissionStatus == PermissionStatus.granted) {
          AppLogger.log('[AppInitializer] ✅ All permissions granted');
        } else {
          AppLogger.log('[AppInitializer] ⚠️ Some permissions denied');
        }
      },
      'initializePermissions',
    );
  }

  /// Initialize timezone
  static Future<void> _initializeTimezone() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 🌍 Initializing timezone...');
        await CentralizedTimezoneManager.initialize();

        final timezoneInfo = CentralizedTimezoneManager.getTimezoneInfo();
        AppLogger.log('[AppInitializer] 🌍 Timezone info: $timezoneInfo');
      },
      'initializeTimezone',
    );
  }

  /// Run parallel initialization tasks
  static Future<void> _runParallelTasks() async {
    AppLogger.log(
        '[AppInitializer] ⚙️ Running parallel initialization tasks...');

    await Future.wait([
      _handleFirstRun(),
      _loadLocationState(),
      HomeServices.loadLastSurahAsync(),
    ]);
  }

  /// Handle first run setup
  static Future<void> _handleFirstRun() async {
    await ErrorHandler.safeExecute(
      () async {
        final prefs = await SharedPreferences.getInstance();
        final isFirstRun = prefs.getBool('first_run') ?? true;

        AppLogger.log(
            '[AppInitializer] 🔍 Checking first run: first_run=$isFirstRun');

        if (isFirstRun) {
          AppLogger.log(
              '[AppInitializer] 🎉 First app launch detected! Setting up initial configuration');
          await prefs.setBool('first_run', false);

          // Clean temporary directory
          await _cleanTemporaryDirectory();
        } else {
          AppLogger.log(
              '[AppInitializer] 👋 Returning user, skipping first-run setup');
        }
      },
      'handleFirstRun',
    );
  }

  /// Clean temporary directory
  static Future<void> _cleanTemporaryDirectory() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 🧹 Cleaning temporary directory...');
        final tempDir = await getTemporaryDirectory();

        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
          AppLogger.log(
              '[AppInitializer] ✅ Temporary directory cleaned successfully');
        } else {
          AppLogger.log(
              '[AppInitializer] ℹ️ Temporary directory does not exist, nothing to clean');
        }
      },
      'cleanTemporaryDirectory',
    );
  }

  /// Load location state
  static Future<void> _loadLocationState() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 📍 Loading location state...');
        final prefs = await SharedPreferences.getInstance();

        // Detect device country
        await _detectDeviceCountry();

        // Load selected country
        final savedCountry = prefs.getString('countryEnglish');
        Globals.selectedCountry = savedCountry;

        // Use device country as default if no saved country
        if (Globals.selectedCountry == null && Globals.deviceCountry != null) {
          Globals.selectedCountry = Globals.deviceCountry;
          AppLogger.log(
              '[AppInitializer] 🌍 No saved country found, using device country as default: ${Globals.deviceCountry}');
        }
      },
      'loadLocationState',
    );
  }

  /// Detect device country
  static Future<void> _detectDeviceCountry() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 🌍 Detecting device country...');

        try {
          // Try to load saved device country first
          final prefs = await SharedPreferences.getInstance();
          final savedDeviceCountry = prefs.getString('device_country');

          if (savedDeviceCountry != null) {
            Globals.deviceCountry = savedDeviceCountry;
            AppLogger.log(
                '[AppInitializer] 🌍 Loaded saved device country: ${Globals.deviceCountry}');
            return;
          }

          // Try to get device country from GPS
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            AppLogger.log(
                '[AppInitializer] 🔍 Location services disabled, using default device country');
            Globals.deviceCountry = 'Egypt';
            await prefs.setString('device_country', 'Egypt');
            return;
          }

          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            AppLogger.log(
                '[AppInitializer] 🔍 Location permission denied, using default device country');
            Globals.deviceCountry = 'Egypt';
            await prefs.setString('device_country', 'Egypt');
            return;
          }

          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(const Duration(seconds: 10));

          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            final detectedCountry = place.country ?? "Unknown";
            Globals.deviceCountry = _mapToSupportedCountry(detectedCountry);
            await prefs.setString('device_country', Globals.deviceCountry!);
          }
        } catch (e) {
          AppLogger.log(
              '[AppInitializer] ⚠️ Error detecting device country: $e');
          Globals.deviceCountry = 'Egypt';
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('device_country', 'Egypt');
        }
      },
      'detectDeviceCountry',
    );
  }

  /// Map detected country to supported country
  static String _mapToSupportedCountry(String detectedCountry) {
    switch (detectedCountry.toLowerCase()) {
      case 'saudi arabia':
        return 'Saudi Arabia';
      case 'egypt':
        return 'Egypt';
      case 'united arab emirates':
      case 'uae':
        return 'UAE';
      case 'kuwait':
        return 'Kuwait';
      case 'qatar':
        return 'Qatar';
      case 'bahrain':
        return 'Bahrain';
      case 'oman':
        return 'Oman';
      case 'jordan':
        return 'Jordan';
      case 'lebanon':
        return 'Lebanon';
      case 'syria':
        return 'Syria';
      case 'iraq':
        return 'Iraq';
      case 'yemen':
        return 'Yemen';
      case 'sudan':
        return 'Sudan';
      case 'libya':
        return 'Libya';
      case 'tunisia':
        return 'Tunisia';
      case 'algeria':
        return 'Algeria';
      case 'morocco':
        return 'Morocco';
      case 'palestine':
        return 'Palestine';
      case 'turkey':
        return 'Turkey';
      case 'iran':
        return 'Iran';
      case 'pakistan':
        return 'Pakistan';
      case 'india':
        return 'India';
      case 'bangladesh':
        return 'Bangladesh';
      case 'indonesia':
        return 'Indonesia';
      case 'malaysia':
        return 'Malaysia';
      case 'singapore':
        return 'Singapore';
      default:
        return 'Egypt';
    }
  }

  /// Initialize notification systems with duplicate prevention
  static Future<void> _initializeNotificationSystems() async {
    AppLogger.log('[AppInitializer] 🔔 Initializing notification systems...');

    await Future.wait([
      _initializePrayerScheduler(),
      _initializeReminderScheduler(),
    ]);

    // Prevent duplicate scheduling by checking existing notifications
    await _preventDuplicateScheduling();
  }

  /// Prevent duplicate notification scheduling
  static Future<void> _preventDuplicateScheduling() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[AppInitializer] 🔍 Checking for duplicate notifications...');

        // Get all pending notifications from reminder scheduler
        final reminderNotifications =
            await ReminderScheduler.getPendingReminders() ?? [];

        // Get prayer notifications by checking all pending notifications
        final allNotifications =
            await ReminderScheduler.getPendingReminders() ?? [];
        final prayerNotifications = allNotifications
            .where((n) => n.id >= 1001 && n.id <= 1005)
            .toList();

        // Check for duplicates and clean if necessary
        await _cleanDuplicateNotifications(
            prayerNotifications, reminderNotifications);

        AppLogger.log('[AppInitializer] ✅ Duplicate prevention completed');
      },
      'preventDuplicateScheduling',
    );
  }

  /// Clean duplicate notifications
  static Future<void> _cleanDuplicateNotifications(
    List<PendingNotificationRequest> prayerNotifications,
    List<PendingNotificationRequest> reminderNotifications,
  ) async {
    // Create sets of existing notification IDs
    final existingPrayerIds = prayerNotifications.map((n) => n.id).toSet();
    final existingReminderIds = reminderNotifications.map((n) => n.id).toSet();

    // Check if we have duplicates by comparing expected IDs
    final expectedPrayerIds = {
      1001, // Fajr
      1002, // Dhuhr
      1003, // Asr
      1004, // Maghrib
      1005, // Isha
    };

    final expectedReminderIds = {
      999997, // Morning Azkar
      999996, // Evening Azkar
      999995, // Sleeping Azkar
      999998, // Quran Reminder
    };

    // Log current state
    AppLogger.log(
        '[AppInitializer] Current prayer notifications: ${existingPrayerIds.join(', ')}');
    AppLogger.log(
        '[AppInitializer] Current reminder notifications: ${existingReminderIds.join(', ')}');

    // If we have all expected notifications, prevent rescheduling
    final hasAllPrayerNotifications =
        expectedPrayerIds.every((id) => existingPrayerIds.contains(id));
    final hasAllReminderNotifications =
        expectedReminderIds.every((id) => existingReminderIds.contains(id));

    if (hasAllPrayerNotifications && hasAllReminderNotifications) {
      AppLogger.log(
          '[AppInitializer] ✅ All notifications already scheduled, preventing duplicates');

      // Set flags to prevent rescheduling
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prayer_notifications_scheduled', true);
      await prefs.setBool('reminder_notifications_scheduled', true);
      await prefs.setBool('azkar_scheduled', true);
    } else {
      AppLogger.log(
          '[AppInitializer] 📅 Some notifications missing, allowing scheduling');

      // Log which notifications are missing
      final missingPrayerIds =
          expectedPrayerIds.where((id) => !existingPrayerIds.contains(id));
      final missingReminderIds =
          expectedReminderIds.where((id) => !existingReminderIds.contains(id));

      if (missingPrayerIds.isNotEmpty) {
        AppLogger.log(
            '[AppInitializer] Missing prayer notifications: ${missingPrayerIds.join(', ')}');
      }
      if (missingReminderIds.isNotEmpty) {
        AppLogger.log(
            '[AppInitializer] Missing reminder notifications: ${missingReminderIds.join(', ')}');
      }
    }
  }

  /// Initialize prayer scheduler
  static Future<void> _initializePrayerScheduler() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '🕌 [AppInitializer] Initializing prayer notification system...');
        AppLogger.log(
            '⏰ [AppInitializer] Timestamp: ${DateTime.now().toIso8601String()}');

        await UnifiedPrayerScheduler.initialize();
        AppLogger.log('✅ [AppInitializer] UnifiedPrayerScheduler initialized');

        AppLogger.log(
            '📅 [AppInitializer] Scheduling all prayers for today...');
        await UnifiedPrayerScheduler.scheduleAllPrayersForToday();

        AppLogger.log(
            '✅ [AppInitializer] Prayer scheduler initialization completed');
      },
      'initializePrayerScheduler',
    );
  }

  /// Initialize reminder scheduler
  static Future<void> _initializeReminderScheduler() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 📿 Initializing reminder scheduler...');
        await ReminderScheduler.initialize();
        await ReminderScheduler.scheduleAllDailyReminders();
      },
      'initializeReminderScheduler',
    );
  }

  /// Schedule startup tasks
  static Future<void> _scheduleStartupTasks() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[AppInitializer] 📅 Finalizing startup tasks...');

        // Print scheduled notifications
        await ReminderScheduler.printAllScheduledNotifications();

        // Check if notifications can be presented
        final canPresent =
            await ReminderScheduler.checkIfNotificationsAbleToPresent();
        AppLogger.log(
            '[AppInitializer] 🔔 Notifications can be presented: $canPresent');

        AppLogger.log(
            '[AppInitializer] ✅ All startup tasks completed successfully');
      },
      'scheduleStartupTasks',
    );
  }

  /// Check if app is initialized
  static bool get isInitialized => _isInitialized;

  /// Get initialization status
  static Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'errorCount': ErrorHandler.getErrorStats()['totalErrors'],
      'timezone': CentralizedTimezoneManager.getCurrentTimezone(),
      'permissions': CentralizedPermissionManager.getPermissionStatusSummary(),
    };
  }

  /// Reset initialization (for testing)
  static void reset() {
    _isInitialized = false;
    _initializationCallbacks.clear();
    AppLogger.log('[AppInitializer] Initialization reset');
  }
}
