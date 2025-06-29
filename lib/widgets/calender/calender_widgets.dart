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
  final double elevation;
  final BorderRadius borderRadius;

  const SelectedDateCard({
    super.key,
    required this.selectedDay,
    required this.isEnglish,
    required this.primaryColor,
    required this.textColor,
    this.elevation = 4.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriCalendar.fromDate(selectedDay);
    final gregorianDate = selectedDay;

    return Material(
      
      elevation: elevation,
      borderRadius: borderRadius,
      color: const Color(0xFFF8F5EF),
      shadowColor: Theme.of(context).shadowColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDateRow(
              context,
              gregorianDate: gregorianDate,
              hijriDate: hijriDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_today_rounded,
          color: primaryColor,
          size: 20,
        ),
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
    );
  }

  Widget _buildDateRow(
    BuildContext context, {
    required DateTime gregorianDate,
    required HijriCalendar hijriDate,
  }) {
    final weekday = getWeekdayName(gregorianDate);

    return Column(
      children: [
        Text(
          weekday,
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDateColumn(
              context,
              title: isEnglish ? 'Gregorian' : 'الميلادي',
              date: isEnglish
                  ? DateFormat('dd MMMM yyyy').format(gregorianDate)
                  : '${Globals.toArabicNumber(gregorianDate.day.toString())} '
                      '${CalendarServices.monthNamesMap[gregorianDate.monthName]} '
                      '${Globals.toArabicNumber(gregorianDate.year.toString())}',
            ),
            _buildDivider(),
            _buildDateColumn(
              context,
              title: isEnglish ? 'Hijri' : 'الهجري',
              date: isEnglish
                  ? hijriDate.toFormat("dd MMMM yyyy")
                  : Globals.toArabicNumber(hijriDate.toFormat("dd MMMM yyyy")),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateColumn(
    BuildContext context, {
    required String title,
    required String date,
  }) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[300],
    );
  }

  String getWeekdayName(DateTime date) {
    if (isEnglish) {
      return DateFormat.EEEE().format(date); // e.g., Monday
    } else {
      const arabicWeekdays = {
        'Monday': 'الإثنين',
        'Tuesday': 'الثلاثاء',
        'Wednesday': 'الأربعاء',
        'Thursday': 'الخميس',
        'Friday': 'الجمعة',
        'Saturday': 'السبت',
        'Sunday': 'الأحد',
      };
      String englishWeekday = DateFormat.EEEE().format(date);
      return arabicWeekdays[englishWeekday] ?? englishWeekday;
    }
  }
}
