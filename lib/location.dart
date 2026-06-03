// ignore_for_file: equal_keys_in_map

import 'package:adhan/adhan.dart';
import 'package:islamic_app/globals.dart';

class Locations {
  // Get the appropriate country map based on language
  Map<String, List<String>> get arabCountries =>
      Globals.languageState! ? arabCountriesEnglish : arabCountriesArabic;

  static final Map<String, List<String>> arabCountriesEnglish = {
    'Egypt': [
      'Cairo',
      'Giza',
      'Alexandria',
      'Aswan',
      'Asyut',
      'Al-Beheira',
      'Beni-Suef',
      'Al-Dakahlia',
      'Damietta',
      'Al-Faiyum',
      'Al-Gharbia',
      'Al-Ismailia',
      'Kafr-El-Sheikh',
      'Luxor',
      'Al-Matrouh',
      'Al-Minya',
      'Al-Monufia',
      'New-Valley',
      'North-Sinai',
      'Port-Said',
      'Al-Qalyubia',
      'Qena',
      'Red-Sea',
      'Al-Sharqia',
      'Sohag',
      'South-Sinai',
      'Al-Suez'
    ],
    'Saudi Arabia': [
      'Riyadh',
      'Jeddah',
      'Makkah',
      'Madinah',
      'Eastern-Province',
      'Al-Qassim',
      'Asir',
      'Tabuk',
      'Hail',
      'Northern-Borders',
      'Jazan',
      'Najran',
      'Al-Baha',
      'Al-Jouf'
    ],
  };

  static final Map<String, List<String>> arabCountriesArabic = {
    'مصر': [
      'القاهرة',
      'الجيزة',
      'الإسكندرية',
      'أسوان',
      'أسيوط',
      'البحيرة',
      'بني-سويف',
      'الدقهلية',
      'دمياط',
      'الفيوم',
      'الغربية',
      'الإسماعيلية',
      'كفر-الشيخ',
      'الأقصر',
      'مطروح',
      'المنيا',
      'المنوفية',
      'الوادي-الجديد',
      'شمال-سيناء',
      'بورسعيد',
      'القليوبية',
      'قنا',
      'البحر-الأحمر',
      'الشرقية',
      'سوهاج',
      'جنوب-سيناء',
      'السويس'
    ],
    'السعودية': [
      'الرياض',
      'جدة',
      'مكة-المكرمة',
      'المدينة-المنورة',
      'الشرقية',
      'القصيم',
      'عسير',
      'تبوك',
      'حائل',
      'الحدود-الشمالية',
      'جازان',
      'نجران',
      'الباحة',
      'الجوف'
    ],
  };

  /// Convert English governorate name to Arabic, given the English country and governorate.
  static String? englishGovernorateToArabic(String engCountry, String engGov) {
    final engGovs = arabCountriesEnglish[engCountry];
    final arabGovs = arabCountriesArabic[arabicCountryFromEnglish(engCountry)];

    if (engGovs != null && arabGovs != null) {
      final index = engGovs.indexOf(engGov);
      if (index != -1 && index < arabGovs.length) {
        return arabGovs[index];
      }
    }
    return null;
  }

  /// Convert Arabic country name to English country name
  static String arabicCountryFromEnglish(String engCountry) {
    const countryMap = {
      'Egypt': 'مصر',
      'Saudi Arabia': 'السعودية',
    };

    return countryMap[engCountry] ?? engCountry;
  }

  final Map<String, Coordinates> governorateCoordinates = {
    // Egypt 🇪🇬
    "Cairo": Coordinates(30.0444, 31.2357),
    "Giza": Coordinates(30.0131, 31.2089),
    "Alexandria": Coordinates(31.2001, 29.9187),
    "Aswan": Coordinates(24.0889, 32.8998),
    "Luxor": Coordinates(25.6872, 32.6396),
    "Mansoura": Coordinates(31.0364, 31.3807),
    "Tanta": Coordinates(30.7865, 31.0004),
    "Qena": Coordinates(26.1644, 32.7267),
    "Sohag": Coordinates(26.5569, 31.6948),
    "Beni Suef": Coordinates(29.0667, 31.0833),
    "Minya": Coordinates(28.1099, 30.7503),
    "Assiut": Coordinates(27.1828, 31.1828),
    "Ismailia": Coordinates(30.5833, 32.2667),
    "Suez": Coordinates(29.9668, 32.5498),
    "Port Said": Coordinates(31.2565, 32.2841),
    "Fayoum": Coordinates(29.3084, 30.8428),
    "Damietta": Coordinates(31.4167, 31.8144),
    "Beheira": Coordinates(30.4659, 30.9306),
    "Sharqia": Coordinates(30.7056, 31.6356),
    "Kafr El Sheikh": Coordinates(31.1117, 30.9394),
    "Al-Matrouh": Coordinates(31.3544, 27.2173),
    "Al-Monufia": Coordinates(30.5400, 31.0000),
    "New-Valley": Coordinates(25.7141, 30.5258),
    "North-Sinai": Coordinates(30.7413, 33.9159),
    "Red-Sea": Coordinates(26.5513, 34.9186),
    "South-Sinai": Coordinates(28.2293, 33.9871),
    "Al-Qalyubia": Coordinates(30.3410, 31.2000),

    // Saudi Arabia 🇸🇦
    "Riyadh": Coordinates(24.7136, 46.6753),
    "Jeddah": Coordinates(21.4858, 39.1925),
    "Makkah": Coordinates(21.3891, 39.8579),
    "Madinah": Coordinates(24.5247, 39.5692),
    "Eastern-Province": Coordinates(26.4207, 50.0888),
    "Al-Qassim": Coordinates(26.3325, 43.9749),
    "Asir": Coordinates(18.2164, 42.5053),
    "Tabuk": Coordinates(28.3838, 36.5550),
    "Hail": Coordinates(27.5236, 41.7001),
    "Northern-Borders": Coordinates(30.9756, 41.0381),
    "Jazan": Coordinates(16.8892, 42.5706),
    "Najran": Coordinates(17.5656, 44.2289),
    "Al-Baha": Coordinates(20.0129, 41.4677),
    "Al-Jouf": Coordinates(29.9711, 40.2075),
  };
}