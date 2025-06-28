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
  static SharedPreferences? _prefs;

  static Future<void> _ensurePrefsLoaded() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> checkLocationAndNavigate(BuildContext context, VoidCallback onStateChanged) async {
    await _ensurePrefsLoaded();

    String? country = getLocalizedString(
      _prefs!.getString('countryEnglish'),
      _prefs!.getString('countryArabic'),
    );
    String? governorate = getLocalizedString(
      _prefs!.getString('governorateEnglish'),
      _prefs!.getString('governorateArabic'),
    );

    if (country == null || governorate == null) {
      try {
        // Check location permission
        if (!await Geolocator.isLocationServiceEnabled()) {
          throw Exception("Location services are disabled.");
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) throw Exception("Permission denied.");
        }
        if (permission == LocationPermission.deniedForever) throw Exception("Permission permanently denied.");

        // Get current location
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isEmpty) throw Exception("Failed to detect location.");
        Placemark place = placemarks.first;

        String rawCountry = place.country ?? "Unknown";
        String rawGovernorate = place.administrativeArea?.split(' ').first ?? "Unknown";

        String countryAr = Locations.arabicCountryFromEnglish(rawCountry);
        String governorateAr = Locations.englishGovernorateToArabic(rawCountry, rawGovernorate) ?? rawGovernorate;

        // Save to SharedPreferences
        await _prefs!.setString('countryEnglish', rawCountry);
        await _prefs!.setString('countryArabic', countryAr);
        await _prefs!.setString('governorateEnglish', rawGovernorate);
        await _prefs!.setString('governorateArabic', governorateAr);

        // Set globals
        country = getLocalizedString(rawCountry, countryAr);
        governorate = getLocalizedString(rawGovernorate, governorateAr);
        Globals.currentLocation = "$governorate, $country";
        Globals.locationSelected = true;
        Globals.coordinates = Locations().governorateCoordinates[governorate] ?? Coordinates(30.0444, 31.2357);

        await _initializePrayerTimes(onStateChanged);
      } catch (e) {
        debugPrint("Location error: $e");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
            );
          }
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
    await _ensurePrefsLoaded();

    String? country = getLocalizedString(
      _prefs!.getString('countryEnglish'),
      _prefs!.getString('countryArabic'),
    );
    String? governorate = getLocalizedString(
      _prefs!.getString('governorateEnglish'),
      _prefs!.getString('governorateArabic'),
    );

    if (country != null && governorate != null) {
      Globals.currentLocation = '$governorate, $country';
      Globals.locationSelected = true;
      Globals.coordinates = Locations().governorateCoordinates[governorate] ?? Coordinates(30.0444, 31.2357);
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
        _initializePrayerTimes(onStateChanged);
        return;
      }

      String formatted = _formatDuration(diff);
      if (Globals.timeRemaining != formatted) {
        Globals.timeRemaining = formatted;
        onStateChanged();
      }
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

  static String? getLocalizedString(String? english, String? arabic) {
    return Globals.languageState! ? english : arabic;
  }
}
