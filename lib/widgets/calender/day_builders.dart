import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/calender_services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:islamic_app/widgets/app_them.dart';

Widget buildDefaultDay(
  BuildContext context, 
  DateTime day, 
  bool isEnglish, 
  Color textColor, 
  Color hijriTextColor,
) {
  CalendarServices.setHijriLocale(isEnglish);
  final hijri = HijriCalendar.fromDate(day);
  
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        Globals.languageState! ? '${day.day}' : Globals.toArabicNumber('${day.day}'),
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.w500,
          fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
        ),
      ),
      const SizedBox(height: 2),
      Text(
        Globals.languageState! ? hijri.hDay.toString() : Globals.toArabicNumber(hijri.hDay.toString()),
        style: TextStyle(
          fontSize: 12,
          color: hijriTextColor,
          fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
        ),
      ),
    ],
  );
}

Widget buildTodayDay(
  BuildContext context, 
  DateTime day, 
  bool isEnglish, 
  Color primaryColor,
  double cellSize,
) {
  CalendarServices.setHijriLocale(isEnglish);
  final hijri = HijriCalendar.fromDate(day);
  
  return Container(
    width: cellSize,
    height: cellSize,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: primaryColor.withOpacity(0.2),
      shape: BoxShape.circle,
      border: Border.all(color: primaryColor, width: 1.5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isEnglish ? '${day.day}' : Globals.toArabicNumber('${day.day}'),
          style: TextStyle(
            fontSize: 16,
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isEnglish ? hijri.hDay.toString() : Globals.toArabicNumber(hijri.hDay.toString()),
          style: TextStyle(
            fontSize: 12,
            color: primaryColor,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
      ],
    ),
  );
}

Widget buildSelectedDay(
  BuildContext context, 
  DateTime day, 
  bool isEnglish, 
  double cellSize,
) {
  CalendarServices.setHijriLocale(isEnglish);
  final hijri = HijriCalendar.fromDate(day);
  
  return Container(
    width: cellSize,
    height: cellSize,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: primaryColor,
      shape: BoxShape.circle,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isEnglish ? '${day.day}' : Globals.toArabicNumber('${day.day}'),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isEnglish ? hijri.hDay.toString() : Globals.toArabicNumber(hijri.hDay.toString()),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
      ],
    ),
  );
}