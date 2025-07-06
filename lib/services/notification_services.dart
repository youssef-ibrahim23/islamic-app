// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/services/app_lunch_services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';
import 'package:islamic_app/globals.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    tzData.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(initSettings);
    await _requestPermissions();
    await _createNotificationChannels();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _createNotificationChannels() async {
    const prayerChannel = AndroidNotificationChannel(
      'prayer_channel',
      'Prayer Notifications',
      description: 'Channel for prayer time alerts',
      importance: Importance.max,
      enableVibration: true,
    );

    const scheduleChannel = AndroidNotificationChannel(
      'prayer_schedule_channel',
      'Prayer Time Scheduler',
      description: 'Channel for scheduling background prayer updates',
      importance: Importance.low,
    );

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(prayerChannel);
      await androidPlugin.createNotificationChannel(scheduleChannel);
    }
  }

  Future<void> showPrayerNotification(String title) async {
    final bool isEnglish = Globals.languageState ?? true;

    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Notifications',
      channelDescription: 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
    );

    await _notificationsPlugin.show(
      0,
      isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
      isEnglish ? 'It is time for $title prayer' : 'حان الآن وقت صلاة $title',
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> schedulePrayerNotification(String title, DateTime dateTime) async {
    final bool isEnglish = Globals.languageState ?? true;
    final tzTime = tz.TZDateTime.from(dateTime, tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final int notificationId = title.hashCode ^ dateTime.hashCode;

    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Notifications',
      channelDescription: 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
    );

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      isEnglish ? 'Prayer Reminder 🕌' : 'تنبيه للصلاة 🕌',
      isEnglish ? '$title prayer time' : 'موعد صلاة $title',
      tzTime,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'prayer_$title',
    );
  }

  Future<void> cancelAllPrayerNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleBackgroundTask(tz.TZDateTime time) async {
    final bool isEnglish = Globals.languageState ?? true;

    const androidDetails = AndroidNotificationDetails(
      'prayer_schedule_channel',
      'Prayer Time Scheduler',
      channelDescription: 'Channel for scheduling background prayer updates',
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
    );

    await _notificationsPlugin.zonedSchedule(
      999999,
      isEnglish ? '⏰ Updating Prayer Times' : '⏰ تحديث مواعيد الصلاة',
      isEnglish
          ? 'Prayer times are being updated automatically'
          : 'يتم الآن تحديث مواعيد الصلاة تلقائيًا',
      time,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'update_prayer',
    );

    final now = tz.TZDateTime.now(tz.local);
    final delay = time.difference(now);

    Future.delayed(delay, () async {
      await AppLaunchService.scheduleAllAzans();
      await AppLaunchService.scheduleMonthlyAzanUpdate();
    });
  }
}
