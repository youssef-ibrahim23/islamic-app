import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
    try {
      // 🔹 Check permission and request if needed
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied.");
      }

      // 🔹 Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 🔹 Reverse geocode to get location name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        
      );

      if (placemarks.isNotEmpty) {
  Placemark place = placemarks.first;

  // Raw data (likely English)
  String rawCountry = place.country ?? "Unknown";
  String rawGovernorate = place.administrativeArea ?? "Unknown";

  // Convert English country name to Arabic (if possible)
  String countryArabic = Locations.arabicCountryFromEnglish(rawCountry);

  // Convert English governorate to Arabic if possible
  String governorateArabic =
      Locations.englishGovernorateToArabic(rawCountry, rawGovernorate) ??
      rawGovernorate; // fallback to raw if no match

  // Save Arabic names
  country = countryArabic;
  governorate = governorateArabic;

  // Save to prefs
  await prefs.setString('country', country);
  await prefs.setString('governorate', governorate);

  // Set globals
  Globals.currentLocation = "$governorate, $country";
  Globals.locationSelected = true;

  Globals.coordinates = Locations().governorateCoordinates[governorate] ?? Globals.coordinates;

  await _initializePrayerTimes(onStateChanged);
}

 else {
        throw Exception("Failed to detect location.");
      }
    } catch (e) {
      debugPrint("Location error: $e");

      // If failed, go to manual selection page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
        );
      });
    }
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
      Globals.coordinates = Locations().governorateCoordinates[governorate] ?? Globals.coordinates;
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
      _calculateAndStartCountdown(prayerTimes, onStateChanged);
    } catch (_) {
      Globals.prayerTimesIsLoading = false;
      Globals.nextPrayer = Globals.languageState! ? "Error" : "خطأ";
      Globals.nextPrayerTime = Globals.languageState! ? "Unable to calculate" : "تعذر الحساب";
      Globals.timeRemaining = "";
      onStateChanged();
    }
  }

  static void _calculateAndStartCountdown(PrayerTimes prayerTimes, VoidCallback onStateChanged) {
    final now = DateTime.now();
    DateTime next;
    String name;

    if (now.isBefore(prayerTimes.fajr)) {
      next = prayerTimes.fajr;
      name = 'Fajr';
    } else if (now.isBefore(prayerTimes.sunrise)) {
      next = prayerTimes.sunrise;
      name = 'Sunrise';
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      next = prayerTimes.dhuhr;
      name = 'Dhuhr';
    } else if (now.isBefore(prayerTimes.asr)) {
      next = prayerTimes.asr;
      name = 'Asr';
    } else if (now.isBefore(prayerTimes.maghrib)) {
      next = prayerTimes.maghrib;
      name = 'Maghrib';
    } else if (now.isBefore(prayerTimes.isha)) {
      next = prayerTimes.isha;
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

    _startCountdown(next, onStateChanged);
  }

  static void _startCountdown(DateTime nextPrayerTime, VoidCallback onStateChanged) {
    Globals.timer?.cancel();
    Globals.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = nextPrayerTime.difference(now);

      if (diff.isNegative) {
        // Time passed; restart whole cycle
        _initializePrayerTimes(onStateChanged);
        return;
      }

      Globals.timeRemaining = _formatDuration(diff);
      onStateChanged();
    });
  }

  static String _formatDuration(Duration diff) {
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    final formatted = '$hours:$minutes:$seconds';

    return Globals.languageState!
        ? formatted
        : Globals.toArabicNumber(formatted);
  }

  static String getArabicPrayerName(String name) {
    switch (name) {
      case 'Fajr':
        return 'الفجر';
      case 'Sunrise':
        return 'الشروق';
      case 'Dhuhr':
        return 'الظهر';
      case 'Asr':
        return 'العصر';
      case 'Maghrib':
        return 'المغرب';
      case 'Isha':
        return 'العشاء';
      default:
        return '';
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
