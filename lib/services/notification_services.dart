// ignore_for_file: deprecated_member_use, library_prefixes

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/models/Azkar.dart';
import 'package:islamic_app/screens/azkar.dart';
import 'package:islamic_app/screens/prayer_times.dart';
import 'package:islamic_app/screens/surahs_list.dart';
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

  // Notification channels
  static const String _prayerChannelId = 'prayer_channel';
  static const String scheduleChannelId = 'prayer_schedule_channel';
  static const String quranChannelId = 'quran_reminder_channel';
  static const String azkarChannelId = 'azkar_reminder_channel';

  // Notification IDs
  static const int backgroundTaskId = 999999;
  static const int quranReminderId = 999998;
  static const int morningAzkarId = 999997;
  static const int eveningAzkarId = 999996;

  Future<void> init() async {
    tzData.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
  requestSoundPermission: true,
  requestAlertPermission: true,
  requestBadgePermission: true,
  notificationCategories: [
    DarwinNotificationCategory(
      'prayer_category',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('snooze_id', 'Snooze'),
        DarwinNotificationAction.plain('open_app_id', 'Open App'),
      ],
    ),
    DarwinNotificationCategory(
      'azkar_category',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('open_app_id', 'Open App'),
        DarwinNotificationAction.plain('read_now_id', 'Read Now'),
      ],
    ),
  ],
);

final initSettings = InitializationSettings(
  android: androidInit,
  iOS: iosInit,
);


    await _notificationsPlugin.initialize(
  initSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) {
    final payload = response.payload ?? '';

    if (payload.startsWith('prayer_')) {
      Globals.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
      );
    } else if (payload == 'quran_reminder') {
      Globals.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const QuranPage()),
      );
    } else if (payload == 'morning_azkar' || payload == 'evening_azkar') {
      Globals.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const AzkarPage()),
      );
    }
  },
);
    
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
          ?.requestPermissions(alert: true, badge: true, sound: false);
    }
  }

  Future<void> _createNotificationChannels() async {
    const prayerChannel = AndroidNotificationChannel(
      _prayerChannelId,
      'Prayer Notifications',
      description: 'Channel for prayer time alerts',
      importance: Importance.max,
      enableVibration: true,
      sound: null,
      ledColor: Color(0xFF0D47A1),
      enableLights: true,
    );

    const scheduleChannel = AndroidNotificationChannel(
      scheduleChannelId,
      'Prayer Time Scheduler',
      description: 'Channel for scheduling background prayer updates',
      importance: Importance.low,
    );

    const quranChannel = AndroidNotificationChannel(
      quranChannelId,
      'Quran Reminders',
      description: 'Channel for daily Quran reading reminders',
      importance: Importance.high,
      enableVibration: true,
      sound: null,
    );

    const azkarChannel = AndroidNotificationChannel(
      azkarChannelId,
      'Azkar Reminders',
      description: 'Channel for morning and evening azkar reminders',
      importance: Importance.high,
      enableVibration: true,
      sound: null,
      ledColor: Color(0xFF4CAF50),
      enableLights: true,
    );

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(prayerChannel);
      await androidPlugin.createNotificationChannel(scheduleChannel);
      await androidPlugin.createNotificationChannel(quranChannel);
      await androidPlugin.createNotificationChannel(azkarChannel);
    }
  }

  Future<void> showPrayerNotification(String title, {String? customBody}) async {
    final bool isEnglish = Globals.languageState ?? true;

    final androidDetails = AndroidNotificationDetails(
      _prayerChannelId,
      'Prayer Notifications',
      channelDescription: 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      sound: null,
      autoCancel: true,
      color: const Color(0xFF0D47A1),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        customBody ?? (isEnglish ? 'It is time for $title prayer' : 'حان الآن وقت صلاة $title'),
        contentTitle: isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
        htmlFormatBigText: true,
        summaryText: isEnglish ? 'Tap to open app' : 'انقر لفتح التطبيق',
      ),
      actions: [
        const AndroidNotificationAction(
          'snooze_id',
          'Snooze',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'open_app_id',
          'Open App',
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      sound: null,
      categoryIdentifier: 'prayer_category',
      threadIdentifier: 'prayer_notifications',
    );

    await _notificationsPlugin.show(
      title.hashCode,
      isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
      customBody ?? (isEnglish ? 'It is time for $title prayer' : 'حان الآن وقت صلاة $title'),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'prayer_$title',
    );
  }

  Future<void> schedulePrayerNotification(String title, DateTime dateTime, 
      {String? customBody}) async {
    final bool isEnglish = Globals.languageState ?? true;
    final tzTime = tz.TZDateTime.from(dateTime, tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final int notificationId = title.hashCode ^ dateTime.hashCode;

    final androidDetails = AndroidNotificationDetails(
      _prayerChannelId,
      'Prayer Notifications',
      channelDescription: 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      sound: null,
      autoCancel: true,
      color: const Color(0xFF0D47A1),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        customBody ?? (isEnglish ? '$title prayer time' : 'موعد صلاة $title'),
        contentTitle: isEnglish ? 'Prayer Reminder 🕌' : 'تنبيه للصلاة 🕌',
        htmlFormatBigText: true,
        summaryText: isEnglish ? 'Tap to open app' : 'انقر لفتح التطبيق',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      sound:  null,
      categoryIdentifier: 'prayer_category',
      threadIdentifier: 'prayer_notifications',
    );

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      isEnglish ? 'Prayer Reminder 🕌' : 'تنبيه للصلاة 🕌',
      customBody ?? (isEnglish ? '$title prayer time' : 'موعد صلاة $title'),
      tzTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'prayer_$title',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyQuranReminder(TimeOfDay time, {String? customMessage}) async {
    final bool isEnglish = Globals.languageState ?? true;
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      quranChannelId,
      'Quran Reminders',
      channelDescription: 'Channel for daily Quran reading reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      sound: null,
      autoCancel: true,
      color: const Color(0xFF4CAF50),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        customMessage ?? (isEnglish 
          ? 'Take a moment to read Quran today and gain blessings' 
          : 'خذ لحظة لقراءة القرآن اليوم واكتساب البركات'),
        contentTitle: isEnglish ? 'Quran Reminder 📖' : 'تذكير القرآن 📖',
        htmlFormatBigText: true,
        summaryText: isEnglish ? 'Tap to open app' : 'انقر لفتح التطبيق',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      sound: null,
      threadIdentifier: 'quran_reminders',
    );

    await _notificationsPlugin.zonedSchedule(
      quranReminderId,
      isEnglish ? 'Quran Reminder 📖' : 'تذكير القرآن 📖',
      customMessage ?? (isEnglish 
        ? 'Take a moment to read Quran today and gain blessings' 
        : 'خذ لحظة لقراءة القرآن اليوم واكتساب البركات'),
      tzTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'quran_reminder',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyAzkarReminders() async {
    // Schedule morning azkar at sunrise (adjust time as needed)
    const morningTime = TimeOfDay(hour: 6, minute: 0);
    await scheduleAzkarReminder(
      id: morningAzkarId,
      time: morningTime,
      isMorning: true,
    );

    // Schedule evening azkar at sunset (adjust time as needed)
    const eveningTime = TimeOfDay(hour: 18, minute: 0);
    await scheduleAzkarReminder(
      id: eveningAzkarId,
      time: eveningTime,
      isMorning: false,
    );
  }

  Future<void> scheduleAzkarReminder({
    required int id,
    required TimeOfDay time,
    required bool isMorning,
  }) async {
    final bool isEnglish = Globals.languageState ?? true;
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final title = isMorning 
        ? (isEnglish ? 'Morning Azkar 🌅' : 'أذكار الصباح 🌅')
        : (isEnglish ? 'Evening Azkar 🌇' : 'أذكار المساء 🌇');

    final body = isMorning
        ? (isEnglish 
            ? 'Start your day with remembrance of Allah. Read your morning azkar now.'
            : 'ابدأ يومك بذكر الله. اقرأ أذكار الصباح الآن.')
        : (isEnglish
            ? 'End your day with remembrance of Allah. Read your evening azkar now.'
            : 'اختم يومك بذكر الله. اقرأ أذكار المساء الآن.');

    final androidDetails = AndroidNotificationDetails(
      azkarChannelId,
      'Azkar Reminders',
      channelDescription: 'Channel for morning and evening azkar reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      sound: null,
      autoCancel: true,
      color: const Color(0xFF4CAF50),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatBigText: true,
        summaryText: isEnglish ? 'Tap to open app' : 'انقر لفتح التطبيق',
      ),
      actions: [
        const AndroidNotificationAction(
          'read_now_id',
          'Read Now',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        const AndroidNotificationAction(
          'open_app_id',
          'Open App',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      sound: null,
      categoryIdentifier: 'azkar_category',
      threadIdentifier: 'azkar_reminders',
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: isMorning ? 'morning_azkar' : 'evening_azkar',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showRichAzkarNotification({
    required bool isMorning,
    String? customTitle,
    String? customBody,
    String? customPayload,
  }) async {
    final bool isEnglish = Globals.languageState ?? true;

    final title = customTitle ?? 
        (isMorning 
            ? (isEnglish ? 'Morning Azkar 🌅' : 'أذكار الصباح 🌅')
            : (isEnglish ? 'Evening Azkar 🌇' : 'أذكار المساء 🌇'));

    final body = customBody ??
        (isMorning
            ? (isEnglish 
                ? 'Start your day with remembrance of Allah. Read your morning azkar now.'
                : 'ابدأ يومك بذكر الله. اقرأ أذكار الصباح الآن.')
            : (isEnglish
                ? 'End your day with remembrance of Allah. Read your evening azkar now.'
                : 'اختم يومك بذكر الله. اقرأ أذكار المساء الآن.'));

    final payload = customPayload ?? (isMorning ? 'morning_azkar' : 'evening_azkar');

    final androidDetails = AndroidNotificationDetails(
      azkarChannelId,
      'Azkar Reminders',
      channelDescription: 'Channel for morning and evening azkar reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      sound: null,
      autoCancel: true,
      color: const Color(0xFF4CAF50),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatBigText: true,
        summaryText: isEnglish ? 'Tap to open app' : 'انقر لفتح التطبيق',
      ),
      actions: [
        const AndroidNotificationAction(
          'read_now_id',
          'Read Now',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        const AndroidNotificationAction(
          'open_app_id',
          'Open App',
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      sound: null,
      categoryIdentifier: 'azkar_category',
      threadIdentifier: 'azkar_reminders',
    );

    await _notificationsPlugin.show(
      isMorning ? morningAzkarId : eveningAzkarId,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  Future<void> cancelAllPrayerNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelQuranReminder() async {
    await _notificationsPlugin.cancel(quranReminderId);
  }

  Future<void> cancelAzkarReminders() async {
    await _notificationsPlugin.cancel(morningAzkarId);
    await _notificationsPlugin.cancel(eveningAzkarId);
  }

  Future<void> scheduleBackgroundTask(tz.TZDateTime time) async {
    final bool isEnglish = Globals.languageState ?? true;

    const androidDetails = AndroidNotificationDetails(
      scheduleChannelId,
      'Prayer Time Scheduler',
      channelDescription: 'Channel for scheduling background prayer updates',
      importance: Importance.low,
      priority: Priority.low,
      playSound: false,
      ongoing: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      threadIdentifier: 'prayer_scheduler',
    );

    await _notificationsPlugin.zonedSchedule(
      backgroundTaskId,
      isEnglish ? '⏰ Updating Prayer Times' : '⏰ تحديث مواعيد الصلاة',
      isEnglish
          ? 'Prayer times are being updated automatically'
          : 'يتم الآن تحديث مواعيد الصلاة تلقائيًا',
      time,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
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

  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? channelId,
    String? channelName,
    String? channelDescription,
    String? payload,
    Color? color,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _prayerChannelId,
      channelName ?? 'Prayer Notifications',
      channelDescription: channelDescription ?? 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      sound: null,
      autoCancel: true,
      color: color ?? const Color(0xFF0D47A1),
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        htmlFormatBigText: true,
        summaryText: 'Tap to open app',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      sound: null,
    );

    await _notificationsPlugin.show(
      title.hashCode,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}