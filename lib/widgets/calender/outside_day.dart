import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/date_services.dart';

Widget buildOutsideDay(
  BuildContext context,
  DateTime day,
  bool isEnglish,
  Color textColor,
  Color hijriTextColor,
) {
  final hijriDay = DateService.getHijriDayForDate(day);

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isEnglish
              ? day.day.toString()
              : Globals.toArabicNumber(day.day.toString()),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
        Text(
          isEnglish
              ? hijriDay.toString()
              : Globals.toArabicNumber(hijriDay.toString()),
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
      ],
    ),
  );
}
