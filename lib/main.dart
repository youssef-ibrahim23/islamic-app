import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/splash_screen.dart';
import 'package:islamic_app/services/app_lunch_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load preferences, permissions, initial data
    await AppLaunchService.handleFirstRunAndPermissions();
  } catch (e) {
    // Optional: log to Firebase or Sentry
    debugPrint("Startup error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamic App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo', // Optional: Add if Arabic font used
        splashFactory: InkRipple.splashFactory,
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      navigatorKey: Globals.navigatorKey,
      navigatorObservers: [Globals.routeObserver],
      home: const SplashScreen(),
    );
  }
}
