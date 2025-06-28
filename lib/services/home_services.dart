import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeServices {
  static StreamSubscription<CompassEvent>? _compassSubscription;

  /// Starts listening to compass heading without checking any permissions
  static void fetchCompassData(
    Function(bool) onReady,
    Function(double?) onHeadingUpdate,
  ) {
    onReady(true); // Immediately assume permission is granted or not needed

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
  }

  /// Cancels compass listening stream
  static void disposeCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
  }

  /// Loads last visited Surah info
static Future<void> loadLastSurah(Function(int, String) onLoaded) async {
  final prefs = await SharedPreferences.getInstance();

  final lastSurahId = prefs.getInt('lastSurahId') ?? 1;
  final lastSurahName = prefs.getString('lastSurahName') ?? "Al-Fatiha";
  final lastSurahArabicName = prefs.getString("lastSurahArabicName") ?? "الفاتحة";

  Globals.surahId = lastSurahId;
  Globals.currentSora = Globals.languageState! ? lastSurahName : lastSurahArabicName;

  onLoaded(Globals.surahId!, Globals.currentSora);
}

}
