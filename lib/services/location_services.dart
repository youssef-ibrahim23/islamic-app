import 'package:adhan/adhan.dart';
import 'package:islamic_app/location.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  /// Saves country, governorate, and corresponding coordinates to SharedPreferences.
  static Future<void> saveLocation({
    required String country,
    required String governorate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save raw country and governorate names
    await prefs.setString('countryEnglish', country);
    await prefs.setString('countryArabic', Locations.arabicCountryFromEnglish(country));
    await prefs.setString('governorateEnglish', governorate);
    await prefs.setString(
      'governorateArabic',
      Locations.englishGovernorateToArabic(country, governorate) ?? governorate,
    );

    // Save coordinates if known
    final Coordinates? coords = Locations().governorateCoordinates[governorate];
    if (coords != null) {
      await prefs.setDouble('latitude', coords.latitude);
      await prefs.setDouble('longitude', coords.longitude);
    } else {
      // Fallback: remove if not found
      await prefs.remove('latitude');
      await prefs.remove('longitude');
    }
  }

  /// Retrieves saved location info including coordinates, or returns null if any info missing.
  static Future<Map<String, dynamic>?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    final String? country = PrayerTimesService.getLocalizedString(
      prefs.getString('countryEnglish'),
      prefs.getString('countryArabic'),
    );
    final String? governorate = PrayerTimesService.getLocalizedString(
      prefs.getString('governorateEnglish'),
      prefs.getString('governorateArabic'),
    );
    final double? latitude = prefs.getDouble('latitude');
    final double? longitude = prefs.getDouble('longitude');

    if (country != null && governorate != null && latitude != null && longitude != null) {
      return {
        'country': country,
        'governorate': governorate,
        'latitude': latitude,
        'longitude': longitude,
      };
    }

    return null;
  }

  /// Clears all saved location data from SharedPreferences.
  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('countryEnglish');
    await prefs.remove('countryArabic');
    await prefs.remove('governorateEnglish');
    await prefs.remove('governorateArabic');
    await prefs.remove('latitude');
    await prefs.remove('longitude');
  }
}
