import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:islamic_app/globals.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {

  static void fetchCompassData(
    Function(bool) onPermissionResult,
    Function(double?) onHeadingUpdate,
  ) async {
    // Request location permission (required for compass access on Android)
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      onPermissionResult(true);

      // Check if the device supports compass sensors
      final hasSensor = await FlutterCompass.events?.isBroadcast ?? false;
      if (!hasSensor) {
        debugPrint("⚠️ Compass sensor not available on this device.");
        onHeadingUpdate(null);
        return;
      }

      // Subscribe to compass data safely
      FlutterCompass.events!.listen((event) {
        final heading = event.heading;

        if (heading == null) {
          debugPrint("⚠️ Compass heading is null");
          onHeadingUpdate(null);
          return;
        }

        Globals.compassHeading = heading;
        Globals.qiblaDirection = (heading - 45) % 360;

        onHeadingUpdate(Globals.qiblaDirection);
      });
    } else {
      // Permission denied
      onPermissionResult(false);
    }
  }


  static Future<void> loadLastSurah(Function(int, String) onLoaded) async {
    final prefs = await SharedPreferences.getInstance();

    final lastSurahId = prefs.getInt('lastSurahId') ?? 1;
    final lastSurahName = prefs.getString('lastSurahName') ?? "Al-Fatiha";
    final lastSurahArabicName =
        prefs.getString("lastSurahArabicName") ?? "الفاتحة";

    Globals.surahId = lastSurahId;
    Globals.currentSora = Globals.languageState! ? lastSurahName : lastSurahArabicName;

    onLoaded(Globals.surahId, Globals.currentSora);
  }
}
