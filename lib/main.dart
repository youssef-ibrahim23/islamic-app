import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/splash_screen.dart';
import 'package:islamic_app/services/app_lunch_services.dart';
import 'package:islamic_app/services/background_service_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background service handler for system events
  BackgroundServiceHandler.initialize();

  await AppLaunchService.requestPermissions();

  // Initialize notification response handler
  await _initializeNotificationHandler();

  runApp(const MyApp());
}

Future<void> _initializeNotificationHandler() async {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Note: Notification handling is now done internally in UnifiedPrayerScheduler
  // This initialization is minimal since UnifiedPrayerScheduler handles everything

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(settings: settings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashFactory: InkRipple.splashFactory,
        fontFamily: 'Amiri',
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: Globals.navigatorKey,
      navigatorObservers: [Globals.routeObserver],
      home: const SplashScreen(),
    );
  }
}
