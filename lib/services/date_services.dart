import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/globals.dart';

class DateService {
  static String getCurrentGregorianDate() {
    String currentDayName = DateFormat("EEEE").format(DateTime.now());
    int currentDay = DateTime.now().day;
    String currentMonth = DateFormat("MMMM").format(DateTime.now());
    String currentYear = DateFormat("y").format(DateTime.now());
    
    Map<String, String> dayNamesMap = {
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };

    Map<String, String> monthNamesMap = {
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

    return Globals.languageState!
        ? "${currentMonth} ${currentDay} ,  ${currentYear}"
        : "   ${monthNamesMap[currentMonth]} ${_toArabicNumber(currentDay.toString())} ,  ${_toArabicNumber(currentYear)}  ";
  }

  static String getCurrentHijriDate() {
    Globals.languageState! 
        ? HijriCalendar.setLocal("en")
        : HijriCalendar.setLocal("ar");
    
    return HijriCalendar.fromDate(DateTime.now()).toFormat("dd MMMM yyyy");
  }

  static String _toArabicNumber(String input) {
    Map<String, String> arabicNumerals = {
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

    return input.split('').map((char) => arabicNumerals[char] ?? char).join('');
  }

  static String getCurrentDayName() {
    String englishDay = DateFormat("EEEE").format(DateTime.now());
    
    Map<String, String> dayNamesMap = {
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };

    return Globals.languageState! ? englishDay : dayNamesMap[englishDay]!;
  }
}