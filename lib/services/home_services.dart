import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:islamic_app/globals.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {
  
static StreamSubscription<CompassEvent>? _compassSubscription;

static void fetchCompassData(
  Function(bool) onPermissionResult,
  Function(double?) onHeadingUpdate,
) async {
  final status = await Permission.locationWhenInUse.request();

  if (status.isGranted) {
    onPermissionResult(true);

    _compassSubscription?.cancel();

    _compassSubscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) {
        onHeadingUpdate(null);
        return;
      }
      Globals.compassHeading = heading;
      Globals.qiblaDirection = (heading - 45) % 360;
      onHeadingUpdate(Globals.qiblaDirection);
    });
  } else {
    onPermissionResult(false);
  }
}

static void disposeCompass() {
  _compassSubscription?.cancel();
  _compassSubscription = null;
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
