import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:islamic_app/globals.dart';

class AppLaunchService {
  static Future<void> handleFirstRun() async {
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

    await _loadLastSurah(); // <-- important!
  }

  static Future<void> _loadLastSurah() async {
    final prefs = await SharedPreferences.getInstance();
    Globals.surahId = prefs.getInt('lastSurahId') ?? 1;
    Globals.currentSora = Globals.languageState == true
        ? (prefs.getString('lastSurahName') ?? 'Al-Fatiha')
        : (prefs.getString('lastSurahArabicName') ?? 'الفاتحة');
  }

  static Future<int> _getAndroidSDKVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

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
}
