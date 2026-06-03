import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/services/error_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_constants.dart';
import 'prayer_time_calculation_service.dart';
import 'app_logger.dart';
import '../globals.dart';
import 'dart:async';

/// Unified prayer scheduling service using only Flutter
class UnifiedPrayerScheduler {
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;
  static bool _isInitialized = false;
  static Timer? _backgroundSchedulerTimer;
  static Timer? _midnightTimer;
  static const Duration _backgroundCheckInterval =
      Duration(minutes: 30); // Check every 30 minutes
  static const Duration _autoScheduleDelay =
      Duration(minutes: 5); // Auto-schedule 5 minutes after prayer

  static int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  static int _dateKey(DateTime date) {
    // Fits in <= 39966 (year 0-99 * 400 + dayOfYear 1-366)
    return (date.year % 100) * 400 + _dayOfYear(date);
  }

  /// Initialize the unified scheduler
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    final androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin!.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationReceived,
    );

    // Create all prayer channels
    await _createPrayerChannels();

    // Start background scheduler
    _startBackgroundScheduler();

    // Start midnight timer for daily reset
    _startMidnightTimer();

    _isInitialized = true;
    AppLogger.log('[UnifiedPrayerScheduler] Initialized successfully');
  }

  /// Create prayer notification channels
  static Future<void> _createPrayerChannels() async {
    try {
      final androidPlugin = AndroidFlutterLocalNotificationsPlugin();

      final prayerChannel = const AndroidNotificationChannel(
        NotificationConstants.prayerChannel,
        NotificationConstants.prayerChannelName,
        description: NotificationConstants.prayerChannelDescription,
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        ledColor: Color(0xFF0D47A1),
        enableLights: true,
        showBadge: true,
      );

      await androidPlugin.createNotificationChannel(prayerChannel);
      AppLogger.log('[UnifiedPrayerScheduler] Prayer channel created');
    } catch (e) {
      AppLogger.log('[UnifiedPrayerScheduler] Error creating channels: $e');
    }
  }

  /// Background notification receiver (handles both taps and auto-triggers)
  static void _onNotificationReceived(NotificationResponse response) async {
    AppLogger.log(
        '[UnifiedPrayerScheduler] Notification received: ${response.payload}');

    if (response.payload?.startsWith('prayer_') == true) {
      final prayerName = response.payload!.replaceFirst('prayer_', '');
      AppLogger.log(
          '[UnifiedPrayerScheduler] Prayer notification: $prayerName');

      // Schedule next prayer automatically (no user interaction needed)
      await _scheduleNextPrayerAutomatically(prayerName);
    }
  }

  /// Schedule next prayer automatically without user interaction
  static Future<void> _scheduleNextPrayerAutomatically(
      String currentPrayer) async {
    try {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Auto-scheduling next prayer after $currentPrayer');

      // Wait a bit to ensure prayer time has passed
      await Future.delayed(const Duration(seconds: 30));

      final success = await scheduleNextPrayerOnly();

      if (success) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Next prayer auto-scheduled successfully');
      } else {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Failed to auto-schedule next prayer');
        // Fallback: schedule all remaining prayers for today
        await _scheduleRemainingPrayersForToday();
      }
    } catch (e) {
      AppLogger.log('[UnifiedPrayerScheduler] Error in auto-scheduling: $e');
    }
  }

  /// Start background scheduler for continuous monitoring
  static void _startBackgroundScheduler() {
    _backgroundSchedulerTimer?.cancel();
    _backgroundSchedulerTimer =
        Timer.periodic(_backgroundCheckInterval, (timer) async {
      await _backgroundScheduleCheck();
    });
    AppLogger.log(
        '[UnifiedPrayerScheduler] Background scheduler started (checks every ${_backgroundCheckInterval.inMinutes} minutes)');
  }

  /// Background schedule check to ensure no prayers are missed
  static Future<void> _backgroundScheduleCheck() async {
    try {
      AppLogger.log('[UnifiedPrayerScheduler] Background schedule check...');

      final pendingPrayers = await getPendingPrayers();
      final nextPrayer = await PrayerTimeCalculationService.getNextPrayer();

      if (nextPrayer == null) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] No next prayer found, scheduling tomorrow\'s prayers');
        final isEnglish = Globals.languageState ?? true;
        await _scheduleTomorrowPrayers(isEnglish, force: true);
        return;
      }

      // Check if next prayer is already scheduled (using unique ID logic)
      final nextPrayerId =
          _generateUniquePrayerId(nextPrayer.key, date: nextPrayer.value);
      final isNextPrayerScheduled =
          pendingPrayers.any((p) => p.id == nextPrayerId);

      if (!isNextPrayerScheduled) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Next prayer not scheduled, scheduling now: ${nextPrayer.key}');
        final isEnglish = Globals.languageState ?? true;
        final ok =
            await _schedulePrayer(nextPrayer.key, nextPrayer.value, isEnglish);
        if (ok) {
          AppLogger.log(
              '[UnifiedPrayerScheduler] Successfully scheduled ${nextPrayer.key}');
        } else {
          AppLogger.log(
              '[UnifiedPrayerScheduler] Failed to schedule ${nextPrayer.key}');
        }
      } else {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Next prayer already scheduled: ${nextPrayer.key} (ID: $nextPrayerId)');
      }

      // Check if we need to schedule tomorrow\'s early prayers
      await _checkAndScheduleTomorrowEarlyPrayers();
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Background schedule check failed: $e');
    }
  }

  /// Check and schedule tomorrow\'s early prayers if today\'s have passed
  static Future<void> _checkAndScheduleTomorrowEarlyPrayers() async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final todayPrayers =
          await PrayerTimeCalculationService.getTodayPrayerTimesMap();

      if (todayPrayers == null) return;

      final fajrPassed = todayPrayers['Fajr']?.isBefore(now) ?? false;
      final dhuhrPassed = todayPrayers['Dhuhr']?.isBefore(now) ?? false;

      if (fajrPassed || dhuhrPassed) {
        final pendingPrayers = await getPendingPrayers();
        final isEnglish = Globals.languageState ?? true;

        // Check if tomorrow\'s fajr is already scheduled (using unique ID)
        if (fajrPassed) {
          final tomorrowFajrTime = await _getTomorrowPrayerTime('Fajr');
          if (tomorrowFajrTime != null) {
            final tomorrowFajrId =
                _generateUniquePrayerId('Fajr', date: tomorrowFajrTime);
            final isTomorrowFajrScheduled =
                pendingPrayers.any((p) => p.id == tomorrowFajrId);

            if (!isTomorrowFajrScheduled) {
              final ok =
                  await _schedulePrayer('Fajr', tomorrowFajrTime, isEnglish);
              if (ok) {
                AppLogger.log(
                    '[UnifiedPrayerScheduler] Scheduled tomorrow\'s Fajr (today\'s passed)');
              }
            }
          }
        }

        // Check if tomorrow\'s dhuhr is already scheduled (using unique ID)
        if (dhuhrPassed) {
          final tomorrowDhuhrTime = await _getTomorrowPrayerTime('Dhuhr');
          if (tomorrowDhuhrTime != null) {
            final tomorrowDhuhrId =
                _generateUniquePrayerId('Dhuhr', date: tomorrowDhuhrTime);
            final isTomorrowDhuhrScheduled =
                pendingPrayers.any((p) => p.id == tomorrowDhuhrId);

            if (!isTomorrowDhuhrScheduled) {
              final ok =
                  await _schedulePrayer('Dhuhr', tomorrowDhuhrTime, isEnglish);
              if (ok) {
                AppLogger.log(
                    '[UnifiedPrayerScheduler] Scheduled tomorrow\'s Dhuhr (today\'s passed)');
              }
            }
          }
        }
      }
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error checking tomorrow\'s early prayers: $e');
    }
  }

  /// Helper method to get tomorrow's prayer time
  static Future<tz.TZDateTime?> _getTomorrowPrayerTime(
      String prayerName) async {
    try {
      final tomorrowPrayerTimes =
          await PrayerTimeCalculationService.calculateTomorrowPrayerTimes();
      if (tomorrowPrayerTimes == null) return null;

      switch (prayerName) {
        case 'Fajr':
          return tz.TZDateTime.from(tomorrowPrayerTimes.fajr, tz.local);
        case 'Dhuhr':
          return tz.TZDateTime.from(tomorrowPrayerTimes.dhuhr, tz.local);
        case 'Asr':
          return tz.TZDateTime.from(tomorrowPrayerTimes.asr, tz.local);
        case 'Maghrib':
          return tz.TZDateTime.from(tomorrowPrayerTimes.maghrib, tz.local);
        case 'Isha':
          return tz.TZDateTime.from(tomorrowPrayerTimes.isha, tz.local);
        default:
          return null;
      }
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error getting tomorrow\'s $prayerName time: $e');
      return null;
    }
  }

  /// Start midnight timer for daily reset
  static void _startMidnightTimer() {
    _midnightTimer?.cancel();
    _midnightTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await _midnightCheck();
    });
    AppLogger.log(
        '[UnifiedPrayerScheduler] Midnight timer started (checks every hour)');
  }

  /// Midnight check to handle daily reset
  static Future<void> _midnightCheck() async {
    try {
      final now = tz.TZDateTime.now(tz.local);

      // Check if it\'s midnight (between 12:00 AM and 12:05 AM)
      if (now.hour == 0 && now.minute <= 5) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Midnight detected, performing daily reset...');

        // Clear cache for new day
        PrayerTimeCalculationService.clearCache();

        // Schedule all prayers for the new day
        await scheduleAllPrayersForToday();
      }
    } catch (e) {
      AppLogger.log('[UnifiedPrayerScheduler] Midnight check failed: $e');
    }
  }

  /// Schedule remaining prayers for today (fallback method)
  static Future<void> _scheduleRemainingPrayersForToday() async {
    try {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Scheduling remaining prayers for today (fallback)');

      final prayerTimes =
          await PrayerTimeCalculationService.getTodayPrayerTimesMap();
      if (prayerTimes == null) return;

      final now = tz.TZDateTime.now(tz.local);
      final isEnglish = Globals.languageState ?? true;
      int scheduledCount = 0;

      for (final prayerName in NotificationConstants.orderedPrayers) {
        final prayerTime = prayerTimes[prayerName];
        if (prayerTime != null && prayerTime.isAfter(now)) {
          final ok = await _schedulePrayer(prayerName, prayerTime, isEnglish);
          if (ok) {
            scheduledCount++;
          }
        }
      }

      AppLogger.log(
          '[UnifiedPrayerScheduler] Fallback scheduled $scheduledCount remaining prayers');
    } catch (e) {
      AppLogger.log('[UnifiedPrayerScheduler] Fallback scheduling failed: $e');
    }
  }

  /// Schedule tomorrow\'s Fajr only
  static Future<void> _scheduleTomorrowFajr(bool isEnglish) async {
    try {
      final tomorrowPrayerTimes =
          await PrayerTimeCalculationService.calculateTomorrowPrayerTimes();
      if (tomorrowPrayerTimes == null) return;

      final fajrTime = tz.TZDateTime.from(tomorrowPrayerTimes.fajr, tz.local);
      final ok = await _schedulePrayer('Fajr', fajrTime, isEnglish);
      if (ok) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Scheduled tomorrow\'s Fajr at $fajrTime');
      }
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error scheduling tomorrow\'s Fajr: $e');
    }
  }

  /// Schedule tomorrow\'s Dhuhr only
  static Future<void> _scheduleTomorrowDhuhr(bool isEnglish) async {
    try {
      final tomorrowPrayerTimes =
          await PrayerTimeCalculationService.calculateTomorrowPrayerTimes();
      if (tomorrowPrayerTimes == null) return;

      final dhuhrTime = tz.TZDateTime.from(tomorrowPrayerTimes.dhuhr, tz.local);
      final ok = await _schedulePrayer('Dhuhr', dhuhrTime, isEnglish);
      if (ok) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Scheduled tomorrow\'s Dhuhr at $dhuhrTime');
      }
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error scheduling tomorrow\'s Dhuhr: $e');
    }
  }

  /// Cleanup method to stop all timers
  static void cleanup() {
    _backgroundSchedulerTimer?.cancel();
    _midnightTimer?.cancel();
    _backgroundSchedulerTimer = null;
    _midnightTimer = null;
    AppLogger.log('[UnifiedPrayerScheduler] Cleanup completed');
  }

  static Future<void> _scheduleTomorrowPrayers(bool isEnglish,
      {bool force = false}) async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Scheduling tomorrow prayers...');

        final tomorrowPrayerTimes =
            await PrayerTimeCalculationService.calculateTomorrowPrayerTimes();
        if (tomorrowPrayerTimes == null) {
          AppLogger.log(
              '[UnifiedPrayerScheduler] No tomorrow prayer times available');
          return;
        }

        // Convert PrayerTimes to Map<String, tz.TZDateTime>
        final tomorrowPrayerTimesMap = <String, tz.TZDateTime>{
          'Fajr': tz.TZDateTime.from(tomorrowPrayerTimes.fajr, tz.local),
          'Dhuhr': tz.TZDateTime.from(tomorrowPrayerTimes.dhuhr, tz.local),
          'Asr': tz.TZDateTime.from(tomorrowPrayerTimes.asr, tz.local),
          'Maghrib': tz.TZDateTime.from(tomorrowPrayerTimes.maghrib, tz.local),
          'Isha': tz.TZDateTime.from(tomorrowPrayerTimes.isha, tz.local),
        };

        // Get pending notifications to check for duplicates (only if not forcing)
        final pendingPrayers = force ? [] : (await getPendingPrayers() ?? []);

        int tomorrowScheduledCount = 0;

        // Schedule each prayer for tomorrow
        for (final prayerName in NotificationConstants.orderedPrayers) {
          final prayerTime = tomorrowPrayerTimesMap[prayerName];
          if (prayerTime != null) {
            final ok = await _schedulePrayer(prayerName, prayerTime, isEnglish);
            if (ok) {
              tomorrowScheduledCount++;
              AppLogger.log(
                  '[UnifiedPrayerScheduler] Scheduled tomorrow\'s $prayerName at $prayerTime');
            }
          }
        }

        AppLogger.log(
            '[UnifiedPrayerScheduler] Tomorrow\'s prayers scheduled: $tomorrowScheduledCount');
      },
      '_scheduleTomorrowPrayers',
    );
  }

  /// Smart scheduling - handles all scenarios intelligently with duplicate prevention
  static Future<bool> scheduleAllPrayersForToday() async {
    try {
      AppLogger.log(
          ' [UnifiedPrayerScheduler] Starting SMART prayer scheduling...');

      final isEnglish = Globals.languageState!;
      final now = tz.TZDateTime.now(tz.local);

      // Check for existing notifications to prevent duplicates
      final existingNotifications = await getPendingNotifications() ?? [];
      final expectedPrayerIds = {
        1001, // Fajr
        1002, // Dhuhr
        1003, // Asr
        1004, // Maghrib
        1005, // Isha
      };

      final existingIds = existingNotifications.map((n) => n.id).toSet();
      final hasAllPrayers =
          expectedPrayerIds.every((id) => existingIds.contains(id));

      if (hasAllPrayers) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] All prayer notifications already exist, preventing duplicates');

        // Set flag to prevent rescheduling
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('prayer_notifications_scheduled', true);

        return true;
      }

      final prayerTimes =
          await PrayerTimeCalculationService.getTodayPrayerTimesMap();
      if (prayerTimes == null) {
        AppLogger.log(' [UnifiedPrayerScheduler] No prayer times available');
        return false;
      }

      int scheduledCount = 0;
      int skippedCount = 0;
      final List<String> passedPrayers = [];

      // Schedule today's remaining prayers
      for (final prayerName in NotificationConstants.orderedPrayers) {
        final prayerId =
            NotificationConstants.generatePrayerNotificationId(prayerName);
        final prayerTime = prayerTimes[prayerName];

        if (prayerTime != null && prayerTime.isAfter(now)) {
          // Only schedule if not already exists
          if (!existingIds.contains(prayerId)) {
            final ok = await _schedulePrayer(prayerName, prayerTime, isEnglish);
            if (ok) {
              scheduledCount++;
              AppLogger.log(
                  ' [UnifiedPrayerScheduler] ✅ Scheduled $prayerName at $prayerTime');
            } else {
              skippedCount++;
              AppLogger.log(
                  ' [UnifiedPrayerScheduler] ❌ Failed to schedule $prayerName at $prayerTime');
            }
          } else {
            AppLogger.log(
                '[UnifiedPrayerScheduler] ⏭️ $prayerName already scheduled, skipping');
          }
        } else if (prayerTime != null) {
          passedPrayers.add(prayerName);
          skippedCount++;
          AppLogger.log(
              ' [UnifiedPrayerScheduler] ⏭️ Skipped $prayerName - already passed ($prayerTime)');
        } else {
          skippedCount++;
          AppLogger.log(
              ' [UnifiedPrayerScheduler] ❌ No time found for $prayerName');
        }
      }

      // Smart tomorrow scheduling based on passed prayers
      await _smartTomorrowScheduling(passedPrayers, isEnglish);

      // Set flag after successful scheduling
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prayer_notifications_scheduled', true);

      AppLogger.log(' [UnifiedPrayerScheduler] SMART scheduling completed!');
      AppLogger.log(
          ' [UnifiedPrayerScheduler] 📊 Results: Scheduled=$scheduledCount, Skipped=$skippedCount, Passed=${passedPrayers.length}');

      // Print detailed schedule summary
      await _printScheduleSummary(prayerTimes, now);

      return true;
    } catch (e) {
      AppLogger.log(' [UnifiedPrayerScheduler] Error in SMART scheduling: $e');
      return false;
    }
  }

  /// Check if prayers are already properly scheduled for today
  static Future<bool> _checkIfPrayersAlreadyScheduled(
      Map<String, tz.TZDateTime> prayerTimes, tz.TZDateTime now) async {
    try {
      AppLogger.log(
          ' [UnifiedPrayerScheduler] 🔍 Checking if prayers are already scheduled...');

      final pendingNotifications =
          await _notificationsPlugin!.pendingNotificationRequests();
      int correctSchedules = 0;
      int totalExpected = 0;

      for (final prayerName in NotificationConstants.orderedPrayers) {
        final prayerTime = prayerTimes[prayerName];
        if (prayerTime == null) continue;

        // Only check future prayers for today
        if (prayerTime.isAfter(now) && _isSameDay(prayerTime, now)) {
          totalExpected++;
          // Use the same ID generation logic as actual scheduling
          final notificationId =
              _generateUniquePrayerId(prayerName, date: prayerTime);

          // Look for matching notification
          bool found = false;
          for (final notification in pendingNotifications) {
            if (notification.id == notificationId) {
              found = true;
              correctSchedules++;
              AppLogger.log(
                  ' [UnifiedPrayerScheduler] ✅ $prayerName already scheduled (ID: $notificationId)');
              break;
            }
          }

          if (!found) {
            AppLogger.log(
                ' [UnifiedPrayerScheduler] ❌ $prayerName not found in scheduled notifications (ID: $notificationId)');
          }
        }
      }

      AppLogger.log(
          ' [UnifiedPrayerScheduler] 📊 Schedule check: $correctSchedules/$totalExpected prayers correctly scheduled');

      // Consider it "already scheduled" if at least 80% of expected prayers are correctly scheduled
      final threshold = (totalExpected * 0.8).ceil();
      final isAlreadyScheduled =
          totalExpected > 0 && correctSchedules >= threshold;

      if (isAlreadyScheduled) {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] ✅ Prayer schedule is optimal (threshold: $threshold)');
      } else {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] 🔄 Prayer schedule needs updating (threshold: $threshold)');
      }

      return isAlreadyScheduled;
    } catch (e) {
      AppLogger.log(
          ' [UnifiedPrayerScheduler] Error checking existing schedules: $e');
      return false; // On error, proceed with rescheduling
    }
  }

  /// Check if two dates are the same day
  static bool _isSameDay(tz.TZDateTime date1, tz.TZDateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Smart tomorrow scheduling based on which prayers have passed today
  static Future<void> _smartTomorrowScheduling(
      List<String> passedPrayers, bool isEnglish) async {
    try {
      AppLogger.log(
          ' [UnifiedPrayerScheduler] Smart tomorrow scheduling for passed prayers: $passedPrayers');

      if (passedPrayers.isEmpty) {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] No prayers passed today, no tomorrow scheduling needed');
        return;
      }

      // If all prayers passed, schedule all tomorrow's prayers
      if (passedPrayers.length == 5) {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] All prayers passed today, scheduling all tomorrow prayers...');
        await _scheduleTomorrowPrayers(isEnglish, force: true);
        return;
      }

      // Schedule specific tomorrow prayers based on what passed today
      if (passedPrayers.contains('Fajr')) {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] Fajr passed today, scheduling tomorrow Fajr...');
        await _scheduleTomorrowFajr(isEnglish);
      }

      if (passedPrayers.contains('Dhuhr')) {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] Dhuhr passed today, scheduling tomorrow Dhuhr...');
        await _scheduleTomorrowDhuhr(isEnglish);
      }

      // If evening prayers passed, schedule all tomorrow prayers (we're late in the day)
      if (passedPrayers.contains('Maghrib') || passedPrayers.contains('Isha')) {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] Evening prayers passed, scheduling all tomorrow prayers...');
        await _scheduleTomorrowPrayers(isEnglish, force: true);
      }
    } catch (e) {
      AppLogger.log(
          ' [UnifiedPrayerScheduler] Error in smart tomorrow scheduling: $e');
    }
  }

  /// Print detailed schedule summary
  static Future<void> _printScheduleSummary(
      Map<String, tz.TZDateTime> prayerTimes, tz.TZDateTime now) async {
    AppLogger.log(' [UnifiedPrayerScheduler] Detailed Schedule Summary:');
    for (final prayerName in NotificationConstants.orderedPrayers) {
      final prayerTime = prayerTimes[prayerName];
      if (prayerTime != null) {
        AppLogger.log(
            ' [UnifiedPrayerScheduler] $prayerName: $prayerTime (${prayerTime.difference(now).inMinutes} minutes from now)');
      } else {
        AppLogger.log(' [UnifiedPrayerScheduler] $prayerName: No time found');
      }
    }
  }

  /// Generate unique notification ID for prayer (prevents duplicates)
  static int _generateUniquePrayerId(String prayerName, {DateTime? date}) {
    // Must fit signed 32-bit int (Android requirement)
    // We encode (baseId * 100000) + dateKey where dateKey <= 39966.
    // Example: baseId=1001, dateKey=... => ~100,139,966 which is safe.
    final baseId =
        NotificationConstants.generatePrayerNotificationId(prayerName);
    if (date == null) return baseId;
    return baseId * 100000 + _dateKey(date);
  }

  /// Cancel existing prayer notification before scheduling new one
  static Future<void> _cancelExistingPrayerNotification(String prayerName,
      {DateTime? date}) async {
    try {
      final notificationId = _generateUniquePrayerId(prayerName, date: date);
      await _notificationsPlugin?.cancel(id: notificationId);
      AppLogger.log(
          '[UnifiedPrayerScheduler] Cancelled existing notification for $prayerName (ID: $notificationId)');
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error cancelling $prayerName notification: $e');
    }
  }

  /// Schedule a single prayer (duplicate-safe)
  static Future<bool> _schedulePrayer(
      String prayerName, tz.TZDateTime prayerTime, bool isEnglish) async {
    try {
      final prayerDisplayName =
          NotificationConstants.getPrayerDisplayName(prayerName, isEnglish);

      // Generate unique ID for this specific prayer time
      final notificationId =
          _generateUniquePrayerId(prayerName, date: prayerTime);

      AppLogger.log(
          '⏰ [UnifiedPrayerScheduler] Scheduling $prayerName ($prayerDisplayName)...');
      AppLogger.log('📅 [UnifiedPrayerScheduler] Prayer time: $prayerTime');
      AppLogger.log(
          '🔔 [UnifiedPrayerScheduler] Notification ID: $notificationId');

      // Cancel any existing notification for this prayer to prevent duplicates
      await _cancelExistingPrayerNotification(prayerName, date: prayerTime);

      // Android notification details
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

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentSound: true,
        sound: 'azan.mp3',
        categoryIdentifier: 'prayer_category',
        threadIdentifier: 'prayer_notifications',
      );

      await _notificationsPlugin!.zonedSchedule(
        id: notificationId,
        title: isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
        body: isEnglish
            ? 'It is time for $prayerDisplayName prayer'
            : 'حان الآن وقت صلاة $prayerDisplayName',
        scheduledDate: prayerTime,
        notificationDetails:
            NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.exact,
        payload: 'prayer_$prayerName',
      );

      final now = tz.TZDateTime.now(tz.local);
      final minutesUntil = prayerTime.difference(now).inMinutes;

      AppLogger.log(
          '✅ [UnifiedPrayerScheduler] Successfully scheduled $prayerName!');
      AppLogger.log(
          '⏱️ [UnifiedPrayerScheduler] Time until prayer: $minutesUntil minutes');
      AppLogger.log(
          '🔄 [UnifiedPrayerScheduler] One-time scheduling: Dynamic prayer times');
      AppLogger.log('📱 [UnifiedPrayerScheduler] Payload: prayer_$prayerName');

      return true;
    } catch (e) {
      AppLogger.log(
          '❌ [UnifiedPrayerScheduler] Error scheduling $prayerName: $e');
      return false;
    }
  }

  /// Schedule next prayer only (for immediate scheduling)
  static Future<bool> scheduleNextPrayerOnly() async {
    try {
      AppLogger.log('[UnifiedPrayerScheduler] Scheduling next prayer only');

      final nextPrayer = await PrayerTimeCalculationService.getNextPrayer();
      if (nextPrayer == null) {
        AppLogger.log('[UnifiedPrayerScheduler] No next prayer found');
        return false;
      }

      final isEnglish = Globals.languageState ?? true;
      await _schedulePrayer(nextPrayer.key, nextPrayer.value, isEnglish);

      AppLogger.log(
          '[UnifiedPrayerScheduler] Next prayer scheduled: ${nextPrayer.key} at ${nextPrayer.value}');
      return true;
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error scheduling next prayer: $e');
      return false;
    }
  }

  /// Get all pending notifications
  static Future<List<PendingNotificationRequest>?>
      getPendingNotifications() async {
    try {
      final notifications =
          await _notificationsPlugin?.pendingNotificationRequests() ?? [];
      return notifications;
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error getting pending notifications: $e');
      return null;
    }
  }

  /// Get all pending prayer notifications
  static Future<List<PendingNotificationRequest>?>
      getPendingPrayerNotifications() async {
    try {
      final allNotifications = await getPendingNotifications() ?? [];
      final prayerNotifications = allNotifications.where((notification) {
        return notification.id >= 1001 && notification.id <= 1005;
      }).toList();
      return prayerNotifications;
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error getting pending prayer notifications: $e');
      return null;
    }
  }

  /// Cancel all prayers
  static Future<void> cancelAllPrayers() async {
    try {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Cancelling all prayer notifications...');

      final prayerIds = [1001, 1002, 1003, 1004, 1005];

      for (final id in prayerIds) {
        await _notificationsPlugin?.cancel(id: id);
      }

      AppLogger.log(
          '[UnifiedPrayerScheduler] All prayer notifications cancelled');
    } catch (e) {
      AppLogger.log('[UnifiedPrayerScheduler] Error cancelling prayers: $e');
    }
  }

  /// Get all pending prayer notifications (enhanced filtering)
  static Future<List<PendingNotificationRequest>> getPendingPrayers() async {
    try {
      final notifications =
          await _notificationsPlugin?.pendingNotificationRequests() ?? [];
      final prayerNotifications = notifications
          .where((n) => n.payload?.startsWith('prayer_') == true)
          .toList();

      AppLogger.log(
          '[UnifiedPrayerScheduler] Found ${prayerNotifications.length} pending prayer notifications');

      // Log details for debugging
      for (final notification in prayerNotifications) {
        AppLogger.log(
            '[UnifiedPrayerScheduler] Pending: ID=${notification.id}, Payload=${notification.payload}');
      }

      return prayerNotifications;
    } catch (e) {
      AppLogger.log(
          '[UnifiedPrayerScheduler] Error getting pending prayers: $e');
      return [];
    }
  }
}
