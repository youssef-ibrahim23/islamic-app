import 'dart:async';
import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/splash_screen.dart';
import 'package:islamic_app/services/app_lunch_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only request permissions here
  await AppLaunchService.requestPermissions();

  // App logic runs later in SplashScreen
  runApp(const MyApp());
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
