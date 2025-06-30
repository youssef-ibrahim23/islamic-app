import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/calender_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/calender/calender_header.dart';
import 'package:islamic_app/widgets/calender/calender_widgets.dart';
import 'package:islamic_app/widgets/calender/day_builders.dart';
import 'package:islamic_app/widgets/calender/outside_day.dart';
import 'package:table_calendar/table_calendar.dart';

class EnhancedCalendar extends StatefulWidget {
  const EnhancedCalendar({super.key});

  @override
  State<EnhancedCalendar> createState() => _EnhancedCalendarState();
}

class _EnhancedCalendarState extends State<EnhancedCalendar> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay = DateTime.now();
  final Color hijriTextColor = const Color(0xFF666666);
  final bool isEnglish = Globals.languageState!;

  @override
  void initState() {
    super.initState();
    CalendarServices.setHijriLocale(isEnglish);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cellSize = size.width * 0.12;

    final weekdayNames = isEnglish
        ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEnglish ? 'Calendar' : 'التقويم',
          style: TextStyle(
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F5EF),
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.07),
                _buildCalendar(size, cellSize, weekdayNames),
                SizedBox(height: size.height * 0.06),
                if (selectedDay != null)
                  SelectedDateCard(
                    selectedDay: selectedDay!,
                    isEnglish: isEnglish,
                    primaryColor: primaryColor,
                    textColor: textColor,
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(Size size, double cellSize, List<String> weekdayNames) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFFF8F5EF),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TableCalendar(
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          focusedDay: focusedDay,
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              this.selectedDay = selectedDay;
              this.focusedDay = focusedDay;
            });
          },
          headerStyle: HeaderStyle(
            leftChevronIcon: const Icon(Icons.chevron_left, color: primaryColor, size: 28),
            rightChevronIcon: const Icon(Icons.chevron_right, color: primaryColor, size: 28),
            titleCentered: true,
            titleTextFormatter: (date, locale) => formatCalendarHeaderText(date, isEnglish),
            formatButtonVisible: false,
            titleTextStyle: TextStyle(
              color: primaryColor,
              fontSize: isEnglish ? 16 : 18,
              fontWeight: FontWeight.bold,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 12),
            headerMargin: const EdgeInsets.only(bottom: 8),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 1.5),
            ),
            selectedDecoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
            weekendTextStyle: TextStyle(
              fontSize: 16,
              color: textColor,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
            outsideTextStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
            selectedTextStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            todayTextStyle: TextStyle(
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
            cellMargin: const EdgeInsets.all(4),
            cellPadding: EdgeInsets.zero,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            decoration: const BoxDecoration(
              color: Color(0xFFF8F5EF),
            ),
            weekdayStyle: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
            weekendStyle: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
            ),
          ),
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              return Center(
                child: Text(
                  weekdayNames[day.weekday % 7],
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                  ),
                ),
              );
            },
            defaultBuilder: (context, day, focusedDay) =>
                buildDefaultDay(context, day, isEnglish, textColor, hijriTextColor),
            todayBuilder: (context, day, focusedDay) =>
                buildTodayDay(context, day, isEnglish, primaryColor, cellSize),
            selectedBuilder: (context, day, focusedDay) =>
                buildSelectedDay(context, day, isEnglish, cellSize),
            outsideBuilder: (context, day, focusedDay) => // Add this builder
                buildOutsideDay(context, day, isEnglish, textColor, hijriTextColor),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}