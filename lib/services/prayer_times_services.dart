import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/location.dart';
import 'package:islamic_app/screens/location_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesService {
  static Future<void> checkLocationAndNavigate(BuildContext context, VoidCallback onStateChanged) async {
    final prefs = await SharedPreferences.getInstance();
    String? country = prefs.getString('country');
    String? governorate = prefs.getString('governorate');

    if (country == null || governorate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
        );
      });
    } else {
      await _loadLocationAndInitialize(onStateChanged);
    }
  }

  static Future<void> changeLocation(BuildContext context, VoidCallback onStateChanged) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
    );

    if (result == true) {
      Globals.prayerTimesIsLoading = true;
      onStateChanged();
      await _loadLocationAndInitialize(onStateChanged);
    }
  }

  static Future<void> _loadLocationAndInitialize(VoidCallback onStateChanged) async {
    final prefs = await SharedPreferences.getInstance();
    String? country = prefs.getString('country');
    String? governorate = prefs.getString('governorate');

    if (country != null && governorate != null) {
      Globals.currentLocation = '$governorate, $country';
      Globals.locationSelected = true;
      Globals.coordinates = Location().governorateCoordinates[governorate] ?? Globals.coordinates;
    }

    await _initializePrayerTimes(onStateChanged);
  }

  static Future<void> _initializePrayerTimes(VoidCallback onStateChanged) async {
    try {
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;

      final prayerTimes = PrayerTimes.today(Globals.coordinates, params);
      final formatter = DateFormat('HH:mm');

      Globals.prayerTimes = {
        'Fajr': formatter.format(prayerTimes.fajr),
        'Sunrise': formatter.format(prayerTimes.sunrise),
        'Dhuhr': formatter.format(prayerTimes.dhuhr),
        'Asr': formatter.format(prayerTimes.asr),
        'Maghrib': formatter.format(prayerTimes.maghrib),
        'Isha': formatter.format(prayerTimes.isha),
      };

      Globals.prayerTimesIsLoading = false;
      _calculateNextPrayer(prayerTimes);
      onStateChanged();
    } catch (_) {
      Globals.prayerTimesIsLoading = false;
      Globals.nextPrayer = Globals.languageState! ? "Error" : "خطأ";
      Globals.nextPrayerTime = Globals.languageState! ? "Unable to calculate" : "تعذر الحساب";
      Globals.timeRemaining = "";
      onStateChanged();
    }
  }

  static void _calculateNextPrayer(PrayerTimes times) {
    final now = DateTime.now();
    DateTime next;
    String name;

    if (now.isBefore(times.fajr)) {
      next = times.fajr;
      name = 'Fajr';
    } else if (now.isBefore(times.sunrise)) {
      next = times.sunrise;
      name = 'Sunrise';
    } else if (now.isBefore(times.dhuhr)) {
      next = times.dhuhr;
      name = 'Dhuhr';
    } else if (now.isBefore(times.asr)) {
      next = times.asr;
      name = 'Asr';
    } else if (now.isBefore(times.maghrib)) {
      next = times.maghrib;
      name = 'Maghrib';
    } else if (now.isBefore(times.isha)) {
      next = times.isha;
      name = 'Isha';
    } else {
      final tomorrow = now.add(const Duration(days: 1));
      final params = CalculationMethod.egyptian.getParameters()..madhab = Madhab.shafi;
      final tomorrowTimes = PrayerTimes(
        Globals.coordinates,
        DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
        params,
      );
      next = tomorrowTimes.fajr;
      name = 'Fajr';
    }

    Globals.nextPrayer = name;
    Globals.nextPrayerTime = DateFormat('HH:mm').format(next);
    Globals.nextArabicPrayer = getArabicPrayerName(name);

    _updateTimeRemaining(next);

    Globals.timer?.cancel();
    Globals.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeRemaining(next);
    });
  }

  static void _updateTimeRemaining(DateTime nextPrayerTime) {
    final now = DateTime.now();
    final diff = nextPrayerTime.difference(now);

    Globals.timeRemaining = diff.isNegative
        ? (Globals.languageState! ? 'Prayer time now!' : 'حان وقت الصلاة الآن!')
        : '${diff.inHours.toString().padLeft(2, '0')}:'
          '${(diff.inMinutes % 60).toString().padLeft(2, '0')}:'
          '${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  static String getArabicPrayerName(String name) {
    switch (name) {
      case 'Fajr': return 'الفجر';
      case 'Sunrise': return 'الشروق';
      case 'Dhuhr': return 'الظهر';
      case 'Asr': return 'العصر';
      case 'Maghrib': return 'المغرب';
      case 'Isha': return 'العشاء';
      default: return '';
    }
  }

  static String convertTo12HourFormat(String time24) {
    try {
      final time = DateFormat("HH:mm").parse(time24);
      return DateFormat(Globals.languageState! ? "h:mm a" : "h:mm").format(time);
    } catch (_) {
      return time24;
    }
  }
}
