import 'package:flutter/material.dart';
import 'package:islamic_app/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';

class Calendar_p extends StatefulWidget {
  const Calendar_p({super.key});

  @override
  _HijriCalendarPageState createState() => _HijriCalendarPageState();
}

class _HijriCalendarPageState extends State<Calendar_p> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Convert numbers to Arabic numerals
  String toArabicNumber(String input) {
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

    return input.split('').map((char) {
      return arabicNumerals[char] ??
          char; // Replace digits, or keep character if not a digit
    }).join('');
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0b3d27),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          languageState! ? 'Calendar' : 'التقويم',
          style: TextStyle(
            fontFamily: languageState! ? 'cursive' : 'Lateef',
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime(2000, 1, 1),
              lastDay: DateTime(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: HeaderStyle(
                leftChevronIcon: const Icon(
                  Icons.arrow_back_ios_new_outlined,
                  size: 15,
                  color: Colors.white,
                ),
                rightChevronIcon:
                    const Icon(Icons.navigate_next, color: Colors.white),
                titleCentered: true,
                titleTextFormatter: (date, locale) {
                  languageState!
                      ? HijriCalendar.setLocal("en")
                      : HijriCalendar.setLocal("ar");
                  final hijri = HijriCalendar.fromDate(date);
                  return languageState!
                      ? '\n${date.monthName} ${date.year} \n${hijri.longMonthName} ${hijri.hYear} \n'
                      : '\n${monthNamesMap[date.monthName]} ${toArabicNumber(date.year.toString())} \n${hijri.longMonthName} ${toArabicNumber(hijri.hYear.toString())} \n';
                },
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: languageState! ? 18 : 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  color: const Color(0xFF00796B),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle:
                    const TextStyle(fontSize: 14, color: Colors.white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white)),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  languageState!
                      ? HijriCalendar.setLocal("en")
                      : HijriCalendar.setLocal("ar");
                  final hijri = HijriCalendar.fromDate(day);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        languageState!
                            ? '${day.day}'
                            : toArabicNumber(
                                '${day.day}'), // Converts the day number to Arabic
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        toArabicNumber(hijri.hDay.toString()),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (_selectedDay != null)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF0b3d27),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                languageState!
                    ? 'Selected Gregorian: ${_selectedDay!.day}-${_selectedDay!.month}-${_selectedDay!.year}\n\n'
                        'Selected Hijri: ${HijriCalendar.fromDate(_selectedDay!).toFormat("dd MMMM yyyy")}'
                    : " التاريخ الميلادي : ${toArabicNumber("${_selectedDay!.day}-${_selectedDay!.month}-${_selectedDay!.year}\n\n")}"
                        "التاريخ الهجري : ${HijriCalendar.fromDate(_selectedDay!).toFormat("dd MMMM yyyy")}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on DateTime {
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
