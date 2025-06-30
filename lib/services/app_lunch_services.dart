import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:islamic_app/globals.dart';

class AppLaunchService {
  /// Called once at app launch
  static Future<void> handleFirstRunAndPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('first_run') ?? true;

    if (isFirstRun) {
      await prefs.clear();
      await prefs.setBool('first_run', false);

      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (e) {
        debugPrint("Temp directory cleanup failed: $e");
      }
    }

    await _loadLastSurah(prefs);
    await _requestEssentialPermissions();
  }

  /// Load last played Surah from preferences
  static Future<void> _loadLastSurah(SharedPreferences prefs) async {
    Globals.surahId = prefs.getInt('lastSurahId') ?? 1;
    Globals.currentSora = Globals.languageState == true
        ? (prefs.getString('lastSurahName') ?? 'Al-Fatiha')
        : (prefs.getString('lastSurahArabicName') ?? 'الفاتحة');
  }

  /// Request all important permissions
  static Future<void> _requestEssentialPermissions() async {
    await Future.wait([
      _requestStoragePermission(),
      _requestLocationPermission(),
      _requestNotificationPermission(),
    ]);
  }

  /// Handle storage permission (API level aware)
  static Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final sdkVersion = await _getAndroidSDKVersion();

      if (sdkVersion >= 30) {
        final status = await Permission.manageExternalStorage.status;
        if (status.isGranted) return true;
        return (await Permission.manageExternalStorage.request()).isGranted;
      } else {
        final status = await Permission.storage.status;
        if (status.isGranted) return true;
        return (await Permission.storage.request()).isGranted;
      }
    } catch (e) {
      debugPrint("Storage permission request failed: $e");
      return false;
    }
  }

  /// Handle location permission
  static Future<bool> _requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isGranted) return true;
      return (await Permission.locationWhenInUse.request()).isGranted;
    } catch (e) {
      debugPrint("Location permission request failed: $e");
      return false;
    }
  }

  /// Handle notification permission (Android 13+ and iOS)
  static Future<bool> _requestNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final status = await Permission.notification.status;
        if (status.isGranted) return true;
        return (await Permission.notification.request()).isGranted;
      } catch (e) {
        debugPrint("Notification permission request failed: $e");
        return false;
      }
    }
    return true;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidSDKVersion() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      debugPrint("Failed to get Android SDK version: $e");
      return 0; // safe default
    }
  }
}
