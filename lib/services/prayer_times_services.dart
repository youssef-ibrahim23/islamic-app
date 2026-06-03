import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/location.dart';
import 'package:islamic_app/screens/location_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesService {
  static SharedPreferences? _prefs;
  static bool isFirstTime = true;

  // Timezone mapping for each country
  static const Map<String, String> countryTimezones = {
    'Saudi Arabia': 'Asia/Riyadh',
    'Egypt': 'Africa/Cairo',
  };

  static Future<void> _ensurePrefsLoaded() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> checkLocationAndNavigate(
    BuildContext context,
    VoidCallback onStateChanged, {
    bool forceGPSDetection = false,
    bool navigateOnFail = true,
  }) async {
    await _ensurePrefsLoaded();

    // Check if user has already selected a location
    final savedCountry = _prefs!.getString('countryEnglish');
    final savedGovernorate = _prefs!.getString('governorateEnglish');
    final hasSavedLocation = savedCountry != null && savedGovernorate != null;

    // Check if coming from manual location selection
    final comingFromSelection =
        _prefs!.getBool('comingFromLocationSelection') ?? false;
    if (comingFromSelection) {
      // Clear the flag and use saved location
      await _prefs!.setBool('comingFromLocationSelection', false);
      if (hasSavedLocation) {
        await _loadLocationAndInitialize();
        return;
      }
    }

    // Only use GPS location if it's the first time OR forceGPSDetection is true
    if (isFirstTime || forceGPSDetection || !hasSavedLocation) {
      if (isFirstTime) {
        isFirstTime = false;
      }
      await _detectAndStoreLocation(context, onStateChanged,
          isFirstTime: false, navigateOnFail: navigateOnFail);
    } else {
      // Use saved location for prayer times
      await _loadLocationAndInitialize();
    }
  }

  static Future<void> _detectAndStoreLocation(
    BuildContext context,
    VoidCallback onStateChanged, {
    bool isFirstTime = false,
    bool navigateOnFail = true,
  }) async {
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

      // Use timeout with future to prevent hanging
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 3));

      if (placemarks.isEmpty) throw Exception("No placemarks found.");

      final place = placemarks.first;
      final rawCountry = place.country ?? "Unknown";
      final rawGovernorate =
          place.administrativeArea?.split(' ').first ?? "Unknown";

      final countryAr = Locations.arabicCountryFromEnglish(rawCountry);
      final governorateAr =
          Locations.englishGovernorateToArabic(rawCountry, rawGovernorate) ??
              rawGovernorate;

      // Map detected country to supported country for prayer calculations
      final mappedCountry = _mapToSupportedCountry(rawCountry);

      // IMPORTANT: Always use current device location for prayer calculations
      Globals.selectedCountry = mappedCountry;
      Globals.currentLocation = isFirstTime
          ? "${getLocalizedString(rawGovernorate, governorateAr)}, "
              "${getLocalizedString(rawCountry, countryAr)}"
          : "${getLocalizedString(rawGovernorate, governorateAr)}, ${getLocalizedString(rawCountry, countryAr)}";
      Globals.locationSelected = true;
      Globals.coordinates = Coordinates(position.latitude, position.longitude);

      // Save coordinates (save to both key formats for compatibility)
      await _prefs!.setDouble('lat', position.latitude);
      await _prefs!.setDouble('lng', position.longitude);
      await _prefs!.setDouble('latitude', position.latitude);
      await _prefs!.setDouble('longitude', position.longitude);

      // Save detected country as current selection
      await _prefs!.setString('countryEnglish', mappedCountry);
      await _prefs!.setString(
          'countryArabic', Locations.arabicCountryFromEnglish(mappedCountry));
      await _prefs!.setString('governorateEnglish', rawGovernorate);
      await _prefs!.setString('governorateArabic', governorateAr);

      // Save as last successful location for fallback
      await _saveLastSuccessfulLocation(mappedCountry, rawGovernorate);

      await _initializePrayerTimes();
    } catch (e) {
      debugPrint("📍 Location detection failed: $e");

      // Try to load last saved location when GPS fails
      final lastLocationLoaded = await _tryLoadLastSavedLocation();

      if (lastLocationLoaded) {
        debugPrint("✅ Successfully loaded last saved location");
        return; // Success, no need to prompt user
      }

      debugPrint("❌ No saved location available, prompting user");

      if (navigateOnFail) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LocationSelectionPage()),
            );
          }
        });
      } else {
        Globals.locationSelected = false;
        Globals.prayerTimesIsLoading = false;
        onStateChanged();
      }
    }
  }

  // Save last successful location for fallback
  static Future<void> _saveLastSuccessfulLocation(
      String country, String governorate) async {
    await _ensurePrefsLoaded();
    await _prefs!.setString('last_successful_country', country);
    await _prefs!.setString('last_successful_governorate', governorate);
    await _prefs!.setString(
        'last_successful_timestamp', DateTime.now().toIso8601String());
  }

  // Try to load last saved location when GPS fails
  static Future<bool> _tryLoadLastSavedLocation() async {
    await _ensurePrefsLoaded();

    try {
      final lastCountry = _prefs!.getString('last_successful_country');
      final lastGovernorate = _prefs!.getString('last_successful_governorate');
      final lastTimestamp = _prefs!.getString('last_successful_timestamp');

      if (lastCountry == null ||
          lastGovernorate == null ||
          lastTimestamp == null) {
        debugPrint("📍 No last successful location found");
        return false;
      }

      // Check if last location is recent (within 30 days)
      final lastDate = DateTime.parse(lastTimestamp);
      final now = DateTime.now();
      final daysDifference = now.difference(lastDate).inDays;

      if (daysDifference > 30) {
        debugPrint("📍 Last saved location is too old ($daysDifference days)");
        return false;
      }

      // Load the last successful location
      final countryAr = Locations.arabicCountryFromEnglish(lastCountry);
      final governorateAr =
          Locations.englishGovernorateToArabic(lastCountry, lastGovernorate) ??
              lastGovernorate;

      Globals.selectedCountry = lastCountry;
      Globals.selectedGovernorate = lastGovernorate;
      Globals.currentLocation =
          "${getLocalizedString(lastGovernorate, governorateAr)}, ${getLocalizedString(lastCountry, countryAr)}";
      Globals.locationSelected = true;

      // Try to load coordinates for the last location
      final lat = _prefs!.getDouble('lat') ?? _prefs!.getDouble('latitude');
      final lng = _prefs!.getDouble('lng') ?? _prefs!.getDouble('longitude');

      if (lat != null && lng != null) {
        Globals.coordinates = Coordinates(lat, lng);
      } else {
        // Fallback to governorate coordinates
        final locationString =
            "${getLocalizedString(lastGovernorate, governorateAr)}, ${getLocalizedString(lastCountry, countryAr)}";
        Globals.coordinates =
            Locations().governorateCoordinates[locationString] ??
                Coordinates(30.0444, 31.2357);
      }

      // Update current saved location to use this one
      await _prefs!.setString('countryEnglish', lastCountry);
      await _prefs!.setString('countryArabic', countryAr);
      await _prefs!.setString('governorateEnglish', lastGovernorate);
      await _prefs!.setString('governorateArabic', governorateAr);

      await _initializePrayerTimes();
      return true;
    } catch (e) {
      debugPrint("❌ Error loading last saved location: $e");
      return false;
    }
  }

  // Helper method to map detected country to supported country
  static String _mapToSupportedCountry(String detectedCountry) {
    switch (detectedCountry.toLowerCase()) {
      case 'saudi arabia':
        return 'Saudi Arabia';
      case 'egypt':
        return 'Egypt';
      case 'united arab emirates':
      case 'uae':
        return 'UAE';
      case 'kuwait':
        return 'Kuwait';
      case 'qatar':
        return 'Qatar';
      case 'bahrain':
        return 'Bahrain';
      default:
        // Default to Egypt if country not supported
        return 'Egypt';
    }
  }

  static Future<void> changeLocation(
    BuildContext context,
  ) async {
    Globals.prayerTimesIsLoading = true;

    // Force reload from SharedPreferences to get latest saved location
    await _loadLocationAndInitialize();

    // Reset isFirstTime flag to prevent GPS override
    isFirstTime = false;
  }

  static Future<void> _loadLocationAndInitialize() async {
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
      // IMPORTANT: Update Globals.selectedCountry from saved preferences
      Globals.selectedCountry = _prefs!.getString('countryEnglish');
      Globals.selectedGovernorate = _prefs!.getString('governorateEnglish');
      Globals.currentLocation = "$governorate, $country";
      Globals.locationSelected = true;

      // Check both key formats for compatibility
      final lat = _prefs!.getDouble('lat') ?? _prefs!.getDouble('latitude');
      final lng = _prefs!.getDouble('lng') ?? _prefs!.getDouble('longitude');

      if (lat != null && lng != null) {
        Globals.coordinates = Coordinates(lat, lng);
      } else {
        // Fallback to governorate coordinates if available
        Globals.coordinates = Locations().governorateCoordinates[governorate] ??
            Coordinates(30.0444, 31.2357);
      }

      // Save this as last successful location for fallback
      await _saveLastSuccessfulLocation(
        _prefs!.getString('countryEnglish')!,
        _prefs!.getString('governorateEnglish')!,
      );
    }

    await _initializePrayerTimes();
  }

  static Future<void> _initializePrayerTimes() async {
    try {
      print(
          '🔍 DEBUG _initializePrayerTimes: Starting prayer times calculation');

      // Get calculation method based on selected country
      final params = _getCalculationParameters();

      // Calculate prayer times for today using standard method
      // The Adhan library will handle timezone based on coordinates
      final prayerTimes = PrayerTimes.today(Globals.coordinates, params);

      // Format prayer times in 24-hour format
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
      _calculateAndStartCountdown(prayerTimes);
    } catch (e) {
      print('❌ Error calculating prayer times: $e');
      Globals.prayerTimesIsLoading = false;
      Globals.nextPrayer =
          Globals.languageState! ? "Error" : "\u062e\u0637\u0623";
      Globals.nextPrayerTime = Globals.languageState!
          ? "Unable to calculate"
          : "\u062a\u0639\u0631\u062f \u0627\u0644\u062d \u0627\u0627\u0644\u062d";
      Globals.timeRemaining = "";
    }
  }

  static CalculationParameters _getCalculationParameters() {
    final country = Globals.selectedCountry;

    // Use appropriate calculation method based on country
    if (country == 'Saudi Arabia') {
      // Use Umm al-Qura method for Saudi Arabia (official Saudi method)
      final params = CalculationMethod.umm_al_qura.getParameters()
        ..madhab = Madhab.shafi;

      // Check if it's Ramadan and add +30 minutes to Isha
      final now = DateTime.now();
      HijriCalendar.setLocal(
          'en'); // Set to English for consistent month numbering
      final hijriDate = HijriCalendar.fromDate(now);

      final isRamadan = hijriDate.hMonth == 9;

      print('  - Current Gregorian date: ${now.toIso8601String()}');
      print(
          '  - Current Hijri date: ${hijriDate.toFormat("dd MMMM yyyy")} (Month: ${hijriDate.hMonth})');
      print('  - Ramadan detection: $isRamadan');

      if (isRamadan) {
        print(
            '  - Ramadan detected, adding +30 minutes to Isha (120 minutes total)');
        params.ishaInterval =
            120; // 120 minutes after Maghrib during Ramadan (90 + 30)
      } else {
        print('  - Normal Isha interval: 90 minutes after Maghrib');
        // For Umm al-Qura, standard is 90 minutes after Maghrib
        params.ishaInterval = 90;
      }

      return params;
    } else if (country == 'Egypt') {
      print('  - Using Egyptian method for Egypt');
      return CalculationMethod.egyptian.getParameters()..madhab = Madhab.shafi;
    } else if (country == 'UAE' ||
        country == 'Kuwait' ||
        country == 'Qatar' ||
        country == 'Bahrain') {
      print('  - Using Dubai method for Gulf countries');
      return CalculationMethod.dubai.getParameters()..madhab = Madhab.shafi;
    } else if (country == 'Pakistan' ||
        country == 'Bangladesh' ||
        country == 'India') {
      print('  - Using Karachi method for South Asia');
      return CalculationMethod.karachi.getParameters()..madhab = Madhab.shafi;
    } else {
      print('  - Using Muslim World League as default');
      return CalculationMethod.muslim_world_league.getParameters()
        ..madhab = Madhab.shafi;
    }
  }

  static void _calculateAndStartCountdown(
    PrayerTimes prayerTimes,
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
        _setNextPrayer(entry.key, entry.value);
        return;
      }
    }

    // If no prayer left today, get tomorrow's Fajr
    final tomorrow = now.add(const Duration(days: 1));
    final params = _getCalculationParameters();
    final tomorrowPrayerTimes = PrayerTimes(
      Globals.coordinates,
      DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
      params,
    );
    _setNextPrayer('Fajr', tomorrowPrayerTimes.fajr);
  }

  static void _setNextPrayer(
    String name,
    DateTime nextTime,
  ) {
    Globals.nextPrayer = name;
    Globals.nextPrayerTime = DateFormat('HH:mm').format(nextTime);
    Globals.nextArabicPrayer = getArabicPrayerName(name);
    _startCountdown(nextTime);
  }

  static void _startCountdown(DateTime targetTime) {
    Globals.timer?.cancel();
    Globals.timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = targetTime.difference(now);

      if (diff.isNegative) {
        _initializePrayerTimes();
        return;
      }

      final formatted = _formatDuration(diff);
      if (Globals.timeRemaining != formatted) {
        Globals.timeRemaining = formatted;
      }
    });
  }

  static String _formatDuration(Duration diff) {
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    final formatted = '$h:$m:$s';
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

  static String? getLocalizedString(String? en, String? ar) {
    return Globals.languageState! ? en : ar;
  }

  static String convertTo12HourFormat(String time24) {
    try {
      final time = DateFormat("HH:mm").parse(time24);
      return DateFormat(Globals.languageState! ? "h:mm a" : "h:mm")
          .format(time);
    } catch (_) {
      return time24;
    }
  }
}
