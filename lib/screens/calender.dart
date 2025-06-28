import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/calender_services.dart';
import 'package:islamic_app/widgets/calender/calender_widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';

class EnhancedCalendar extends StatefulWidget {
  const EnhancedCalendar({super.key});

  @override
  State<EnhancedCalendar> createState() => _EnhancedCalendarState();
}

class _EnhancedCalendarState extends State<EnhancedCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final Color _primaryColor = const Color(0xFF8B0000);
  final Color _backgroundColor = const Color(0xFFFAFAFA);
  final Color _textColor = const Color(0xFF333333);
  final Color _hijriTextColor = const Color(0xFF666666);
  final bool _isEnglish = Globals.languageState!;

  @override
  void initState() {
    super.initState();
    CalendarServices.setHijriLocale(_isEnglish);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cellSize = size.width * 0.12;

    final weekdayNames = _isEnglish
        ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        : ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEnglish ? 'Calendar' : 'التقويم',
          style: TextStyle(
            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TableCalendar(
                        firstDay: DateTime(2000),
                        lastDay: DateTime(2100),
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
                          leftChevronIcon: Icon(Icons.chevron_left, color: _primaryColor, size: 28),
                          rightChevronIcon: Icon(Icons.chevron_right, color: _primaryColor, size: 28),
                          titleCentered: true,
                          titleTextFormatter: (date, locale) {
                            CalendarServices.setHijriLocale(_isEnglish);
                            final hijri = HijriCalendar.fromDate(date);
                            return _isEnglish
                                ? '${date.monthName} ${date.year}\n${hijri.longMonthName} ${hijri.hYear}'
                                : '${CalendarServices.monthNamesMap[date.monthName]} ${Globals.toArabicNumber(date.year.toString())}\n${hijri.longMonthName} ${Globals.toArabicNumber(hijri.hYear.toString())}';
                          },
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            color: _primaryColor,
                            fontSize: _isEnglish ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                          ),
                          headerPadding: const EdgeInsets.symmetric(vertical: 12),
                          headerMargin: const EdgeInsets.only(bottom: 8),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: _primaryColor, width: 1.5),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(
                            fontSize: 16,
                            color: _textColor,
                            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                          ),
                          weekendTextStyle: TextStyle(
                            fontSize: 16,
                            color: _textColor,
                            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                          ),
                          outsideTextStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                          ),
                          selectedTextStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          todayTextStyle: TextStyle(
                            fontSize: 16,
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                          ),
                          cellMargin: const EdgeInsets.all(4),
                          cellPadding: EdgeInsets.zero,
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          weekdayStyle: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                          ),
                          weekendStyle: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, day) {
                            return Center(
                              child: Text(
                                weekdayNames[day.weekday % 7],
                                style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                                ),
                              ),
                            );
                          },
                          defaultBuilder: (context, day, focusedDay) {
                            CalendarServices.setHijriLocale(_isEnglish);
                            final hijri = HijriCalendar.fromDate(day);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isEnglish ? '${day.day}' : Globals.toArabicNumber('${day.day}'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _textColor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isEnglish ? hijri.hDay.toString() : Globals.toArabicNumber(hijri.hDay.toString()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _hijriTextColor,
                                    fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                                  ),
                                ),
                              ],
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            CalendarServices.setHijriLocale(_isEnglish);
                            final hijri = HijriCalendar.fromDate(day);
                            return Container(
                              width: cellSize,
                              height: cellSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: _primaryColor, width: 1.5),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isEnglish ? '${day.day}' : Globals.toArabicNumber('${day.day}'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isEnglish ? hijri.hDay.toString() : Globals.toArabicNumber(hijri.hDay.toString()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _primaryColor,
                                      fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            CalendarServices.setHijriLocale(_isEnglish);
                            final hijri = HijriCalendar.fromDate(day);
                            return Container(
                              width: cellSize,
                              height: cellSize,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isEnglish ? '${day.day}' : Globals.toArabicNumber('${day.day}'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isEnglish ? hijri.hDay.toString() : Globals.toArabicNumber(hijri.hDay.toString()),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.9),
                                      fontFamily: _isEnglish ? 'Roboto' : 'Tajawal',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  if (_selectedDay != null)
                    SelectedDateCard(
                      selectedDay: _selectedDay!,
                      isEnglish: _isEnglish,
                      primaryColor: _primaryColor,
                      textColor: _textColor,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
