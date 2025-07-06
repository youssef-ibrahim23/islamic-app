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

  static Future<void> checkLocationAndNavigate(
    BuildContext context,
    VoidCallback onStateChanged,
  ) async {
    await _ensurePrefsLoaded();

    final country = getLocalizedString(
      _prefs!.getString('countryEnglish'),
      _prefs!.getString('countryArabic'),
    );
    final governorate = getLocalizedString(
      _prefs!.getString('governorateEnglish'),
      _prefs!.getString('governorateArabic'),
    );

    if (country == null || governorate == null) {
      await _detectAndStoreLocation(context, onStateChanged);
    } else {
      await _loadLocationAndInitialize(onStateChanged);
    }
  }

  static Future<void> _detectAndStoreLocation(
    BuildContext context,
    VoidCallback onStateChanged,
  ) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception("Location services are disabled.");
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied.");
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) throw Exception("No placemarks found.");

      final place = placemarks.first;
      final rawCountry = place.country ?? "Unknown";
      final rawGovernorate = place.administrativeArea?.split(' ').first ?? "Unknown";

      final countryAr = Locations.arabicCountryFromEnglish(rawCountry);
      final governorateAr =
          Locations.englishGovernorateToArabic(rawCountry, rawGovernorate) ?? rawGovernorate;

      await _prefs!.setString('countryEnglish', rawCountry);
      await _prefs!.setString('countryArabic', countryAr);
      await _prefs!.setString('governorateEnglish', rawGovernorate);
      await _prefs!.setString('governorateArabic', governorateAr);

      // Save coordinates
      await _prefs!.setDouble('lat', position.latitude);
      await _prefs!.setDouble('lng', position.longitude);

      Globals.currentLocation =
          "${getLocalizedString(rawGovernorate, governorateAr)}, ${getLocalizedString(rawCountry, countryAr)}";
      Globals.locationSelected = true;
      Globals.coordinates = Coordinates(position.latitude, position.longitude);

      await _initializePrayerTimes(onStateChanged);
    } catch (e) {
      debugPrint("\u{1F4CD} Location detection failed: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
          );
        }
      });
    }
  }

  static Future<void> changeLocation(
    BuildContext context,
    VoidCallback onStateChanged,
  ) async {
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

    final country = getLocalizedString(
      _prefs!.getString('countryEnglish'),
      _prefs!.getString('countryArabic'),
    );
    final governorate = getLocalizedString(
      _prefs!.getString('governorateEnglish'),
      _prefs!.getString('governorateArabic'),
    );

    if (country != null && governorate != null) {
      Globals.currentLocation = "$governorate, $country";
      Globals.locationSelected = true;

      final lat = _prefs!.getDouble('lat');
      final lng = _prefs!.getDouble('lng');

      if (lat != null && lng != null) {
        Globals.coordinates = Coordinates(lat, lng);
      } else {
        Globals.coordinates = Locations().governorateCoordinates[governorate] ??
            Coordinates(30.0444, 31.2357);
      }
    }

    await _initializePrayerTimes(onStateChanged);
  }

  static Future<void> _initializePrayerTimes(VoidCallback onStateChanged) async {
    try {
      final params = CalculationMethod.egyptian.getParameters()..madhab = Madhab.shafi;
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
    } catch (e) {
      Globals.prayerTimesIsLoading = false;
      Globals.nextPrayer = Globals.languageState! ? "Error" : "\u062e\u0637\u0623";
      Globals.nextPrayerTime =
          Globals.languageState! ? "Unable to calculate" : "\u062a\u0639\u0630\u0631 \u0627\u0644\u062d\u0633\u0627\u0628";
      Globals.timeRemaining = "";
      onStateChanged();
    }
  }

  static void _calculateAndStartCountdown(
    PrayerTimes prayerTimes,
    VoidCallback onStateChanged,
  ) {
    final now = DateTime.now();
    final prayerTimesList = {
      'Fajr': prayerTimes.fajr,
      'Sunrise': prayerTimes.sunrise,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    for (final entry in prayerTimesList.entries) {
      if (now.isBefore(entry.value)) {
        _setNextPrayer(entry.key, entry.value, onStateChanged);
        return;
      }
    }

    final tomorrow = now.add(const Duration(days: 1));
    final params = CalculationMethod.egyptian.getParameters()..madhab = Madhab.shafi;
    final tomorrowFajr = PrayerTimes(
      Globals.coordinates,
      DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
      params,
    ).fajr;

    _setNextPrayer('Fajr', tomorrowFajr, onStateChanged);
  }

  static void _setNextPrayer(
    String name,
    DateTime nextTime,
    VoidCallback onStateChanged,
  ) {
    Globals.nextPrayer = name;
    Globals.nextPrayerTime = DateFormat('HH:mm').format(nextTime);
    Globals.nextArabicPrayer = getArabicPrayerName(name);
    _startCountdown(nextTime, onStateChanged);
  }

  static void _startCountdown(DateTime targetTime, VoidCallback onStateChanged) {
    Globals.timer?.cancel();
    Globals.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = targetTime.difference(now);

      if (diff.isNegative) {
        _initializePrayerTimes(onStateChanged);
        return;
      }

      final formatted = _formatDuration(diff);
      if (Globals.timeRemaining != formatted) {
        Globals.timeRemaining = formatted;
        onStateChanged();
      }
    });
  }

  static String _formatDuration(Duration diff) {
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    final formatted = '$h:$m:$s';
    return Globals.languageState! ? formatted : Globals.toArabicNumber(formatted);
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

  static String? getLocalizedString(String? en, String? ar) {
    return Globals.languageState! ? en : ar;
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
