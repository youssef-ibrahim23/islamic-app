
import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/calender_services.dart';
import 'package:hijri/hijri_calendar.dart';

// For HeaderStyle.titleTextFormatter (returns String)
String formatCalendarHeaderText(DateTime date, bool isEnglish) {
  CalendarServices.setHijriLocale(isEnglish);
  final hijri = HijriCalendar.fromDate(date);
  
  return isEnglish
      ? '${date.monthName} ${date.year}\n${hijri.longMonthName} ${hijri.hYear}'
      : '${CalendarServices.monthNamesMap[date.monthName]} ${Globals.toArabicNumber(date.year.toString())}\n${hijri.longMonthName} ${Globals.toArabicNumber(hijri.hYear.toString())}';
}

// For custom header widget (returns Widget)
Widget buildCalendarHeaderWidget(DateTime date, bool isEnglish, Color primaryColor) {
  return Text(
    formatCalendarHeaderText(date, isEnglish),
    style: TextStyle(
      color: primaryColor,
      fontSize: isEnglish ? 16 : 18,
      fontWeight: FontWeight.bold,
      fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
    ),
  );
}