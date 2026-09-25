import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/globals.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_constants.dart';
import 'centralized_timezone_manager.dart';
import 'error_handler.dart';
import 'app_logger.dart';

/// Unified reminder scheduler for Azkar and Quran reminders
class ReminderScheduler {
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;
  static bool _isInitialized = false;

  // SharedPreferences keys for individual zikr tracking
  static const String morningAzkarKey = 'morning_azkar_scheduled';
  static const String eveningAzkarKey = 'evening_azkar_scheduled';
  static const String sleepingAzkarKey = 'sleeping_azkar_scheduled';
  static const String quranReminderKey = 'quran_reminder_scheduled';
  static const String surahKahfKey = 'surah_kahf_scheduled';

  /// Check if a specific reminder is scheduled
  static Future<bool> _isReminderScheduled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// Mark a specific reminder as scheduled
  static Future<void> _markReminderScheduled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  /// Clear scheduled flag for a specific reminder
  static Future<void> _clearReminderScheduled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, false);
  }

  /// Initialize the reminder scheduler
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      AppLogger.log('[ReminderScheduler] Initializing...');

      _notificationsPlugin = FlutterLocalNotificationsPlugin();
      final androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      final initSettings = InitializationSettings(android: androidInit);

      await _notificationsPlugin!.initialize(settings: initSettings);

      // Create reminder channels
      await _createReminderChannels();

      _isInitialized = true;
      AppLogger.log('[ReminderScheduler] Initialized successfully');
    } catch (e) {
      AppLogger.log('[ReminderScheduler] Error initializing: $e');
      throw Exception('Failed to initialize ReminderScheduler: $e');
    }
  }

  /// Create reminder notification channels
  static Future<void> _createReminderChannels() async {
    try {
      final androidPlugin = AndroidFlutterLocalNotificationsPlugin();

      final channels = [
        const AndroidNotificationChannel(
          NotificationConstants.azkarReminderChannel,
          NotificationConstants.azkarReminderChannelName,
          description: NotificationConstants.azkarReminderChannelDescription,
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
          ledColor: Color(0xFF0D47A1),
          enableLights: true,
          showBadge: true,
        ),
      ];

      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }

      AppLogger.log('[ReminderScheduler] Reminder channels created');
    } catch (e) {
      AppLogger.log('[ReminderScheduler] Error creating channels: $e');
    }
  }

  /// Clear all notification channels and cancel all notifications
  static Future<void> _clearAllNotifications() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[ReminderScheduler] Clearing all notifications...');

        // Cancel all pending notifications
        final pendingNotifications =
            await _notificationsPlugin?.pendingNotificationRequests() ?? [];
        for (final notification in pendingNotifications) {
          await _notificationsPlugin?.cancel(id: notification.id);
        }

        // Clear all scheduled notifications
        final scheduledNotifications = await getPendingReminders() ?? [];
        for (final notification in scheduledNotifications) {
          await _notificationsPlugin?.cancel(id: notification.id);
        }

        AppLogger.log('[ReminderScheduler] Cleared all notifications');
      },
      '_clearAllNotifications',
    );
  }

  /// Schedule all daily reminders with duplicate prevention
  static Future<void> scheduleAllDailyReminders({bool force = false}) async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[ReminderScheduler] Scheduling all daily reminders...');

        // Force schedule if requested, clear existing notifications
        if (force) {
          AppLogger.log(
              '[ReminderScheduler] Force mode: clearing existing notifications before fresh scheduling');
          await _clearAllNotifications();
          AppLogger.log(
              '[ReminderScheduler] Cleared all existing notifications');
        }

        // Schedule each zikr individually if not already scheduled (or force mode)
        await Future.wait([
          _scheduleIfNeeded(
            key: morningAzkarKey,
            id: NotificationConstants.morningAzkarId,
            scheduleFunction: scheduleMorningAzkarReminder,
            force: force,
          ),
          _scheduleIfNeeded(
            key: eveningAzkarKey,
            id: NotificationConstants.eveningAzkarId,
            scheduleFunction: scheduleEveningAzkarReminder,
            force: force,
          ),
          _scheduleIfNeeded(
            key: sleepingAzkarKey,
            id: NotificationConstants.sleepingAzkarId,
            scheduleFunction: scheduleSleepingAzkarReminder,
            force: force,
          ),
          _scheduleIfNeeded(
            key: quranReminderKey,
            id: NotificationConstants.quranReminderId,
            scheduleFunction: scheduleQuranReminder,
            force: force,
          ),
          _scheduleIfNeeded(
            key: surahKahfKey,
            id: NotificationConstants.surahKahfId,
            scheduleFunction: scheduleSurahKahfReminder,
            force: force,
          ),
        ]);

        AppLogger.log(
            '[ReminderScheduler] All daily reminders scheduled successfully');
      },
      'scheduleAllDailyReminders',
    );
  }

  /// Helper method to schedule a reminder if not already scheduled
  static Future<void> _scheduleIfNeeded({
    required String key,
    required int id,
    required Future<void> Function() scheduleFunction,
    required bool force,
  }) async {
    final isScheduled = await _isReminderScheduled(key);

    if (!force && isScheduled) {
      AppLogger.log('[ReminderScheduler] $key already scheduled, skipping');
      return;
    }

    // Check if notification actually exists in system
    final existingNotifications = await getPendingReminders() ?? [];
    final existingIds = existingNotifications.map((n) => n.id).toSet();

    if (!force && existingIds.contains(id)) {
      AppLogger.log(
          '[ReminderScheduler] $key notification exists, marking as scheduled');
      await _markReminderScheduled(key);
      return;
    }

    // Schedule the reminder
    await scheduleFunction();
    await _markReminderScheduled(key);
    AppLogger.log('[ReminderScheduler] $key scheduled and marked');
  }

  /// Schedule morning Azkar reminder
  static Future<void> scheduleMorningAzkarReminder() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[ReminderScheduler] Scheduling morning Azkar reminder...');

        final now = CentralizedTimezoneManager.getCurrentLocalTime();
        final scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          6, // 6:00 AM
          0,
        );

        // If time has passed, schedule for tomorrow
        final targetTime = scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime;

        await _notificationsPlugin?.zonedSchedule(
          id: NotificationConstants.morningAzkarId,
          title: Globals.languageState! ? 'Morning Azkar' : 'أذكار الصباح',
          body: Globals.languageState!
              ? 'Start your day with morning remembrance'
              : 'ابدأ يومك ب اذكار الصباح',
          scheduledDate: targetTime,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.azkarReminderChannel,
              'Morning Azkar',
              channelDescription: 'Daily morning Azkar reminder',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              styleInformation: BigTextStyleInformation(
                Globals.languageState!
                    ? 'Start your day with morning remembrance\n\n'
                        'Recite morning Azkar to begin your day with blessings and protection.'
                    : 'ابدأ يومك ب اذكار الصباح\n\n'
                        'اقرأ أذكار الصباح لبدء يومك بالبركات والحماية.',
              ),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        AppLogger.log(
            '[ReminderScheduler] Morning Azkar scheduled for $targetTime');
      },
      'scheduleMorningAzkarReminder',
    );
  }

  /// Schedule evening Azkar reminder
  static Future<void> scheduleEveningAzkarReminder() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[ReminderScheduler] Scheduling evening Azkar reminder...');

        final now = CentralizedTimezoneManager.getCurrentLocalTime();
        final scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          18, // 6:00 PM
          0,
        );

        // If time has passed, schedule for tomorrow
        final targetTime = scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime;

        await _notificationsPlugin?.zonedSchedule(
          id: NotificationConstants.eveningAzkarId,
          title: Globals.languageState! ? 'Evening Azkar' : 'أذكار المساء',
          body: Globals.languageState!
              ? 'End your day with evening remembrance'
              : 'انهي يومك ب اذكار المساء',
          scheduledDate: targetTime,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.azkarReminderChannel,
              'Evening Azkar',
              channelDescription: 'Daily evening Azkar reminder',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              styleInformation: BigTextStyleInformation(
                Globals.languageState!
                    ? 'End your day with evening remembrance\n\n'
                        'Recite evening Azkar to seek protection and blessings for the night.'
                    : 'انهي يومك ب اذكار المساء\n\n'
                        'اقرأ أذكار المساء لطلب الحماية والبركات للّيل.',
              ),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        AppLogger.log(
            '[ReminderScheduler] Evening Azkar scheduled for $targetTime');
      },
      'scheduleEveningAzkarReminder',
    );
  }

  /// Schedule sleeping Azkar reminder
  static Future<void> scheduleSleepingAzkarReminder() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[ReminderScheduler] Scheduling sleeping Azkar reminder...');

        final now = CentralizedTimezoneManager.getCurrentLocalTime();
        final scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          23, // 11:00 PM
          0,
        );

        // If time has passed, schedule for tomorrow
        final targetTime = scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime;

        await _notificationsPlugin?.zonedSchedule(
          id: NotificationConstants.sleepingAzkarId,
          title: Globals.languageState! ? 'Sleeping Azkar' : 'أذكار النوم',
          body: Globals.languageState!
              ? 'Before you sleep, remember Allah'
              : 'قبل النوم، تذكر الله',
          scheduledDate: targetTime,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.azkarReminderChannel,
              'Sleeping Azkar',
              channelDescription: 'Daily sleeping Azkar reminder',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              styleInformation: BigTextStyleInformation(
                Globals.languageState!
                    ? 'Before you sleep, remember Allah\n\n'
                        'Recite sleeping Azkar for protection and peaceful sleep.'
                    : 'قبل النوم، تذكر الله\n\n'
                        'اقرأ أذكار النوم للحماية والنوم الهانئ.',
              ),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        AppLogger.log(
            '[ReminderScheduler] Sleeping Azkar scheduled for $targetTime');
      },
      'scheduleSleepingAzkarReminder',
    );
  }

  /// Schedule Quran reminder
  static Future<void> scheduleQuranReminder() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[ReminderScheduler] Scheduling Quran reminder...');

        final now = CentralizedTimezoneManager.getCurrentLocalTime();
        final scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          16, // 4:00 PM
          0, // 0 minutes
        );

        // If time has passed, schedule for tomorrow
        final targetTime = scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime;

        await _notificationsPlugin?.zonedSchedule(
          id: NotificationConstants.quranReminderId,
          title: Globals.languageState!
              ? 'Quran & Azkar Time'
              : 'وقت القرآن والأذكار',
          body: Globals.languageState!
              ? 'Take time to read Quran and recite your daily azkar'
              : 'خذ وقتًا لقراءة القرآن وذكر الله',
          scheduledDate: targetTime,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.azkarReminderChannel,
              'Quran & Azkar Reminder',
              channelDescription: 'Daily Quran reading and azkar reminder',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              styleInformation: BigTextStyleInformation(
                Globals.languageState!
                    ? 'Take time to read the Holy Quran and recite your daily azkar\n\n'
                        'Set aside time for daily Quran reading, reflection, and remembrance of Allah.'
                    : 'خذ وقتًا لقراءة القرآن الكريم وذكر الله\n\n'
                        'خصص وقتًا لقراءة القرآن اليومي والتفكر وذكر الله.',
              ),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        AppLogger.log(
            '[ReminderScheduler] Quran reminder scheduled for $targetTime');
      },
      'scheduleQuranReminder',
    );
  }

  /// Schedule Surah Al-Kahf reminder for Friday at 10:00 AM
  static Future<void> scheduleSurahKahfReminder() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[ReminderScheduler] Scheduling Surah Al-Kahf reminder...');

        final now = CentralizedTimezoneManager.getCurrentLocalTime();

        // Calculate days until next Friday (5 = Friday)
        int daysUntilFriday = (DateTime.friday - now.weekday) % 7;
        if (daysUntilFriday == 0 && now.hour >= 10) {
          // If today is Friday and past 10 AM, schedule for next Friday
          daysUntilFriday = 7;
        }

        final scheduledTime = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + daysUntilFriday,
          10, // 10:00 AM
          0,
        );

        await _notificationsPlugin?.zonedSchedule(
          id: NotificationConstants.surahKahfId,
          title: Globals.languageState!
              ? 'Surah Al-Kahf Reminder'
              : 'تذكير سورة الكهف',
          body: Globals.languageState!
              ? 'It is Friday! Time to read Surah Al-Kahf'
              : 'اليوم الجمعة! وقت قراءة سورة الكهف',
          scheduledDate: scheduledTime,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              NotificationConstants.azkarReminderChannel,
              'Surah Al-Kahf Reminder',
              channelDescription:
                  'Weekly Friday reminder to read Surah Al-Kahf',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              largeIcon:
                  const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              styleInformation: BigTextStyleInformation(
                Globals.languageState!
                    ? 'It is Friday! Time to read Surah Al-Kahf\n\n'
                        'Reading Surah Al-Kahf on Friday brings light and blessings until the next Friday.'
                    : 'اليوم الجمعة! وقت قراءة سورة الكهف\n\n'
                        'قراءة سورة الكهف يوم الجمعة تجلب النور والبركات حتى الجمعة القادمة.',
              ),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exact,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );

        AppLogger.log(
            '[ReminderScheduler] Surah Al-Kahf scheduled for $scheduledTime');
      },
      'scheduleSurahKahfReminder',
    );
  }

  /// Cancel all reminder notifications
  static Future<void> cancelAllReminders() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[ReminderScheduler] Cancelling all reminders...');

        final reminderIds = [
          NotificationConstants.morningAzkarId,
          NotificationConstants.eveningAzkarId,
          NotificationConstants.sleepingAzkarId,
          NotificationConstants.quranReminderId,
          NotificationConstants.surahKahfId,
        ];

        for (final id in reminderIds) {
          await _notificationsPlugin?.cancel(id: id);
        }

        // Reset all individual scheduled flags
        await _clearReminderScheduled(morningAzkarKey);
        await _clearReminderScheduled(eveningAzkarKey);
        await _clearReminderScheduled(sleepingAzkarKey);
        await _clearReminderScheduled(quranReminderKey);
        await _clearReminderScheduled(surahKahfKey);

        // Also clear legacy key for backward compatibility
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('azkar_scheduled', false);

        AppLogger.log('[ReminderScheduler] All reminders cancelled');
      },
      'cancelAllReminders',
    );
  }

  /// Get all pending reminder notifications
  static Future<List<PendingNotificationRequest>?> getPendingReminders() async {
    return await ErrorHandler.safeExecute<List<PendingNotificationRequest>>(
      () async {
        final notifications =
            await _notificationsPlugin?.pendingNotificationRequests() ?? [];
        final reminderNotifications = notifications.where((notification) {
          return [
            NotificationConstants.morningAzkarId,
            NotificationConstants.eveningAzkarId,
            NotificationConstants.sleepingAzkarId,
            NotificationConstants.quranReminderId,
            NotificationConstants.surahKahfId,
          ].contains(notification.id);
        }).toList();

        AppLogger.log(
            '[ReminderScheduler] Found ${reminderNotifications.length} pending reminders');
        return reminderNotifications;
      },
      'getPendingReminders',
      defaultValue: <PendingNotificationRequest>[],
    );
  }

  /// Check if notifications can be presented
  static Future<bool?> checkIfNotificationsAbleToPresent() async {
    return await ErrorHandler.safeExecute<bool>(
      () async {
        final notifications =
            await _notificationsPlugin?.pendingNotificationRequests() ?? [];
        final canPresent = notifications.isNotEmpty;
        AppLogger.log(
            '[ReminderScheduler] Notifications can be presented: $canPresent');
        return canPresent;
      },
      'checkIfNotificationsAbleToPresent',
      defaultValue: false,
    );
  }

  /// Print all scheduled notifications
  static Future<void> printAllScheduledNotifications() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log(
            '[ReminderScheduler] Checking all scheduled notifications...');

        final notifications =
            await _notificationsPlugin?.pendingNotificationRequests() ?? [];

        if (notifications.isEmpty) {
          AppLogger.log('[ReminderScheduler] No scheduled notifications found');
          return;
        }

        AppLogger.log(
            '[ReminderScheduler] Found ${notifications.length} scheduled notifications:');

        for (final notification in notifications) {
          AppLogger.log(
              '[ReminderScheduler] - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
        }
      },
      'printAllScheduledNotifications',
    );
  }

  /// Reschedule all reminders (force new scheduling)
  static Future<void> rescheduleAllReminders() async {
    await ErrorHandler.safeExecute(
      () async {
        AppLogger.log('[ReminderScheduler] Rescheduling all reminders...');

        // Cancel existing reminders
        await cancelAllReminders();

        // Schedule new reminders (with force=true to bypass existing check)
        await scheduleAllDailyReminders(force: true);

        AppLogger.log(
            '[ReminderScheduler] All reminders rescheduled successfully');
      },
      'rescheduleAllReminders',
    );
  }
}
