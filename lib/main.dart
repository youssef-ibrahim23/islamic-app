import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/splash_screen.dart';
import 'package:islamic_app/services/app_lunch_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLaunchService.handleFirstRun(); // sets Globals.currentSora
  runApp(const MyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await AppLaunchService.requestStoragePermission();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashFactory: InkRipple.splashFactory,
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: Globals.navigatorKey,
      navigatorObservers: [Globals.routeObserver],
      home: const SplashScreen(),
    );
  }
}
