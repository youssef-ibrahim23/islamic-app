import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:islamic_app/globals.dart';

class AppLaunchService {
  /// Called once at app launch
  static Future<void> handleFirstRunAndPermissions() async {
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
      } catch (_) {}
    }

    await _loadLastSurah();
    await _handleAllPermissions();
  }

  /// Load last played Surah from preferences
  static Future<void> _loadLastSurah() async {
    final prefs = await SharedPreferences.getInstance();
    Globals.surahId = prefs.getInt('lastSurahId') ?? 1;
    Globals.currentSora = Globals.languageState == true
        ? (prefs.getString('lastSurahName') ?? 'Al-Fatiha')
        : (prefs.getString('lastSurahArabicName') ?? 'الفاتحة');
  }

  /// Request all important permissions
  static Future<void> _handleAllPermissions() async {
    await requestStoragePermission();
    await requestLocationPermission();
    await requestNotificationPermission();
  }

  /// Handle storage permission (API level aware)
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final sdkVersion = await _getAndroidSDKVersion();

      if (sdkVersion >= 30) {
        final status = await Permission.manageExternalStorage.status;
        return status.isGranted || await Permission.manageExternalStorage.request().isGranted;
      } else {
        final status = await Permission.storage.status;
        return status.isGranted || await Permission.storage.request().isGranted;
      }
    } catch (_) {
      return false;
    }
  }

  /// Handle location permission
  static Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isGranted) return true;

      return await Permission.locationWhenInUse.request().isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Handle notification permission (especially for Android 13+ and iOS)
  static Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;

      return await Permission.notification.request().isGranted;
    }
    return true;
  }

  /// Get Android SDK version
  static Future<int> _getAndroidSDKVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }
}
