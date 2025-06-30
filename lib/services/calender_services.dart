import 'package:hijri/hijri_calendar.dart';

class CalendarServices {
  /// Returns English to Arabic month name mapping
  static Map<String, String> get monthNamesMap => {
        'January': 'يناير',
        'February': 'فبراير',
        'March': 'مارس',
        'April': 'أبريل',
        'May': 'مايو',
        'June': 'يونيو',
        'July': 'يوليو',
        'August': 'أغسطس',
        'September': 'سبتمبر',
        'October': 'أكتوبر',
        'November': 'نوفمبر',
        'December': 'ديسمبر',
      };

  /// Sets Hijri locale based on [isEnglish] flag
  static void setHijriLocale(bool isEnglish) {
    HijriCalendar.setLocal(isEnglish ? 'en' : 'ar');
  }
}

/// Extension to get month name in both English and Arabic
extension GregorianMonthName on DateTime {
  static const _englishMonths = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Returns English month name for this [DateTime]
  String get monthName {
    if (month < 1 || month > 12) return '';
    return _englishMonths[month - 1];
  }

  /// Returns Arabic month name for this [DateTime]
  String get arabicMonthName {
    final english = monthName;
    return CalendarServices.monthNamesMap[english] ?? '';
  }
}
