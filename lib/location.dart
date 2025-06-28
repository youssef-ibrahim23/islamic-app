// ignore_for_file: equal_keys_in_map

import 'package:adhan/adhan.dart';
import 'package:islamic_app/globals.dart';

class Locations{

    // Get the appropriate country map based on language
   Map<String, List<String>> get arabCountries => Globals.languageState! ? arabCountriesEnglish : arabCountriesArabic;

 static final Map<String, List<String>> arabCountriesEnglish = {
  'Egypt': [
    'Cairo', 'Giza', 'Alexandria', 'Aswan', 'Luxor', 'Mansoura', 'Tanta',
    'Qena', 'Sohag', 'Beni Suef', 'Minya', 'Assiut', 'Ismailia', 'Suez',
    'Port Said', 'Fayoum', 'Damietta', 'Beheira', 'Sharqia', 'Kafr El Sheikh'
  ],
  'Saudi Arabia': [
    'Riyadh', 'Jeddah', 'Makkah', 'Madinah', 'Dammam', 'Abha', 'Tabuk',
    'Najran', 'Buraidah', 'Al Khobar', 'Hail', 'Jazan', 'Al Baha', 'Arar'
  ],
  'UAE': [
    'Abu Dhabi', 'Dubai', 'Sharjah', 'Ajman', 'Umm Al Quwain',
    'Ras Al Khaimah', 'Fujairah', 'Al Ain', 'Khor Fakkan'
  ],
  'Jordan': [
    'Amman', 'Zarqa', 'Irbid', 'Aqaba', 'Madaba', 'Jerash', 'Mafraq',
    'Tafilah', 'Karak', 'Balqa', 'Ajloun', 'Ma\'an'
  ],
  'Morocco': [
    'Casablanca', 'Rabat', 'Fes', 'Marrakech', 'Tangier', 'Agadir',
    'Meknes', 'Oujda', 'Kenitra', 'Tetouan', 'Nador', 'Laayoune'
  ],
  'Iraq': [
    'Baghdad', 'Basra', 'Erbil', 'Mosul', 'Najaf', 'Karbala', 'Kirkuk',
    'Sulaymaniyah', 'Diwaniyah', 'Nasiriyah', 'Fallujah', 'Diyala'
  ],
  'Syria': [
    'Damascus', 'Aleppo', 'Homs', 'Latakia', 'Hama', 'Deir ez-Zor',
    'Raqqa', 'Daraa', 'Hasakah', 'Tartus', 'Qamishli', 'Idlib'
  ],
  'Lebanon': [
    'Beirut', 'Tripoli', 'Sidon', 'Tyre', 'Zahle', 'Baalbek', 'Jounieh'
  ],
  'Palestine': [
    'Jerusalem', 'Gaza', 'Hebron', 'Nablus', 'Ramallah', 'Bethlehem',
    'Jenin', 'Tulkarm', 'Qalqilya', 'Salfit', 'Rafah', 'Deir al-Balah'
  ],
  'Sudan': [
    'Khartoum', 'Omdurman', 'Port Sudan', 'Kassala', 'Al-Ubayyid',
    'Nyala', 'Dongola', 'Atbara', 'Gedaref'
  ],
  'Algeria': [
    'Algiers', 'Oran', 'Constantine', 'Annaba', 'Blida', 'Batna',
    'Setif', 'Tlemcen', 'Tizi Ouzou', 'Bejaia', 'Skikda'
  ],
  'Tunisia': [
    'Tunis', 'Sfax', 'Sousse', 'Gabes', 'Bizerte', 'Kairouan', 'Gafsa',
    'Nabeul', 'Tozeur', 'Zarzis', 'Kasserine'
  ],
  'Libya': [
    'Tripoli', 'Benghazi', 'Misrata', 'Zawiya', 'Sirte', 'Sebha', 'Derna',
    'Tobruk', 'Al Bayda', 'Ajdabiya'
  ],
  'Yemen': [
    'Sana\'a', 'Aden', 'Taiz', 'Al Hudaydah', 'Ibb', 'Mukalla', 'Dhamar',
    'Amran', 'Marib', 'Al Mahwit', 'Saada', 'Shabwah'
  ],
  'Oman': [
    'Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Sur', 'Ibri', 'Barka',
    'Rustaq', 'Bahla', 'Duqm'
  ],
  'Qatar': [
    'Doha', 'Al Rayyan', 'Al Wakrah', 'Umm Salal', 'Al Khor', 'Al Daayen',
    'Al Shahaniya'
  ],
  'Bahrain': [
    'Manama', 'Muharraq', 'Riffa', 'Isa Town', 'Hamad Town', 'Sitra',
    'Budaiya'
  ],
  'Kuwait': [
    'Kuwait City', 'Hawalli', 'Salmiya', 'Fahaheel', 'Farwaniya', 'Jahra',
    'Ahmadi'
  ],
  'Mauritania': [
    'Nouakchott', 'Nouadhibou', 'Zouerate', 'Kiffa', 'Kaédi', 'Rosso'
  ],
  'Comoros': [
    'Moroni', 'Mutsamudu', 'Fomboni', 'Domoni', 'Iconi', 'Tsamahou'
  ],
  'Djibouti': [
    'Djibouti City', 'Ali Sabieh', 'Tadjourah', 'Obock', 'Dikhil', 'Arta'
  ],
  'Somalia': [
    'Mogadishu', 'Hargeisa', 'Bosaso', 'Kismayo', 'Baidoa', 'Galkayo',
    'Garowe'
  ]
};

 static final Map<String, List<String>> arabCountriesArabic = {
  'مصر': [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'أسوان', 'الأقصر', 'المنصورة', 'طنطا',
    'قنا', 'سوهاج', 'بني سويف', 'المنيا', 'أسيوط', 'الإسماعيلية', 'السويس',
    'بورسعيد', 'الفيوم', 'دمياط', 'البحيرة', 'الشرقية', 'كفر الشيخ'
  ],
  'السعودية': [
    'الرياض', 'جدة', 'مكة', 'المدينة المنورة', 'الدمام', 'أبها', 'تبوك',
    'نجران', 'بريدة', 'الخبر', 'حائل', 'جازان', 'الباحة', 'عرعر'
  ],
  'الإمارات': [
    'أبو ظبي', 'دبي', 'الشارقة', 'عجمان', 'أم القيوين', 'رأس الخيمة',
    'الفجيرة', 'العين', 'خورفكان'
  ],
  'الأردن': [
    'عمان', 'الزرقاء', 'إربد', 'العقبة', 'مأدبا', 'جرش', 'المفرق',
    'الطفيلة', 'الكرك', 'البلقاء', 'عجلون', 'معان'
  ],
  'المغرب': [
    'الدار البيضاء', 'الرباط', 'فاس', 'مراكش', 'طنجة', 'أكادير',
    'مكناس', 'وجدة', 'القنيطرة', 'تطوان', 'الناظور', 'العيون'
  ],
  'العراق': [
    'بغداد', 'البصرة', 'أربيل', 'الموصل', 'النجف', 'كربلاء', 'كركوك',
    'السليمانية', 'الديوانية', 'الناصرية', 'الفلوجة', 'ديالى'
  ],
  'سوريا': [
    'دمشق', 'حلب', 'حمص', 'اللاذقية', 'حماة', 'دير الزور', 'الرقة',
    'درعا', 'الحسكة', 'طرطوس', 'القامشلي', 'إدلب'
  ],
  'لبنان': [
    'بيروت', 'طرابلس', 'صيدا', 'صور', 'زحلة', 'بعلبك', 'جونية'
  ],
  'فلسطين': [
    'القدس', 'غزة', 'الخليل', 'نابلس', 'رام الله', 'بيت لحم',
    'جنين', 'طولكرم', 'قلقيلية', 'سلفيت', 'رفح', 'دير البلح'
  ],
  'السودان': [
    'الخرطوم', 'أم درمان', 'بورتسودان', 'كسلا', 'الأبيض', 'نيالا',
    'دنقلا', 'عطبرة', 'القضارف'
  ],
  'الجزائر': [
    'الجزائر', 'وهران', 'قسنطينة', 'عنابة', 'البليدة', 'باتنة',
    'سطيف', 'تلمسان', 'تيزي وزو', 'بجاية', 'سكيكدة'
  ],
  'تونس': [
    'تونس', 'صفاقس', 'سوسة', 'قابس', 'بنزرت', 'القيروان', 'قفصة',
    'نابل', 'توزر', 'جرجيس', 'القصرين'
  ],
  'ليبيا': [
    'طرابلس', 'بنغازي', 'مصراتة', 'الزاوية', 'سرت', 'سبها', 'درنة',
    'طبرق', 'البيضاء', 'اجدابيا'
  ],
  'اليمن': [
    'صنعاء', 'عدن', 'تعز', 'الحديدة', 'إب', 'المكلا', 'ذمار',
    'عمران', 'مأرب', 'المحويت', 'صعدة', 'شبوة'
  ],
  'عُمان': [
    'مسقط', 'صلالة', 'صحار', 'نزوى', 'صور', 'عبري', 'بركاء',
    'الرستاق', 'بهلاء', 'الدقم'
  ],
  'قطر': [
    'الدوحة', 'الريان', 'الوكرة', 'أم صلال', 'الخور', 'الضعاين',
    'الشحانية'
  ],
  'البحرين': [
    'المنامة', 'المحرق', 'الرفاع', 'مدينة عيسى', 'مدينة حمد', 'سترة',
    'البديع'
  ],
  'الكويت': [
    'الكويت', 'حولي', 'السالمية', 'الفحيحيل', 'الفروانية', 'الجهراء',
    'الأحمدي'
  ],
  'موريتانيا': [
    'نواكشوط', 'نواذيبو', 'ازويرات', 'كيفة', 'كيهيدي', 'روصو'
  ],
  'جزر القمر': [
    'موروني', 'متسامودو', 'فومبوني', 'دوموني', 'إيكوني', 'تساماهو'
  ],
  'جيبوتي': [
    'جيبوتي', 'علي صبيح', 'تدجوره', 'أوبوك', 'دخيل', 'أرتا'
  ],
  'الصومال': [
    'مقديشو', 'هرجيسا', 'بوصاصو', 'كيسمايو', 'بيدوا', 'جالكعيو',
    'غرووي'
  ]
};

/// Convert Arabic governorate name to English, given the Arabic country and Arabic governorate.
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
    'UAE': 'الإمارات',
    'Jordan': 'الأردن',
    'Morocco': 'المغرب',
    'Iraq': 'العراق',
    'Syria': 'سوريا',
    'Lebanon': 'لبنان',
    'Palestine': 'فلسطين',
    'Sudan': 'السودان',
    'Algeria': 'الجزائر',
    'Tunisia': 'تونس',
    'Libya': 'ليبيا',
    'Yemen': 'اليمن',
    'Oman': 'عُمان',
    'Qatar': 'قطر',
    'Bahrain': 'البحرين',
    'Kuwait': 'الكويت',
    'Mauritania': 'موريتانيا',
    'Comoros': 'جزر القمر',
    'Djibouti': 'جيبوتي',
    'Somalia': 'الصومال',
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
  "القاهرة": Coordinates(30.0444, 31.2357),
  "الجيزة": Coordinates(30.0131, 31.2089),
  "الإسكندرية": Coordinates(31.2001, 29.9187),
  "أسوان": Coordinates(24.0889, 32.8998),
  "الأقصر": Coordinates(25.6872, 32.6396),
  "المنصورة": Coordinates(31.0364, 31.3807),
  "طنطا": Coordinates(30.7865, 31.0004),
  "قنا": Coordinates(26.1644, 32.7267),
  "سوهاج": Coordinates(26.5569, 31.6948),
  "بني سويف": Coordinates(29.0667, 31.0833),
  "المنيا": Coordinates(28.1099, 30.7503),
  "أسيوط": Coordinates(27.1828, 31.1828),
  "الإسماعيلية": Coordinates(30.5833, 32.2667),
  "السويس": Coordinates(29.9668, 32.5498),
  "بورسعيد": Coordinates(31.2565, 32.2841),
  "الفيوم": Coordinates(29.3084, 30.8428),
  "دمياط": Coordinates(31.4167, 31.8144),
  "البحيرة": Coordinates(30.4659, 30.9306),
  "الشرقية": Coordinates(30.7056, 31.6356),
  "كفر الشيخ": Coordinates(31.1117, 30.9394),

  // Saudi Arabia 🇸🇦
  "Riyadh": Coordinates(24.7136, 46.6753),
  "Jeddah": Coordinates(21.4858, 39.1925),
  "Makkah": Coordinates(21.3891, 39.8579),
  "Madinah": Coordinates(24.5247, 39.5692),
  "Dammam": Coordinates(26.4207, 50.0888),
  "Abha": Coordinates(18.2164, 42.5053),
  "Tabuk": Coordinates(28.3838, 36.5550),
  "Najran": Coordinates(17.5656, 44.2289),
  "Buraidah": Coordinates(26.3333, 43.9667),
  "Al Khobar": Coordinates(26.2172, 50.1971),
  "Hail": Coordinates(27.5236, 41.7001),
  "Jazan": Coordinates(16.8892, 42.5706),
  "Al Baha": Coordinates(20.0129, 41.4677),
  "Arar": Coordinates(30.9756, 41.0381),
  "الرياض": Coordinates(24.7136, 46.6753),
  "جدة": Coordinates(21.4858, 39.1925),
  "مكة": Coordinates(21.3891, 39.8579),
  "المدينة المنورة": Coordinates(24.5247, 39.5692),
  "الدمام": Coordinates(26.4207, 50.0888),
  "أبها": Coordinates(18.2164, 42.5053),
  "تبوك": Coordinates(28.3838, 36.5550),
  "نجران": Coordinates(17.5656, 44.2289),
  "بريدة": Coordinates(26.3333, 43.9667),
  "الخبر": Coordinates(26.2172, 50.1971),
  "حائل": Coordinates(27.5236, 41.7001),
  "جازان": Coordinates(16.8892, 42.5706),
  "الباحة": Coordinates(20.0129, 41.4677),
  "عرعر": Coordinates(30.9756, 41.0381),

  // UAE 🇦🇪
  "Abu Dhabi": Coordinates(24.4539, 54.3773),
  "Dubai": Coordinates(25.2769, 55.2962),
  "Sharjah": Coordinates(25.3463, 55.4209),
  "Ajman": Coordinates(25.4052, 55.5136),
  "Umm Al Quwain": Coordinates(25.5653, 55.5533),
  "Ras Al Khaimah": Coordinates(25.7895, 55.9432),
  "Fujairah": Coordinates(25.1288, 56.3265),
  "Al Ain": Coordinates(24.1917, 55.7606),
  "Khor Fakkan": Coordinates(25.3314, 56.3420),
  "أبو ظبي": Coordinates(24.4539, 54.3773),
  "دبي": Coordinates(25.2769, 55.2962),
  "الشارقة": Coordinates(25.3463, 55.4209),
  "عجمان": Coordinates(25.4052, 55.5136),
  "أم القيوين": Coordinates(25.5653, 55.5533),
  "رأس الخيمة": Coordinates(25.7895, 55.9432),
  "الفجيرة": Coordinates(25.1288, 56.3265),
  "العين": Coordinates(24.1917, 55.7606),
  "خورفكان": Coordinates(25.3314, 56.3420),

  // Jordan 🇯🇴
  "Amman": Coordinates(31.9539, 35.9106),
  "Zarqa": Coordinates(32.0728, 36.0880),
  "Irbid": Coordinates(32.5569, 35.8490),
  "Aqaba": Coordinates(29.5328, 35.0061),
  "Madaba": Coordinates(31.7167, 35.8000),
  "Jerash": Coordinates(32.2808, 35.8993),
  "Mafraq": Coordinates(32.3417, 36.2020),
  "Tafilah": Coordinates(30.8333, 35.6000),
  "Karak": Coordinates(31.1833, 35.7000),
  "Balqa": Coordinates(32.0667, 35.7333),
  "Ajloun": Coordinates(32.3333, 35.7500),
  "Ma'an": Coordinates(30.1920, 35.7360),
  "عمان": Coordinates(31.9539, 35.9106),
  "الزرقاء": Coordinates(32.0728, 36.0880),
  "إربد": Coordinates(32.5569, 35.8490),
  "العقبة": Coordinates(29.5328, 35.0061),
  "مأدبا": Coordinates(31.7167, 35.8000),
  "جرش": Coordinates(32.2808, 35.8993),
  "المفرق": Coordinates(32.3417, 36.2020),
  "الطفيلة": Coordinates(30.8333, 35.6000),
  "الكرك": Coordinates(31.1833, 35.7000),
  "البلقاء": Coordinates(32.0667, 35.7333),
  "عجلون": Coordinates(32.3333, 35.7500),
  "معان": Coordinates(30.1920, 35.7360),

  // Morocco 🇲🇦
  "Casablanca": Coordinates(33.5731, -7.5898),
  "Rabat": Coordinates(34.0209, -6.8416),
  "Fes": Coordinates(34.0433, -5.0033),
  "Marrakech": Coordinates(31.6295, -7.9811),
  "Tangier": Coordinates(35.7595, -5.8340),
  "Agadir": Coordinates(30.4278, -9.5981),
  "Meknes": Coordinates(33.8833, -5.5500),
  "Oujda": Coordinates(34.6867, -1.9114),
  "Kenitra": Coordinates(34.2500, -6.5833),
  "Tetouan": Coordinates(35.5764, -5.3684),
  "Nador": Coordinates(35.1667, -2.9333),
  "Laayoune": Coordinates(27.1536, -13.2033),
  "الدار البيضاء": Coordinates(33.5731, -7.5898),
  "الرباط": Coordinates(34.0209, -6.8416),
  "فاس": Coordinates(34.0433, -5.0033),
  "مراكش": Coordinates(31.6295, -7.9811),
  "طنجة": Coordinates(35.7595, -5.8340),
  "أكادير": Coordinates(30.4278, -9.5981),
  "مكناس": Coordinates(33.8833, -5.5500),
  "وجدة": Coordinates(34.6867, -1.9114),
  "القنيطرة": Coordinates(34.2500, -6.5833),
  "تطوان": Coordinates(35.5764, -5.3684),
  "الناظور": Coordinates(35.1667, -2.9333),
  "العيون": Coordinates(27.1536, -13.2033),

  // Iraq 🇮🇶
  "Baghdad": Coordinates(33.3152, 44.3661),
  "Basra": Coordinates(30.5150, 47.8101),
  "Erbil": Coordinates(36.1900, 44.0089),
  "Mosul": Coordinates(36.3400, 43.1300),
  "Najaf": Coordinates(32.0250, 44.3467),
  "Karbala": Coordinates(32.6167, 44.0333),
  "Kirkuk": Coordinates(35.4667, 44.3167),
  "Sulaymaniyah": Coordinates(35.5572, 45.4356),
  "Diwaniyah": Coordinates(31.9833, 44.9333),
  "Nasiriyah": Coordinates(31.0500, 46.2667),
  "Fallujah": Coordinates(33.3500, 43.7833),
  "Diyala": Coordinates(33.7500, 45.0500),
  "بغداد": Coordinates(33.3152, 44.3661),
  "البصرة": Coordinates(30.5150, 47.8101),
  "أربيل": Coordinates(36.1900, 44.0089),
  "الموصل": Coordinates(36.3400, 43.1300),
  "النجف": Coordinates(32.0250, 44.3467),
  "كربلاء": Coordinates(32.6167, 44.0333),
  "كركوك": Coordinates(35.4667, 44.3167),
  "السليمانية": Coordinates(35.5572, 45.4356),
  "الديوانية": Coordinates(31.9833, 44.9333),
  "الناصرية": Coordinates(31.0500, 46.2667),
  "الفلوجة": Coordinates(33.3500, 43.7833),
  "ديالى": Coordinates(33.7500, 45.0500),

  // Syria 🇸🇾
  "Damascus": Coordinates(33.5138, 36.2765),
  "Aleppo": Coordinates(36.2021, 37.1343),
  "Homs": Coordinates(34.7333, 36.7167),
  "Latakia": Coordinates(35.5236, 35.7917),
  "Hama": Coordinates(35.1333, 36.7500),
  "Deir ez-Zor": Coordinates(35.3333, 40.1500),
  "Raqqa": Coordinates(35.9500, 39.0167),
  "Daraa": Coordinates(32.6250, 36.1050),
  "Hasakah": Coordinates(36.4833, 40.7500),
  "Tartus": Coordinates(34.8833, 35.8833),
  "Qamishli": Coordinates(37.0500, 41.2167),
  "Idlib": Coordinates(35.9333, 36.6333),
  "دمشق": Coordinates(33.5138, 36.2765),
  "حلب": Coordinates(36.2021, 37.1343),
  "حمص": Coordinates(34.7333, 36.7167),
  "اللاذقية": Coordinates(35.5236, 35.7917),
  "حماة": Coordinates(35.1333, 36.7500),
  "دير الزور": Coordinates(35.3333, 40.1500),
  "الرقة": Coordinates(35.9500, 39.0167),
  "درعا": Coordinates(32.6250, 36.1050),
  "الحسكة": Coordinates(36.4833, 40.7500),
  "طرطوس": Coordinates(34.8833, 35.8833),
  "القامشلي": Coordinates(37.0500, 41.2167),
  "إدلب": Coordinates(35.9333, 36.6333),

  // Lebanon 🇱🇧
  "Beirut": Coordinates(33.8938, 35.5018),
  "Tripoli": Coordinates(34.4367, 35.8344),
  "Sidon": Coordinates(33.5606, 35.3758),
  "Tyre": Coordinates(33.2667, 35.2000),
  "Zahle": Coordinates(33.8439, 35.9072),
  "Baalbek": Coordinates(34.0058, 36.2181),
  "Jounieh": Coordinates(33.9800, 35.6167),
  "بيروت": Coordinates(33.8938, 35.5018),
  "طرابلس": Coordinates(34.4367, 35.8344),
  "صيدا": Coordinates(33.5606, 35.3758),
  "صور": Coordinates(33.2667, 35.2000),
  "زحلة": Coordinates(33.8439, 35.9072),
  "بعلبك": Coordinates(34.0058, 36.2181),
  "جونية": Coordinates(33.9800, 35.6167),

  // Palestine 🇵🇸
  "Jerusalem": Coordinates(31.7683, 35.2137),
  "Gaza": Coordinates(31.5017, 34.4668),
  "Hebron": Coordinates(31.5326, 35.1018),
  "Nablus": Coordinates(32.2211, 35.2544),
  "Ramallah": Coordinates(31.8996, 35.2042),
  "Bethlehem": Coordinates(31.7054, 35.2025),
  "Jenin": Coordinates(32.4619, 35.3000),
  "Tulkarm": Coordinates(32.3106, 35.0286),
  "Qalqilya": Coordinates(32.1906, 34.9708),
  "Salfit": Coordinates(32.0833, 35.1667),
  "Rafah": Coordinates(31.2969, 34.2436),
  "Deir al-Balah": Coordinates(31.4167, 34.3500),
  "القدس": Coordinates(31.7683, 35.2137),
  "غزة": Coordinates(31.5017, 34.4668),
  "الخليل": Coordinates(31.5326, 35.1018),
  "نابلس": Coordinates(32.2211, 35.2544),
  "رام الله": Coordinates(31.8996, 35.2042),
  "بيت لحم": Coordinates(31.7054, 35.2025),
  "جنين": Coordinates(32.4619, 35.3000),
  "طولكرم": Coordinates(32.3106, 35.0286),
  "قلقيلية": Coordinates(32.1906, 34.9708),
  "سلفيت": Coordinates(32.0833, 35.1667),
  "رفح": Coordinates(31.2969, 34.2436),
  "دير البلح": Coordinates(31.4167, 34.3500),

  // Sudan 🇸🇩
  "Khartoum": Coordinates(15.5007, 32.5599),
  "Omdurman": Coordinates(15.6500, 32.4833),
  "Port Sudan": Coordinates(19.6158, 37.2164),
  "Kassala": Coordinates(15.4500, 36.4000),
  "Al-Ubayyid": Coordinates(13.1833, 30.2167),
  "Nyala": Coordinates(12.0500, 24.8833),
  "Dongola": Coordinates(19.1667, 30.4500),
  "Atbara": Coordinates(17.7167, 33.9833),
  "Gedaref": Coordinates(14.0333, 35.3833),
  "الخرطوم": Coordinates(15.5007, 32.5599),
  "أم درمان": Coordinates(15.6500, 32.4833),
  "بورتسودان": Coordinates(19.6158, 37.2164),
  "كسلا": Coordinates(15.4500, 36.4000),
  "الأبيض": Coordinates(13.1833, 30.2167),
  "نيالا": Coordinates(12.0500, 24.8833),
  "دنقلا": Coordinates(19.1667, 30.4500),
  "عطبرة": Coordinates(17.7167, 33.9833),
  "القضارف": Coordinates(14.0333, 35.3833),

  // Algeria 🇩🇿
  "Algiers": Coordinates(36.7538, 3.0588),
  "Oran": Coordinates(35.6911, -0.6417),
  "Constantine": Coordinates(36.3650, 6.6147),
  "Annaba": Coordinates(36.9000, 7.7667),
  "Blida": Coordinates(36.4722, 2.8333),
  "Batna": Coordinates(35.5500, 6.1667),
  "Setif": Coordinates(36.1900, 5.4100),
  "Tlemcen": Coordinates(34.8783, -1.3150),
  "Tizi Ouzou": Coordinates(36.7167, 4.0500),
  "Bejaia": Coordinates(36.7500, 5.0667),
  "Skikda": Coordinates(36.8667, 6.9000),
  "الجزائر": Coordinates(36.7538, 3.0588),
  "وهران": Coordinates(35.6911, -0.6417),
  "قسنطينة": Coordinates(36.3650, 6.6147),
  "عنابة": Coordinates(36.9000, 7.7667),
  "البليدة": Coordinates(36.4722, 2.8333),
  "باتنة": Coordinates(35.5500, 6.1667),
  "سطيف": Coordinates(36.1900, 5.4100),
  "تلمسان": Coordinates(34.8783, -1.3150),
  "تيزي وزو": Coordinates(36.7167, 4.0500),
  "بجاية": Coordinates(36.7500, 5.0667),
  "سكيكدة": Coordinates(36.8667, 6.9000),

  // Tunisia 🇹🇳
  "Tunis": Coordinates(36.8008, 10.1800),
  "Sfax": Coordinates(34.7400, 10.7600),
  "Sousse": Coordinates(35.8254, 10.6360),
  "Gabes": Coordinates(33.8814, 10.0983),
  "Bizerte": Coordinates(37.2744, 9.8739),
  "Kairouan": Coordinates(35.6772, 10.1008),
  "Gafsa": Coordinates(34.4167, 8.7833),
  "Nabeul": Coordinates(36.4500, 10.7333),
  "Tozeur": Coordinates(33.9197, 8.1336),
  "Zarzis": Coordinates(33.5000, 11.1167),
  "Kasserine": Coordinates(35.1667, 8.8333),
  "تونس": Coordinates(36.8008, 10.1800),
  "صفاقس": Coordinates(34.7400, 10.7600),
  "سوسة": Coordinates(35.8254, 10.6360),
  "قابس": Coordinates(33.8814, 10.0983),
  "بنزرت": Coordinates(37.2744, 9.8739),
  "القيروان": Coordinates(35.6772, 10.1008),
  "قفصة": Coordinates(34.4167, 8.7833),
  "نابل": Coordinates(36.4500, 10.7333),
  "توزر": Coordinates(33.9197, 8.1336),
  "جرجيس": Coordinates(33.5000, 11.1167),
  "القصرين": Coordinates(35.1667, 8.8333),

  // Libya 🇱🇾
  "Tripoli": Coordinates(32.8872, 13.1913),
  "Benghazi": Coordinates(32.1167, 20.0667),
  "Misrata": Coordinates(32.3778, 15.0906),
  "Zawiya": Coordinates(32.7500, 12.7167),
  "Sirte": Coordinates(31.2000, 16.5833),
  "Sebha": Coordinates(27.0333, 14.4333),
  "Derna": Coordinates(32.7667, 22.6333),
  "Tobruk": Coordinates(32.0833, 23.9667),
  "Al Bayda": Coordinates(32.7628, 21.7550),
  "Ajdabiya": Coordinates(30.7500, 20.2167),
  "طرابلس": Coordinates(32.8872, 13.1913),
  "بنغازي": Coordinates(32.1167, 20.0667),
  "مصراتة": Coordinates(32.3778, 15.0906),
  "الزاوية": Coordinates(32.7500, 12.7167),
  "سرت": Coordinates(31.2000, 16.5833),
  "سبها": Coordinates(27.0333, 14.4333),
  "درنة": Coordinates(32.7667, 22.6333),
  "طبرق": Coordinates(32.0833, 23.9667),
  "البيضاء": Coordinates(32.7628, 21.7550),
  "اجدابيا": Coordinates(30.7500, 20.2167),

  // Yemen 🇾🇪
  "Sana'a": Coordinates(15.3694, 44.1910),
  "Aden": Coordinates(12.8000, 45.0333),
  "Taiz": Coordinates(13.5789, 44.0219),
  "Al Hudaydah": Coordinates(14.8022, 42.9511),
  "Ibb": Coordinates(13.9667, 44.1667),
  "Mukalla": Coordinates(14.5333, 49.1333),
  "Dhamar": Coordinates(14.5500, 44.4017),
  "Amran": Coordinates(15.6594, 43.9439),
  "Marib": Coordinates(15.4600, 45.3250),
  "Al Mahwit": Coordinates(15.4700, 43.5458),
  "Saada": Coordinates(16.9400, 43.7500),
  "Shabwah": Coordinates(14.5500, 46.8333),
  "صنعاء": Coordinates(15.3694, 44.1910),
  "عدن": Coordinates(12.8000, 45.0333),
  "تعز": Coordinates(13.5789, 44.0219),
  "الحديدة": Coordinates(14.8022, 42.9511),
  "إب": Coordinates(13.9667, 44.1667),
  "المكلا": Coordinates(14.5333, 49.1333),
  "ذمار": Coordinates(14.5500, 44.4017),
  "عمران": Coordinates(15.6594, 43.9439),
  "مأرب": Coordinates(15.4600, 45.3250),
  "المحويت": Coordinates(15.4700, 43.5458),
  "صعدة": Coordinates(16.9400, 43.7500),
  "شبوة": Coordinates(14.5500, 46.8333),

  // Oman 🇴🇲
  "Muscat": Coordinates(23.6139, 58.5922),
  "Salalah": Coordinates(17.0151, 54.0924),
  "Sohar": Coordinates(24.3647, 56.7467),
  "Nizwa": Coordinates(22.9333, 57.5333),
  "Sur": Coordinates(22.5667, 59.5289),
  "Ibri": Coordinates(23.2254, 56.5157),
  "Barka": Coordinates(23.6786, 57.8867),
  "Rustaq": Coordinates(23.3908, 57.4244),
  "Bahla": Coordinates(22.9667, 57.3000),
  "Duqm": Coordinates(19.6667, 57.6333),
  "مسقط": Coordinates(23.6139, 58.5922),
  "صلالة": Coordinates(17.0151, 54.0924),
  "صحار": Coordinates(24.3647, 56.7467),
  "نزوى": Coordinates(22.9333, 57.5333),
  "صور": Coordinates(22.5667, 59.5289),
  "عبري": Coordinates(23.2254, 56.5157),
  "بركاء": Coordinates(23.6786, 57.8867),
  "الرستاق": Coordinates(23.3908, 57.4244),
  "بهلاء": Coordinates(22.9667, 57.3000),
  "الدقم": Coordinates(19.6667, 57.6333),

  // Qatar 🇶🇦
  "Doha": Coordinates(25.2867, 51.5333),
  "Al Rayyan": Coordinates(25.2919, 51.4244),
  "Al Wakrah": Coordinates(25.1715, 51.6034),
  "Umm Salal": Coordinates(25.4697, 51.3975),
  "Al Khor": Coordinates(25.6839, 51.5058),
  "Al Daayen": Coordinates(25.5778, 51.4831),
  "Al Shahaniya": Coordinates(25.3694, 51.1950),
  "الدوحة": Coordinates(25.2867, 51.5333),
  "الريان": Coordinates(25.2919, 51.4244),
  "الوكرة": Coordinates(25.1715, 51.6034),
  "أم صلال": Coordinates(25.4697, 51.3975),
  "الخور": Coordinates(25.6839, 51.5058),
  "الضعاين": Coordinates(25.5778, 51.4831),
  "الشحانية": Coordinates(25.3694, 51.1950),

  // Bahrain 🇧🇭
  "Manama": Coordinates(26.2250, 50.5775),
  "Muharraq": Coordinates(26.2500, 50.6167),
  "Riffa": Coordinates(26.1297, 50.5550),
  "Isa Town": Coordinates(26.1736, 50.5478),
  "Hamad Town": Coordinates(26.1128, 50.5139),
  "Sitra": Coordinates(26.1550, 50.6206),
  "Budaiya": Coordinates(26.2081, 50.4689),
  "المنامة": Coordinates(26.2250, 50.5775),
  "المحرق": Coordinates(26.2500, 50.6167),
  "الرفاع": Coordinates(26.1297, 50.5550),
  "مدينة عيسى": Coordinates(26.1736, 50.5478),
  "مدينة حمد": Coordinates(26.1128, 50.5139),
  "سترة": Coordinates(26.1550, 50.6206),
  "البديع": Coordinates(26.2081, 50.4689),

  // Kuwait 🇰🇼
  "Kuwait City": Coordinates(29.3759, 47.9774),
  "Hawalli": Coordinates(29.3333, 48.0833),
  "Salmiya": Coordinates(29.3333, 48.0833),
  "Fahaheel": Coordinates(29.0833, 48.1333),
  "Farwaniya": Coordinates(29.2775, 47.9586),
  "Jahra": Coordinates(29.3375, 47.6581),
  "Ahmadi": Coordinates(29.0769, 48.0839),
  "الكويت": Coordinates(29.3759, 47.9774),
  "حولي": Coordinates(29.3333, 48.0833),
  "السالمية": Coordinates(29.3333, 48.0833),
  "الفحيحيل": Coordinates(29.0833, 48.1333),
  "الفروانية": Coordinates(29.2775, 47.9586),
  "الجهراء": Coordinates(29.3375, 47.6581),
  "الأحمدي": Coordinates(29.0769, 48.0839),

  // Mauritania 🇲🇷
  "Nouakchott": Coordinates(18.0858, -15.9785),
  "Nouadhibou": Coordinates(20.9333, -17.0333),
  "Zouerate": Coordinates(22.7333, -12.4667),
  "Kiffa": Coordinates(16.6167, -11.4000),
  "Kaédi": Coordinates(16.1500, -13.5000),
  "Rosso": Coordinates(16.5000, -15.8000),
  "نواكشوط": Coordinates(18.0858, -15.9785),
  "نواذيبو": Coordinates(20.9333, -17.0333),
  "ازويرات": Coordinates(22.7333, -12.4667),
  "كيفة": Coordinates(16.6167, -11.4000),
  "كيهيدي": Coordinates(16.1500, -13.5000),
  "روصو": Coordinates(16.5000, -15.8000),

  // Comoros 🇰🇲
  "Moroni": Coordinates(-11.7036, 43.2536),
  "Mutsamudu": Coordinates(-12.1667, 44.4000),
  "Fomboni": Coordinates(-12.2833, 43.7333),
  "Domoni": Coordinates(-12.2500, 44.5333),
  "Iconi": Coordinates(-11.7167, 43.2500),
  "Tsamahou": Coordinates(-12.2167, 44.5167),
  "موروني": Coordinates(-11.7036, 43.2536),
  "متسامودو": Coordinates(-12.1667, 44.4000),
  "فومبوني": Coordinates(-12.2833, 43.7333),
  "دوموني": Coordinates(-12.2500, 44.5333),
  "إيكوني": Coordinates(-11.7167, 43.2500),
  "تساماهو": Coordinates(-12.2167, 44.5167),

  // Djibouti 🇩🇯
  "Djibouti City": Coordinates(11.5950, 43.1481),
  "Ali Sabieh": Coordinates(11.1558, 42.7125),
  "Tadjourah": Coordinates(11.7833, 42.8833),
  "Obock": Coordinates(11.9667, 43.3000),
  "Dikhil": Coordinates(11.1086, 42.3667),
  "Arta": Coordinates(11.5167, 42.8500),
  "جيبوتي": Coordinates(11.5950, 43.1481),
  "علي صبيح": Coordinates(11.1558, 42.7125),
  "تدجوره": Coordinates(11.7833, 42.8833),
    "أوبوك": Coordinates(11.9667, 43.3000),
  "دخيل": Coordinates(11.1086, 42.3667),
  "أرتا": Coordinates(11.5167, 42.8500),

  // Somalia 🇸🇴
  "Mogadishu": Coordinates(2.0469, 45.3182),
  "Hargeisa": Coordinates(9.5632, 44.0672),
  "Bosaso": Coordinates(11.2842, 49.1816),
  "Kismayo": Coordinates(-0.3582, 42.5454),
  "Baidoa": Coordinates(3.1138, 43.6498),
  "Galkayo": Coordinates(6.7697, 47.4308),
  "Garowe": Coordinates(8.4095, 48.4841),
  "مقديشو": Coordinates(2.0469, 45.3182),
  "هرجيسا": Coordinates(9.5632, 44.0672),
  "بوصاصو": Coordinates(11.2842, 49.1816),
  "كيسمايو": Coordinates(-0.3582, 42.5454),
  "بيدوا": Coordinates(3.1138, 43.6498),
  "جالكعيو": Coordinates(6.7697, 47.4308),
  "غرووي": Coordinates(8.4095, 48.4841),

};
}