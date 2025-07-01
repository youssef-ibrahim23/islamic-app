// ignore_for_file: library_prefixes, deprecated_member_use

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/services/app_lunch_services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';
import 'package:islamic_app/globals.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _player = AudioPlayer();

  NotificationService() {
    // Stop audio when playback completes
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _player.stop();
      }
    });
  }

  /// Initialize notifications and request permissions
  Future<void> init() async {
    tzData.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'stop_azan' ||
            response.notificationResponseType ==
                NotificationResponseType.selectedNotification) {
          await stopAzan();
        }
      },
    );

    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  /// Show instant azan notification and play audio
  Future<void> showAzanNotification(String title) async {
    final bool isEnglish = Globals.languageState ?? true;

    final androidDetails = AndroidNotificationDetails(
      'azan_channel',
      'Azan Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      ongoing: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_azan',
          isEnglish ? '⏹ Stop Azan' : '⏹ إيقاف الأذان',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    await _plugin.show(
      title.hashCode,
      isEnglish ? '📢 Azan $title' : '📢 أذان $title',
      isEnglish ? 'Tap to stop azan' : 'اضغط لإيقاف الأذان',
      NotificationDetails(android: androidDetails),
    );

    await playAzan();
  }

  /// Schedule future azan notification and play audio at that time
  Future<void> scheduleAzan(String title, DateTime dateTime) async {
    final bool isEnglish = Globals.languageState ?? true;
    final tzTime = tz.TZDateTime.from(dateTime, tz.local);
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    final int notificationId = title.hashCode ^ dateTime.hashCode;

    await _plugin.zonedSchedule(
      notificationId,
      isEnglish ? '📢 Azan Time' : '📢 حان الآن وقت الأذان',
      isEnglish ? 'Azan $title' : 'أذان $title',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azan_channel',
          'Azan Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final now = DateTime.now();
    final delay = dateTime.difference(now);

    Future.delayed(delay, () async {
      await playAzan();
    });
  }

  /// Play the azan audio
  Future<void> playAzan() async {
    try {
      await _player.setAsset('assets/azan.mp3');
      await _player.play();
    } catch (e) {
      print('Error playing Azan: $e');
    }
  }

  /// Stop azan playback
  Future<void> stopAzan() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping Azan: $e');
    }
  }

  /// Stop azan manually (static access)
  static Future<void> stopAzanManually() async {
    try {
      await _player.stop();
    } catch (e) {
      print('Error stopping Azan manually: $e');
    }
  }

  /// Cancel all scheduled azans
  Future<void> cancelAllAzans() async {
    await _plugin.cancelAll();
  }

  /// Schedule background update task
  Future<void> scheduleBackgroundTask(tz.TZDateTime time) async {
    final bool isEnglish = Globals.languageState ?? true;

    await _plugin.zonedSchedule(
      999999,
      isEnglish ? '⏰ Updating Azan Times' : '⏰ تحديث مواعيد الأذان',
      isEnglish
          ? 'Updating prayer times automatically'
          : 'يتم الآن تحديث مواعيد الصلاة تلقائيًا',
      time,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azan_schedule_channel',
          'Azan Scheduler',
          importance: Importance.low,
          priority: Priority.low,
          playSound: false,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'update_azan',
    );

    final now = tz.TZDateTime.now(tz.local);
    final delay = time.difference(now);

    Future.delayed(delay, () async {
      await AppLaunchService.scheduleAllAzans();
      await AppLaunchService.scheduleDailyAzanUpdate();
    });
  }

}
