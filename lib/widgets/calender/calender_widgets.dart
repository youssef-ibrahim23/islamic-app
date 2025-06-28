// lib/widgets/calendar_widgets.dart

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/calender_services.dart';

class SelectedDateCard extends StatelessWidget {
  final DateTime selectedDay;
  final bool isEnglish;
  final Color primaryColor;
  final Color textColor;

  const SelectedDateCard({
    super.key,
    required this.selectedDay,
    required this.isEnglish,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  isEnglish ? 'Selected Date' : 'التاريخ المحدد',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'Gregorian' : 'الميلادي',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? DateFormat('dd MMMM yyyy').format(selectedDay)
                          : '${Globals.toArabicNumber(selectedDay.day.toString())} ${CalendarServices.monthNamesMap[selectedDay.monthName]} ${Globals.toArabicNumber(selectedDay.year.toString())}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'Hijri' : 'الهجري',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? HijriCalendar.fromDate(selectedDay).toFormat("dd MMMM yyyy")
                          : Globals.toArabicNumber(HijriCalendar.fromDate(selectedDay).toFormat("dd MMMM yyyy")),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
