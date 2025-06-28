// lib/services/calendar_services.dart

import 'package:hijri/hijri_calendar.dart';

class CalendarServices {
  static const Map<String, String> monthNamesMap = {
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

  static void setHijriLocale(bool isEnglish) {
    HijriCalendar.setLocal(isEnglish ? "en" : "ar");
  }
}

extension GregorianMonthName on DateTime {
  String get monthName {
    const months = [
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
      'December'
    ];
    return months[month - 1];
  }
}
