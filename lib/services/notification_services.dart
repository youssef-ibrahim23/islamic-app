// ignore_for_file: deprecated_member_use, library_prefixes

import 'dart:io';
import 'app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/screens/azkar.dart';
import 'package:islamic_app/screens/prayer_times.dart';
import 'package:islamic_app/screens/surahs_list.dart';
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
      AppLogger.log(
          "[NotificationService] init() skipped: already initialized (isInitialized=true)");
      // Still need to ensure permissions are granted on every app start
      await _requestPermissions();
      return;
    }

    AppLogger.log("[NotificationService] init() starting...");

    tzData.initializeTimeZones();

    AppLogger.log(
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
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response);
      },
      onDidReceiveBackgroundNotificationResponse:
          _handleBackgroundNotificationResponse,
    );

    AppLogger.log("[NotificationService] Plugin initialized.");

    await _requestPermissions();
    await _createNotificationChannels();

    await sharedPreferences.setBool("isInitialized", true);

    AppLogger.log("Notification system initialized.");
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

  @pragma('vm:entry-point')
  static void _handleBackgroundNotificationResponse(
      NotificationResponse response) {
    AppLogger.log(
        "[NotificationService] Background notification received: ${response.payload}");
    // Handle background notification if needed
    // This ensures notifications work even when app is terminated
  }

  Future<void> _requestPermissions() async {
    AppLogger.log(
        "[NotificationService] Requesting notification permissions...");
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      AppLogger.log(
          "[NotificationService] Permission.notification not granted yet. Requesting...");
      await Permission.notification.request();
    } else {
      AppLogger.log(
          "[NotificationService] Permission.notification already granted.");
    }

    if (Platform.isIOS) {
      AppLogger.log(
          "[NotificationService] iOS detected. Requesting iOS notification permissions...");
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _createNotificationChannels() async {
    AppLogger.log(
        "[NotificationService] Creating Android notification channels...");
    const channels = [
      AndroidNotificationChannel(
        _prayerChannelId,
        'Prayer Notifications',
        description: 'Channel for prayer time alerts',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('azan'),
        ledColor: Color(0xFF0D47A1),
        enableLights: true,
        showBadge: true,
      ),
      AndroidNotificationChannel(
        scheduleChannelId,
        'Prayer Time Scheduler',
        description: 'Channel for scheduling background prayer updates',
        importance: Importance.low,
      ),
      AndroidNotificationChannel(
        azkarChannelId,
        'Azkar & Quran Reminders',
        description:
            'Channel for morning, evening, sleeping azkar and Quran reading reminders',
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
        AppLogger.log(
            "[NotificationService] Creating channel id='${channel.id}', name='${channel.name}', importance=${channel.importance}");
        await androidPlugin.createNotificationChannel(channel);
      }
      AppLogger.log(
          "[NotificationService] Android notification channels created: ${channels.length}");
    } else {
      AppLogger.log(
          "[NotificationService] AndroidFlutterLocalNotificationsPlugin is null. Channels not created (non-Android platform?)");
    }
  }

  Future<void> showPrayerNotification(String title,
      {String? customBody}) async {
    final isEnglish = Globals.languageState ?? true;

    AppLogger.log(
        "[NotificationService] Showing prayer notification now: id=${title.hashCode}, title='$title', payload='prayer_$title'");

    final androidDetails = AndroidNotificationDetails(
      _prayerChannelId,
      'Prayer Notifications',
      channelDescription: 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('azan'),
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
      presentSound: true,
      sound: 'azan.mp3',
      categoryIdentifier: 'prayer_category',
      threadIdentifier: 'prayer_notifications',
    );

    await _notificationsPlugin.show(
      id: title.hashCode,
      title: isEnglish ? 'Prayer Time 🕌' : 'وقت الصلاة 🕌',
      body: customBody ??
          (isEnglish
              ? 'It is time for $title prayer'
              : 'حان الآن وقت صلاة $title'),
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'prayer_$title',
    );

    AppLogger.log(
        "[NotificationService] Prayer notification shown successfully: id=${title.hashCode}");
  }

  Future<void> schedulePrayerNotification(
    String title,
    DateTime dateTime, {
    String? customBody,
  }) async {
    final canSchedule = await _ensureExactAlarmPermission();
    if (!canSchedule) return;

    final isEnglish = Globals.languageState ?? true;
    final tzTime = tz.TZDateTime.from(dateTime, tz.local);

    final nowTz = tz.TZDateTime.now(tz.local);
    if (tzTime.isBefore(nowTz)) {
      AppLogger.log(
          "[NotificationService] schedulePrayerNotification() skipped: '$title' tzTime=$tzTime is before now=$nowTz");
      return;
    }

    final id = generatePrayerNotificationId(dateTime, title);

    final formattedTime =
        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

    AppLogger.log(
      "🕌 Scheduling Prayer → $title at $formattedTime (tz: ${tzTime.toString()})",
      name: "NotificationService",
    );

    // Log scheduling details
    final now = tz.TZDateTime.now(tz.local);
    final timeUntil = tzTime.difference(now);
    AppLogger.log(
        "⏰ Prayer Notification Details: ID=$id, Title='$title', Scheduled=$tzTime, TimeUntil=${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m, Payload='prayer_$title'",
        name: "NotificationService");

    final androidDetails = AndroidNotificationDetails(
      _prayerChannelId,
      'Prayer Notifications',
      channelDescription: 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('azan'),
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
      presentSound: true,
      sound: 'azan.mp3',
      categoryIdentifier: 'prayer_category',
      threadIdentifier: 'prayer_notifications',
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: isEnglish ? 'Prayer Reminder 🕌' : 'تنبيه للصلاة 🕌',
      body:
          customBody ?? (isEnglish ? '$title prayer time' : 'موعد صلاة $title'),
      scheduledDate: tzTime,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'prayer_$title',
    );

    AppLogger.log(
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

    // Ensure timezone is properly set to Africa/Cairo (UTC+2)
    if (tz.local.name == 'UTC') {
      tz.setLocalLocation(tz.getLocation("Africa/Cairo"));
    }

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    AppLogger.log(
        "[NotificationService] Scheduling daily Quran reminder: id=$quranReminderId, time=${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}, tzTime=$tzTime, payload='quran_reminder'");

    // Log scheduling details
    final nowTz = tz.TZDateTime.now(tz.local);
    final timeUntil = tzTime.difference(nowTz);
    AppLogger.log(
        "📖 Quran Reminder Details: ID=$quranReminderId, Scheduled=$tzTime, TimeUntil=${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m, Payload='quran_reminder'",
        name: "NotificationService");

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
      id: quranReminderId,
      title: isEnglish ? 'Quran Reminder 📖' : 'تذكير القرآن 📖',
      body: (isEnglish
          ? 'Take a moment to read Quran today and gain blessings'
          : 'خذ لحظة لقراءة القرآن اليوم واكتساب البركات'),
      scheduledDate: tzTime,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'quran_reminder',
      matchDateTimeComponents: DateTimeComponents.time,
    );

    AppLogger.log(
        "[NotificationService] Daily Quran reminder scheduled successfully: id=$quranReminderId");
  }

  Future<void> scheduleDailyAzkarReminders() async {
    AppLogger.log("[NotificationService] Scheduling daily Azkar reminders...");
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

    AppLogger.log(
        "[NotificationService] Daily Azkar reminders scheduling finished.");
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

    // Ensure timezone is properly set to Africa/Cairo (UTC+2)
    if (tz.local.name == 'UTC') {
      tz.setLocalLocation(tz.getLocation("Africa/Cairo"));
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

    AppLogger.log(
        "[NotificationService] Scheduling Azkar reminder: id=$id, type=$type, title='$title', tzTime=$tzTime, payload='$payload'");

    // Log scheduling details
    final nowTz = tz.TZDateTime.now(tz.local);
    final timeUntil = tzTime.difference(nowTz);
    AppLogger.log(
        "📿 Azkar Reminder Details: ID=$id, Type=$type, Title='$title', Scheduled=$tzTime, TimeUntil=${timeUntil.inHours}h ${timeUntil.inMinutes % 60}m, Payload='$payload'",
        name: "NotificationService");

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
      id: id,
      title: title,
      body: body,
      scheduledDate: tzTime,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );

    AppLogger.log(
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
      id: notificationId,
      title: title,
      body: body,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );

    AppLogger.log(
        "[NotificationService] Rich Azkar notification shown: id=$notificationId, type=$type, payload='$payload'");
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
    AppLogger.log(
        "[NotificationService] Showing custom notification now: id=${title.hashCode}, title='$title', channelId='${channelId ?? _prayerChannelId}', payload='${payload ?? ''}'");
    final androidDetails = AndroidNotificationDetails(
      channelId ?? _prayerChannelId,
      channelName ?? 'Prayer Notifications',
      channelDescription:
          channelDescription ?? 'Channel for prayer time alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('azan'),
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
      presentSound: true,
      sound: 'azan.mp3',
    );

    await _notificationsPlugin.show(
      id: title.hashCode,
      title: title,
      body: body,
      notificationDetails:
          NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );

    AppLogger.log(
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

  Future<void> cancelAllPrayerNotifications() async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();

      AppLogger.log("[NotificationService] Canceling prayer notifications...");

      for (final notification in pending) {
        // Check if it's a prayer notification by checking payload
        if (notification.payload != null &&
            notification.payload!.startsWith('prayer_')) {
          await _notificationsPlugin.cancel(id: notification.id);
          AppLogger.log(
              "[NotificationService] Canceled prayer notification: id=${notification.id}");
        }
      }

      AppLogger.log(
          "[NotificationService] Prayer notifications cleanup completed");
    } catch (e) {
      AppLogger.log(
          "[NotificationService] Error canceling prayer notifications: $e");
    }
  }

  Future<void> printAllScheduledNotifications() async {
    AppLogger.log(
        "[NotificationService] Fetching all pending notifications...");
    final pending = await _notificationsPlugin.pendingNotificationRequests();

    if (pending.isEmpty) {
      AppLogger.log("[NotificationService] No pending notifications found.");
      return;
    }

    AppLogger.log(
        "[NotificationService] Found ${pending.length} pending notification(s):");

    // Get current time for reference
    final now = tz.TZDateTime.now(tz.local);
    AppLogger.log("[NotificationService] Current time: $now");

    for (var i = 0; i < pending.length; i++) {
      final req = pending[i];

      // Log available information from PendingNotificationRequest
      // Note: scheduledDate is not available in PendingNotificationRequest
      AppLogger.log(
          "  [$i] id: ${req.id}, title: '${req.title}', body: '${req.body}', payload: '${req.payload}'");
    }
  }

  Future<bool> checkIfNotificationsAbleToPresent() async {
    AppLogger.log(
        "[NotificationService] Checking if notifications can be presented...");

    final status = await Permission.notification.status;
    if (!status.isGranted) {
      AppLogger.log(
          "[NotificationService] Notification permission is NOT granted.");
      return false;
    }

    final enabled = await _areNotificationsEnabled();
    if (!enabled!) {
      AppLogger.log(
          "[NotificationService] System notifications are disabled for this app.");
      return false;
    }

    AppLogger.log(
        "[NotificationService] Notifications can be presented (permission granted + system enabled).");
    return true;
  }

  Future<bool?> _areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;
      return await androidPlugin.areNotificationsEnabled();
    } else if (Platform.isIOS) {
      final iosPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin == null) return false;
      final permissions = await iosPlugin.checkPermissions();
      return permissions != null &&
          permissions.isSoundEnabled == true; // or check alert/badge
    }
    return true;
  }

  Future<bool> _ensureExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      AppLogger.log("[ExactAlarm] Android plugin is null.");
      return false;
    }

    final canExact =
        await androidPlugin.canScheduleExactNotifications() ?? false;

    AppLogger.log("[ExactAlarm] canScheduleExactNotifications = $canExact");

    if (canExact) return true;

    AppLogger.log("[ExactAlarm] Exact alarm NOT allowed. Requesting...");

    // Android 13+ runtime notification permission
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }

    // Try requesting exact alarm permission (Android 14+)
    try {
      await androidPlugin.requestExactAlarmsPermission();
    } catch (e) {
      AppLogger.log("[ExactAlarm] requestExactAlarmsPermission failed: $e");
    }

    final recheck =
        await androidPlugin.canScheduleExactNotifications() ?? false;

    AppLogger.log("[ExactAlarm] After request → allowed = $recheck");

    return recheck;
  }
}
