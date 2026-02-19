// ignore_for_file: deprecated_member_use, library_prefixes

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/screens/azkar.dart';
import 'package:islamic_app/screens/prayer_times.dart';
import 'package:islamic_app/screens/surahs_list.dart';
import 'package:islamic_app/services/app_lunch_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';
import 'package:islamic_app/globals.dart';

enum AzkarType { morning, evening, sleeping }

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
  static const int sleepingAzkarId = 999995;

  Future<void> init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool isInitialized = sharedPreferences.getBool("isInitialized") ?? false;
    if (isInitialized) {
      print(
          "[NotificationService] init() skipped: already initialized (isInitialized=true)");
      return;
    }

    print("[NotificationService] init() starting...");

    tzData.initializeTimeZones();

    print(
        "[NotificationService] Timezones initialized. tz.local=${tz.local.name}");

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

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response);
      },
    );

    print("[NotificationService] Plugin initialized.");

    await _requestPermissions();
    await _createNotificationChannels();

    await sharedPreferences.setBool("isInitialized", true);

    print("Notification system initialized.");
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final payload = response.payload ?? '';
    final navigator = Globals.navigatorKey.currentState;

    if (navigator == null) return;

    // Handle general tap (no action ID)
    if (payload.startsWith('prayer_')) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
      );
    } else if (payload == 'quran_reminder') {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const QuranPage()),
      );
    } else if (payload == 'morning_azkar' ||
        payload == 'evening_azkar' ||
        payload == 'sleeping_azkar') {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const AzkarPage()),
      );
    }
  }

  Future<void> _requestPermissions() async {
    print("[NotificationService] Requesting notification permissions...");
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      print(
          "[NotificationService] Permission.notification not granted yet. Requesting...");
      await Permission.notification.request();
    } else {
      print("[NotificationService] Permission.notification already granted.");
    }

    if (Platform.isIOS) {
      print(
          "[NotificationService] iOS detected. Requesting iOS notification permissions...");
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: false);
    }
  }

  Future<void> _createNotificationChannels() async {
    print("[NotificationService] Creating Android notification channels...");
    const channels = [
      AndroidNotificationChannel(
        _prayerChannelId,
        'Prayer Notifications',
        description: 'Channel for prayer time alerts',
        importance: Importance.max,
        enableVibration: true,
        sound: null,
        ledColor: Color(0xFF0D47A1),
        enableLights: true,
      ),
      AndroidNotificationChannel(
        scheduleChannelId,
        'Prayer Time Scheduler',
        description: 'Channel for scheduling background prayer updates',
        importance: Importance.low,
      ),
      AndroidNotificationChannel(
        quranChannelId,
        'Quran Reminders',
        description: 'Channel for daily Quran reading reminders',
        importance: Importance.high,
        enableVibration: true,
        sound: null,
      ),
      AndroidNotificationChannel(
        azkarChannelId,
        'Azkar Reminders',
        description:
            'Channel for morning, evening and sleeping azkar reminders',
        importance: Importance.high,
        enableVibration: true,
        sound: null,
        ledColor: Color(0xFF4CAF50),
        enableLights: true,
      ),
    ];

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      for (final channel in channels) {
        print(
            "[NotificationService] Creating channel id='${channel.id}', name='${channel.name}', importance=${channel.importance}");
        await androidPlugin.createNotificationChannel(channel);
      }
      print(
          "[NotificationService] Android notification channels created: ${channels.length}");
    } else {
      print(
          "[NotificationService] AndroidFlutterLocalNotificationsPlugin is null. Channels not created (non-Android platform?)");
    }
  }

  Future<void> showPrayerNotification(String title,
      {String? customBody}) async {
    final isEnglish = Globals.languageState ?? true;

    print(
        "[NotificationService] Showing prayer notification now: id=${title.hashCode}, title='$title', payload='prayer_$title'");

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
        customBody ??
            (isEnglish
                ? 'It is time for $title prayer'
                : 'حان الآن وقت صلاة $title'),
        contentTitle: isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
        htmlFormatBigText: true,
        summaryText: isEnglish ? 'Tap to open app' : 'انقر لفتح التطبيق',
      ),
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
      customBody ??
          (isEnglish
              ? 'It is time for $title prayer'
              : 'حان الآن وقت صلاة $title'),
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'prayer_$title',
    );

    print(
        "[NotificationService] Prayer notification shown successfully: id=${title.hashCode}");
  }

  Future<void> schedulePrayerNotification(
    String title,
    DateTime dateTime, {
    String? customBody,
  }) async {
    final isEnglish = Globals.languageState ?? true;
    final tzTime = tz.TZDateTime.from(dateTime, tz.local);

    final nowTz = tz.TZDateTime.now(tz.local);
    if (tzTime.isBefore(nowTz)) {
      print(
          "[NotificationService] schedulePrayerNotification() skipped: '$title' tzTime=$tzTime is before now=$nowTz");
      return;
    }

    final id = generatePrayerNotificationId(dateTime, title);

    print(
        "[NotificationService] Scheduling prayer notification: id=$id, title='$title', tzTime=$tzTime, payload='prayer_$title'");

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
      sound: null,
      categoryIdentifier: 'prayer_category',
      threadIdentifier: 'prayer_notifications',
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      isEnglish ? 'Prayer Reminder 🕌' : 'تنبيه للصلاة 🕌',
      customBody ?? (isEnglish ? '$title prayer time' : 'موعد صلاة $title'),
      tzTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'prayer_$title',
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    print(
        "[NotificationService] Prayer notification scheduled successfully: id=$id");
  }

  Future<void> scheduleDailyQuranReminder(TimeOfDay time) async {
    final isEnglish = Globals.languageState ?? true;
    final now = DateTime.now();
    var scheduledTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    print(
        "[NotificationService] Scheduling daily Quran reminder: id=$quranReminderId, time=${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}, tzTime=$tzTime, payload='quran_reminder'");

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
        (isEnglish
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
      (isEnglish
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

    print(
        "[NotificationService] Daily Quran reminder scheduled successfully: id=$quranReminderId");
  }

  Future<void> scheduleDailyAzkarReminders() async {
    print("[NotificationService] Scheduling daily Azkar reminders...");
    // Morning azkar at sunrise
    await scheduleAzkarReminder(
      id: morningAzkarId,
      time: const TimeOfDay(hour: 6, minute: 0),
      type: AzkarType.morning,
    );

    // Evening azkar at sunset
    await scheduleAzkarReminder(
      id: eveningAzkarId,
      time: const TimeOfDay(hour: 18, minute: 0),
      type: AzkarType.evening,
    );

    // Before sleeping azkar
    await scheduleAzkarReminder(
      id: sleepingAzkarId,
      time: const TimeOfDay(hour: 22, minute: 0),
      type: AzkarType.sleeping,
    );

    print("[NotificationService] Daily Azkar reminders scheduling finished.");
  }

  Future<void> scheduleAzkarReminder({
    required int id,
    required TimeOfDay time,
    required AzkarType type,
  }) async {
    final isEnglish = Globals.languageState ?? true;
    final now = DateTime.now();
    var scheduledTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final (title, body, payload) = switch (type) {
      AzkarType.morning => (
          isEnglish ? 'Morning Azkar 🌅' : 'أذكار الصباح 🌅',
          isEnglish
              ? 'Start your day with remembrance of Allah. Read your morning azkar now.'
              : 'ابدأ يومك بذكر الله. اقرأ أذكار الصباح الآن.',
          'morning_azkar',
        ),
      AzkarType.evening => (
          isEnglish ? 'Evening Azkar 🌇' : 'أذكار المساء 🌇',
          isEnglish
              ? 'End your day with remembrance of Allah. Read your evening azkar now.'
              : 'اختم يومك بذكر الله. اقرأ أذكار المساء الآن.',
          'evening_azkar',
        ),
      AzkarType.sleeping => (
          isEnglish ? 'Before Sleeping Azkar 🌙' : 'أذكار النوم 🌙',
          isEnglish
              ? 'Before you sleep, remember Allah with these beautiful adhkar for peaceful sleep.'
              : 'قبل النوم، اذكر الله بهذه الأذكار الجميلة لنوم هادئ.',
          'sleeping_azkar',
        ),
    };

    print(
        "[NotificationService] Scheduling Azkar reminder: id=$id, type=$type, title='$title', tzTime=$tzTime, payload='$payload'");

    final androidDetails = AndroidNotificationDetails(
      azkarChannelId,
      'Azkar Reminders',
      channelDescription: 'Channel for azkar reminders',
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
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print(
        "[NotificationService] Azkar reminder scheduled successfully: id=$id");
  }

  Future<void> showRichAzkarNotification({
    required AzkarType type,
    String? customTitle,
    String? customBody,
    String? customPayload,
  }) async {
    final isEnglish = Globals.languageState ?? true;

    final (title, body, payload, notificationId) = switch (type) {
      AzkarType.morning => (
          customTitle ?? (isEnglish ? 'Morning Azkar 🌅' : 'أذكار الصباح 🌅'),
          customBody ??
              (isEnglish
                  ? 'Start your day with remembrance of Allah. Read your morning azkar now.'
                  : 'ابدأ يومك بذكر الله. اقرأ أذكار الصباح الآن.'),
          customPayload ?? 'morning_azkar',
          morningAzkarId,
        ),
      AzkarType.evening => (
          customTitle ?? (isEnglish ? 'Evening Azkar 🌇' : 'أذكار المساء 🌇'),
          customBody ??
              (isEnglish
                  ? 'End your day with remembrance of Allah. Read your evening azkar now.'
                  : 'اختم يومك بذكر الله. اقرأ أذكار المساء الآن.'),
          customPayload ?? 'evening_azkar',
          eveningAzkarId,
        ),
      AzkarType.sleeping => (
          customTitle ??
              (isEnglish ? 'Before Sleeping Azkar 🌙' : 'أذكار النوم 🌙'),
          customBody ??
              (isEnglish
                  ? 'Before you sleep, remember Allah with these beautiful adhkar for peaceful sleep.'
                  : 'قبل النوم، اذكر الله بهذه الأذكار الجميلة لنوم هادئ.'),
          customPayload ?? 'sleeping_azkar',
          sleepingAzkarId,
        ),
    };

    final androidDetails = AndroidNotificationDetails(
      azkarChannelId,
      'Azkar Reminders',
      channelDescription: 'Channel for azkar reminders',
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
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: false,
      sound: null,
      categoryIdentifier: 'azkar_category',
      threadIdentifier: 'azkar_reminders',
    );

    await _notificationsPlugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );

    print(
        "[NotificationService] Rich Azkar notification shown: id=$notificationId, type=$type, payload='$payload'");
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
    await _notificationsPlugin.cancel(sleepingAzkarId);
  }

  Future<void> scheduleBackgroundTask(tz.TZDateTime time) async {
    final isEnglish = Globals.languageState ?? true;

    print(
        "[NotificationService] Scheduling background task notification: id=$backgroundTaskId, tzTime=$time, payload='update_prayer'");

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
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'update_prayer',
    );

    final now = tz.TZDateTime.now(tz.local);
    final delay = time.difference(now);

    print(
        "[NotificationService] Background task notification scheduled. now=$now, will trigger in ${delay.inSeconds}s");

    Future.delayed(delay, () async {
      print(
          "[NotificationService] Background task triggered. Calling AppLaunchService scheduling...");
      await AppLaunchService.scheduleAllAzans();
      await AppLaunchService.scheduleMonthlyAzanUpdate();
      print(
          "[NotificationService] AppLaunchService scheduling finished (scheduleAllAzans + scheduleMonthlyAzanUpdate)");
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
    print(
        "[NotificationService] Showing custom notification now: id=${title.hashCode}, title='$title', channelId='${channelId ?? _prayerChannelId}', payload='${payload ?? ''}'");
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _prayerChannelId,
      channelName ?? 'Prayer Notifications',
      channelDescription:
          channelDescription ?? 'Channel for prayer time alerts',
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

    print(
        "[NotificationService] Custom notification shown successfully: id=${title.hashCode}");
  }

  /// 🔢 Generate unique notification ID per prayer & date (e.g., 20250707 + 1 = 202507071)
  int generatePrayerNotificationId(DateTime date, String prayerName) {
    final prayerMap = {
      "الفجر": 1,
      "الظهر": 2,
      "العصر": 3,
      "المغرب": 4,
      "العشاء": 5,
    };

    final base = int.parse(
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
    return base * 10 + (prayerMap[prayerName] ?? 0);
  }
}
