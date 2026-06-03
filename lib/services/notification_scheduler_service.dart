// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_logger.dart';
import 'permission_manager.dart';
import 'prayer_time_calculation_service.dart';
import 'notification_constants.dart';
import '../globals.dart';

class NotificationSchedulerService {
  static const String _nextPrayerKey = 'next_prayer_scheduled';
  static const String _lastScheduleKey = 'last_schedule_time';
  static int _permissionRetryCount = 0;
  static const int _maxPermissionRetries = 2;

  static FlutterLocalNotificationsPlugin? _notificationsPlugin;
  static bool _isInitialized = false;
  static bool _methodChannelSetup = false;

  /// Initialize the scheduler service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    AppLogger.log('[NotificationSchedulerService] Initializing...');

    // Initialize notification plugin
    _notificationsPlugin ??= FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin!.initialize(settings: initSettings);

    // Initialize PermissionManager
    await PermissionManager.initialize(_notificationsPlugin!);

    // Setup method channel for native communication
    _setupMethodChannel();

    _isInitialized = true;
    AppLogger.log('[NotificationSchedulerService] Initialized successfully');
  }

  /// Setup method channel for native communication
  static void _setupMethodChannel() {
    if (_methodChannelSetup) return;

    try {
      const channel = MethodChannel('com.youssef.islamic_app/autoschedule');
      channel.setMethodCallHandler((call) async {
        AppLogger.log(
            '📡 [NotificationSchedulerService] Native method call received: ${call.method}');

        final timestamp = DateTime.now().toIso8601String();
        AppLogger.log(
            '⏰ [NotificationSchedulerService] Call timestamp: $timestamp');

        switch (call.method) {
          case 'scheduleNextPrayer':
            final prayerName = call.arguments as String? ?? 'Unknown';
            AppLogger.log(
                '🔄 [NotificationSchedulerService] AUTO-SCHEDULING TRIGGERED!');
            AppLogger.log(
                '🕌 [NotificationSchedulerService] Prayer from native: $prayerName');
            AppLogger.log(
                '📱 [NotificationSchedulerService] Source: Native AutoScheduleReceiver');
            AppLogger.log(
                '🎯 [NotificationSchedulerService] Action: Re-scheduling next prayer');

            final success = await scheduleNextPrayer();

            if (success) {
              AppLogger.log(
                  '✅ [NotificationSchedulerService] Auto-scheduling completed successfully');
            } else {
              AppLogger.log(
                  '❌ [NotificationSchedulerService] Auto-scheduling failed');
            }

            return success ? 'Success' : 'Failed';

          default:
            AppLogger.log(
                '⚠️ [NotificationSchedulerService] Unknown method: ${call.method}');
            throw PlatformException(
              code: 'Unimplemented',
              details: 'Method ${call.method} not implemented',
            );
        }
      });

      _methodChannelSetup = true;
      AppLogger.log(
          '✅ [NotificationSchedulerService] Method channel setup completed');
      AppLogger.log(
          '📡 [NotificationSchedulerService] Channel: com.youssef.islamic_app/autoschedule');
    } catch (e) {
      AppLogger.log(
          '❌ [NotificationSchedulerService] Error setting up method channel: $e');
    }
  }

  /// Schedule the next prayer only (single alarm strategy)
  static Future<bool> scheduleNextPrayer() async {
    try {
      AppLogger.log(
          '🎯 [NotificationSchedulerService] Starting next prayer scheduling...');
      AppLogger.log(
          '⏰ [NotificationSchedulerService] Timestamp: ${DateTime.now().toIso8601String()}');

      // Reset retry counter at the start of each scheduling attempt
      _permissionRetryCount = 0;
      AppLogger.log(
          '🔄 [NotificationSchedulerService] Permission retry counter reset');

      // Check permissions first
      final hasPermissions =
          await PermissionManager.areAllCriticalPermissionsGranted();
      if (!hasPermissions) {
        AppLogger.log(
            '❌ [NotificationSchedulerService] Critical permissions not granted');
        AppLogger.log(
            '🔐 [NotificationSchedulerService] Requesting permissions...');
        await _requestPermissionsAndRetry();
        return false;
      }
      AppLogger.log(
          '✅ [NotificationSchedulerService] All critical permissions granted');

      // Skip test notifications in production mode
      AppLogger.log(
          '🚫 [NotificationSchedulerService] Production mode: Skipping test notifications');

      // Get next prayer
      AppLogger.log('🔍 [NotificationSchedulerService] Getting next prayer...');
      final nextPrayer = await PrayerTimeCalculationService.getNextPrayer();
      if (nextPrayer == null) {
        AppLogger.log('❌ [NotificationSchedulerService] No next prayer found');
        return false;
      }

      // Extract prayer name and display name safely
      final prayerName = nextPrayer.key;
      final isEnglish = Globals.languageState ?? true;
      final prayerDisplayName =
          NotificationConstants.getPrayerDisplayName(prayerName, isEnglish);
      final prayerTime = nextPrayer.value;

      AppLogger.log(
          '🕌 [NotificationSchedulerService] Next prayer: $prayerName ($prayerDisplayName)');
      AppLogger.log(
          '📅 [NotificationSchedulerService] Prayer time: $prayerTime');
      AppLogger.log(
          '🌍 [NotificationSchedulerService] Language: ${isEnglish ? "English" : "Arabic"}');

      // Cancel any existing alarm
      AppLogger.log(
          '🗑️ [NotificationSchedulerService] Canceling existing alarms...');
      await _cancelNextPrayerAlarm();

      // Schedule the new alarm
      AppLogger.log(
          '⏰ [NotificationSchedulerService] Scheduling new prayer alarm...');
      final success =
          await _schedulePrayerAlarm(nextPrayer.key, nextPrayer.value);

      if (success) {
        // Save to preferences
        AppLogger.log(
            '💾 [NotificationSchedulerService] Saving scheduling state...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_nextPrayerKey, nextPrayer.key);
        await prefs.setString(
            _lastScheduleKey, DateTime.now().toIso8601String());

        final now = DateTime.now();
        final minutesUntil = prayerTime.difference(now).inMinutes;

        AppLogger.log(
            '✅ [NotificationSchedulerService] Next prayer scheduled successfully!');
        AppLogger.log(
            '🕌 [NotificationSchedulerService] Prayer: ${nextPrayer.key} ($prayerDisplayName)');
        AppLogger.log(
            '📅 [NotificationSchedulerService] Time: ${nextPrayer.value}');
        AppLogger.log(
            '⏱️ [NotificationSchedulerService] Time until prayer: $minutesUntil minutes');
        AppLogger.log('📱 [NotificationSchedulerService] Saved to preferences');
        AppLogger.log(
            '🔄 [NotificationSchedulerService] Auto-scheduling: ARMED');
      } else {
        AppLogger.log(
            '❌ [NotificationSchedulerService] Failed to schedule prayer alarm');
      }

      return success;
    } catch (e) {
      AppLogger.log(
          '❌ [NotificationSchedulerService] Error scheduling next prayer: $e');
      AppLogger.log(
          '📍 [NotificationSchedulerService] Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Schedule test notifications for debugging - DISABLED IN PRODUCTION
  static Future<void> _scheduleTestNotifications() async {
    // Test notifications disabled in production mode
    AppLogger.log(
        '🚫 [NotificationSchedulerService] Test notifications disabled in production');
    return;
  }

  /// Schedule a test prayer alarm - DISABLED IN PRODUCTION
  static Future<void> _scheduleTestPrayerAlarm(
      String prayerName, DateTime prayerTime, int notificationId) async {
    // Test prayer alarms disabled in production mode
    AppLogger.log(
        '🚫 [NotificationSchedulerService] Test prayer alarms disabled in production');
    return;
  }

  /// Schedule a specific prayer alarm
  static Future<bool> _schedulePrayerAlarm(
      String prayerName, tz.TZDateTime prayerTime) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      if (prayerTime.isBefore(now)) {
        AppLogger.log(
            '[NotificationSchedulerService] Prayer time is in the past: $prayerTime');
        return false;
      }

      final isEnglish = Globals.languageState ?? true;
      final prayerDisplayName =
          PrayerTimeCalculationService.getPrayerName(prayerName);

      // Determine schedule mode based on permission
      AndroidScheduleMode scheduleMode;
      final hasExactPermission =
          await PermissionManager.hasExactAlarmPermission();

      if (hasExactPermission) {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
        AppLogger.log(
            '[NotificationSchedulerService] Using exact alarm for $prayerDisplayName');
      } else {
        scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
        AppLogger.log(
            '[NotificationSchedulerService] Using inexact alarm for $prayerDisplayName (permission denied)');
      }

      final androidDetails = AndroidNotificationDetails(
        NotificationConstants.prayerChannel,
        NotificationConstants.prayerChannelName,
        channelDescription: NotificationConstants.prayerChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('azan'),
        autoCancel: true,
        color: const Color(0xFF0D47A1),
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          isEnglish
              ? 'It is time for $prayerDisplayName prayer'
              : 'حان الآن وقت صلاة $prayerDisplayName',
          contentTitle: isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
          htmlFormatBigText: true,
          summaryText: isEnglish ? 'Tap to open app' : 'انقر لفتح التطبيق',
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentSound: true,
        sound: 'azan.mp3',
        categoryIdentifier: 'prayer_category',
        threadIdentifier: 'prayer_notifications',
      );

      await _notificationsPlugin?.zonedSchedule(
        id: NotificationConstants.nextPrayerNotificationId,
        title: isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
        body: isEnglish
            ? 'It is time for $prayerDisplayName prayer'
            : 'حان الآن وقت صلاة $prayerDisplayName',
        scheduledDate: prayerTime,
        notificationDetails:
            NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: scheduleMode,
        payload: 'prayer_$prayerName',
      );

      AppLogger.log(
          '[NotificationSchedulerService] Prayer alarm scheduled: $prayerDisplayName at $prayerTime');

      // CRITICAL: Schedule auto-next-prayer alarm 5 minutes after current prayer
      await _scheduleAutoNextPrayerAlarm(prayerTime, prayerName);

      return true;
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Error scheduling prayer alarm: $e');
      return false;
    }
  }

  /// Schedule automatic next prayer alarm (works even if user doesn't tap)
  static Future<void> _scheduleAutoNextPrayerAlarm(
      tz.TZDateTime currentPrayerTime, String currentPrayerName) async {
    try {
      AppLogger.log(
          '[NotificationSchedulerService] Scheduling auto-next-prayer alarm...');

      // Get actual prayer times to determine next prayer accurately
      final prayerTimes =
          await PrayerTimeCalculationService.getTodayPrayerTimesMap();
      final nextPrayerTime = getNextPrayerTime(prayerTimes, currentPrayerName);

      AppLogger.log(
          '[NotificationSchedulerService] Scheduling auto-next-prayer at $nextPrayerTime');

      // Schedule auto-schedule using native AlarmManager
      final platform = MethodChannel('com.youssef.islamic_app.autoschedule');
      await platform.invokeMethod('scheduleAutoSchedule', {
        'triggerTime': nextPrayerTime.millisecondsSinceEpoch,
        'prayerName':
            getNextPrayerName(prayerTimes), // Use prayer times for accuracy
      });

      AppLogger.log(
          '[NotificationSchedulerService] Auto-next-prayer alarm scheduled successfully');
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Error scheduling auto-next-prayer alarm: $e');
    }
  }

  /// Get next prayer time based on current prayer
  static tz.TZDateTime getNextPrayerTime(
      Map<String, tz.TZDateTime>? prayerTimes, String currentPrayerName) {
    if (prayerTimes == null) {
      // Fallback to current time + 5 minutes
      return tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5));
    }

    final now = tz.TZDateTime.now(tz.local);
    AppLogger.log(
        '🔍 [NotificationSchedulerService] Getting next prayer after: $currentPrayerName');
    AppLogger.log('⏰ [NotificationSchedulerService] Current time: $now');

    switch (currentPrayerName) {
      case 'Fajr':
        final dhuhr = prayerTimes['Dhuhr'];
        AppLogger.log(
            '☀️ [NotificationSchedulerService] Next: Dhuhr at $dhuhr');
        return dhuhr ?? now.add(const Duration(hours: 5));
      case 'Dhuhr':
        final asr = prayerTimes['Asr'];
        AppLogger.log('🌤️ [NotificationSchedulerService] Next: Asr at $asr');
        return asr ?? now.add(const Duration(hours: 3));
      case 'Asr':
        final maghrib = prayerTimes['Maghrib'];
        AppLogger.log(
            '🌇 [NotificationSchedulerService] Next: Maghrib at $maghrib');
        return maghrib ?? now.add(const Duration(hours: 2));
      case 'Maghrib':
        final isha = prayerTimes['Isha'];
        AppLogger.log('🌙 [NotificationSchedulerService] Next: Isha at $isha');
        return isha ?? now.add(const Duration(hours: 2));
      case 'Isha':
        // After Isha, next is TOMORROW's Fajr
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowFajr = tz.TZDateTime(
          tz.local,
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          prayerTimes['Fajr']?.hour ?? 5,
          prayerTimes['Fajr']?.minute ?? 0,
          prayerTimes['Fajr']?.second ?? 0,
        );
        AppLogger.log(
            ' [NotificationSchedulerService] Next: TOMORROW Fajr at $tomorrowFajr');
        return tomorrowFajr;
      default:
        AppLogger.log(
            ' [NotificationSchedulerService] Unknown prayer: $currentPrayerName, using fallback');
        return now.add(const Duration(minutes: 5));
    }
  }

  /// Get next prayer name for auto-scheduling
  static String getNextPrayerName(Map<String, tz.TZDateTime>? prayerTimes) {
    if (prayerTimes == null || prayerTimes.isEmpty) {
      return NotificationConstants.getNextPrayerByHour();
    }

    final now = tz.TZDateTime.now(tz.local);
    MapEntry<String, tz.TZDateTime>? nextPrayer;

    for (final prayer in NotificationConstants.orderedPrayers) {
      final time = prayerTimes[prayer];
      if (time != null && time.isAfter(now)) {
        if (nextPrayer == null || time.isBefore(nextPrayer.value)) {
          nextPrayer = MapEntry(prayer, time);
        }
      }
    }

    // If all prayers passed → tomorrow Fajr
    if (nextPrayer == null) {
      return 'Fajr';
    }

    return nextPrayer.key;
  }

  /// Cancel the next prayer alarm
  static Future<void> _cancelNextPrayerAlarm() async {
    try {
      // Cancel main prayer alarm
      await _notificationsPlugin?.cancel(
          id: NotificationConstants.nextPrayerNotificationId);

      // Cancel auto-schedule alarm using AlarmManager
      try {
        final platform = MethodChannel('com.youssef.islamic_app.autoschedule');
        await platform.invokeMethod('cancelAutoSchedule');
      } catch (e) {
        AppLogger.log(
            '[NotificationSchedulerService] Error canceling auto-schedule alarm: $e');
      }

      AppLogger.log(
          '[NotificationSchedulerService] Next prayer alarms cancelled (main + auto-schedule)');
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Error cancelling next prayer alarm: $e');
    }
  }

  /// Reschedule after notification fires (chain scheduling)
  static Future<void> onPrayerNotificationFired(String prayerName) async {
    AppLogger.log(
        '[NotificationSchedulerService] Prayer notification fired: $prayerName');

    // Schedule the next prayer
    await scheduleNextPrayer();
  }

  /// Request permissions and retry scheduling
  static Future<void> _requestPermissionsAndRetry() async {
    AppLogger.log('[NotificationSchedulerService] Requesting permissions...');

    _permissionRetryCount++;
    if (_permissionRetryCount > _maxPermissionRetries) {
      AppLogger.log(
          '[NotificationSchedulerService] Max permission retries reached, skipping retry');
      _permissionRetryCount = 0; // Reset counter
      return;
    }

    final status = await PermissionManager.checkAndRequestAllPermissions();
    if (status == PermissionStatus.granted) {
      AppLogger.log(
          '[NotificationSchedulerService] Permissions granted, retrying schedule...');
      _permissionRetryCount = 0; // Reset counter on success
      await scheduleNextPrayer();
    } else {
      AppLogger.log(
          '[NotificationSchedulerService] Permissions denied, using fallback');
      // Could implement fallback logic here
    }
  }

  /// Handle notification response (when user taps)
  static void _handleNotificationResponse(NotificationResponse response) {
    AppLogger.log(
        '[NotificationSchedulerService] Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Handle background notification response
  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationResponse(
      NotificationResponse response) {
    AppLogger.log(
        '[NotificationSchedulerService] Background notification: ${response.payload}');

    // If this is a prayer notification, schedule the next one
    if (response.payload?.startsWith('prayer_') == true) {
      final prayerName = response.payload!.replaceFirst('prayer_', '');
      _scheduleNextPrayerInBackground(prayerName);
    }
  }

  /// Schedule next prayer in background (isolate-safe)
  static Future<void> _scheduleNextPrayerInBackground(String prayerName) async {
    try {
      // Initialize minimal services needed for background scheduling
      await PrayerTimeCalculationService.initializeTimezone();

      // Schedule next prayer
      await scheduleNextPrayer();

      AppLogger.log(
          '[NotificationSchedulerService] Next prayer scheduled from background');
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Error scheduling from background: $e');
    }
  }

  /// Reschedule on app boot
  static Future<void> rescheduleOnBoot() async {
    AppLogger.log('[NotificationSchedulerService] Rescheduling on boot...');

    try {
      // Initialize services
      await initialize();
      await PrayerTimeCalculationService.initializeTimezone();

      // Schedule next prayer
      await scheduleNextPrayer();

      AppLogger.log(
          '[NotificationSchedulerService] Boot rescheduling completed');
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Boot rescheduling failed: $e');
    }
  }

  /// Reschedule on timezone change
  static Future<void> rescheduleOnTimezoneChange() async {
    AppLogger.log(
        '[NotificationSchedulerService] Rescheduling on timezone change...');

    try {
      // Clear cached prayer times
      PrayerTimeCalculationService.clearCache();

      // Reinitialize timezone
      await PrayerTimeCalculationService.initializeTimezone();

      // Reschedule next prayer
      await scheduleNextPrayer();

      AppLogger.log(
          '[NotificationSchedulerService] Timezone change rescheduling completed');
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Timezone change rescheduling failed: $e');
    }
  }

  /// Get scheduled alarm info
  static Future<Map<String, dynamic>?> getScheduledAlarmInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nextPrayerData = prefs.getString(_nextPrayerKey);

      if (nextPrayerData == null) return null;

      final parts = nextPrayerData.split('|');
      if (parts.length != 2) return null;

      return {
        'prayerName': parts[0],
        'scheduledTime':
            DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1])),
      };
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Error getting scheduled alarm info: $e');
      return null;
    }
  }

  /// Check if alarm is scheduled
  static Future<bool> isAlarmScheduled() async {
    final info = await getScheduledAlarmInfo();
    return info != null;
  }

  /// Cancel all alarms (for testing/reset)
  static Future<void> cancelAllAlarms() async {
    try {
      await _cancelNextPrayerAlarm();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_nextPrayerKey);
      await prefs.remove(_lastScheduleKey);

      AppLogger.log('[NotificationSchedulerService] All alarms cancelled');
    } catch (e) {
      AppLogger.log(
          '[NotificationSchedulerService] Error cancelling all alarms: $e');
    }
  }
}
