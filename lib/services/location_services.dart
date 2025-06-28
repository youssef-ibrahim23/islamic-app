import 'package:adhan/adhan.dart';
import 'package:islamic_app/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static Future<void> saveLocation({
    required String country,
    required String governorate,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save country and governorate
    await prefs.setString('country', country);
    await prefs.setString('governorate', governorate);

    // Save coordinates if available
    final Coordinates? coords = Locations().governorateCoordinates[governorate];
    if (coords != null) {
      await prefs.setDouble('latitude', coords.latitude);
      await prefs.setDouble('longitude', coords.longitude);
    }
  }

  static Future<Map<String, dynamic>?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    final String? country = prefs.getString('country');
    final String? governorate = prefs.getString('governorate');
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

  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('country');
    await prefs.remove('governorate');
    await prefs.remove('latitude');
    await prefs.remove('longitude');
  }
}
