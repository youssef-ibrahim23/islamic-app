import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/globals.dart';

class DateService {
  static final _arabicNumerals = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  static final _dayNamesMap = {
    'Monday': 'الإثنين',
    'Tuesday': 'الثلاثاء',
    'Wednesday': 'الأربعاء',
    'Thursday': 'الخميس',
    'Friday': 'الجمعة',
    'Saturday': 'السبت',
    'Sunday': 'الأحد',
  };

  static final _monthNamesMap = {
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

  /// Returns the current Gregorian date in English or Arabic based on language setting.
  static String getCurrentGregorianDate() {
    final now = DateTime.now();
    final day = now.day;
    final year = now.year.toString();
    final month = DateFormat("MMMM").format(now);

    if (Globals.languageState == true) {
      return "$month $day, $year";
    } else {
      final arabicDay = _toArabicNumber(day.toString());
      final arabicYear = _toArabicNumber(year);
      final arabicMonth = _monthNamesMap[month] ?? month;

      return "$arabicMonth $arabicDay , $arabicYear";
    }
  }

  /// Returns the current Hijri date formatted based on selected language.
  static String getCurrentHijriDate() {
    HijriCalendar.setLocal(Globals.languageState == true ? "en" : "ar");
    return HijriCalendar.fromDate(DateTime.now()).toFormat("dd MMMM yyyy");
  }

  /// Converts English digits to Arabic numerals.
  static String _toArabicNumber(String input) {
    return input.split('').map((char) => _arabicNumerals[char] ?? char).join('');
  }

  /// Returns the name of the current day in selected language.
  static String getCurrentDayName() {
    final day = DateFormat("EEEE").format(DateTime.now());
    return Globals.languageState == true ? day : _dayNamesMap[day] ?? day;
  }
}
