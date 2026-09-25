import 'package:adhan/adhan.dart';
import 'package:islamic_app/location.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  /// Save selected country and governorate along with their coordinates
  static Future<void> saveLocation({
    required String country,
    required String governorate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final String arabicCountry = Locations.arabicCountryFromEnglish(country);
    final String arabicGovernorate =
        Locations.englishGovernorateToArabic(country, governorate) ?? governorate;

    await prefs.setString('countryEnglish', country);
    await prefs.setString('countryArabic', arabicCountry);
    await prefs.setString('governorateEnglish', governorate);
    await prefs.setString('governorateArabic', arabicGovernorate);

    final Coordinates? coords = Locations().governorateCoordinates[governorate];
    if (coords != null) {
      // Save to both key formats for compatibility
      await prefs.setDouble('latitude', coords.latitude);
      await prefs.setDouble('longitude', coords.longitude);
      await prefs.setDouble('lat', coords.latitude);
      await prefs.setDouble('lng', coords.longitude);
    } else {
      await prefs.remove('latitude');
      await prefs.remove('longitude');
      await prefs.remove('lat');
      await prefs.remove('lng');
    }
  }

  /// Load previously saved location data
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

  /// Completely remove all stored location data
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
