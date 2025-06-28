import 'dart:io';
import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle first app launch logic (e.g. clear cache)
  await _handleFirstRun();

  // Start app
  runApp(const MyApp());

  // Ask for storage permission once UI is ready — silently
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await requestStoragePermission();
  });
}

/// Handles clearing cache and shared preferences on first launch
Future<void> _handleFirstRun() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('first_run');

  if (isFirstRun == null || isFirstRun) {
    await prefs.clear();
    await prefs.setBool('first_run', false);

    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear temporary directory: $e');
    }
  }
}

/// Retrieves the Android SDK version
Future<int> _getAndroidSDKVersion() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  return androidInfo.version.sdkInt;
}

/// Requests storage permission silently
Future<bool> requestStoragePermission() async {
  if (!Platform.isAndroid) return true;

  try {
    final sdkVersion = await _getAndroidSDKVersion();

    if (sdkVersion >= 30) {
      // Android 11+
      final status = await Permission.manageExternalStorage.status;

      if (status.isGranted) {
        return true;
      }

      final result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      // Android < 11
      final status = await Permission.storage.status;

      if (status.isGranted) {
        return true;
      }

      final result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  } catch (e) {
    return false;
  }
}

/// Main app entry
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
