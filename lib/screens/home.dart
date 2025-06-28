// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/azkar.dart';
import 'package:islamic_app/screens/hadith.dart';
import 'package:islamic_app/services/home_services.dart';
import 'package:islamic_app/widgets/home/category_item.dart';
import 'package:islamic_app/widgets/home/category_row.dart';
import 'package:islamic_app/widgets/home/combined_date_widget.dart';
import 'package:islamic_app/widgets/home/compass_widget.dart';
import 'package:islamic_app/widgets/home/daily_ayat_card.dart';
import 'package:islamic_app/widgets/home/section_title.dart';

// Importing other pages
import 'Counter.dart';
import 'surahs_list.dart';
import 'calender.dart';
import 'prayer_times.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void initState() {
    super.initState();

    HomeServices.loadLastSurah((id, name) {
      setState(() {
        Globals.surahId = id;
        Globals.currentSora = name;
      });
    });

    HomeServices.fetchCompassData(
      (hasPermission) {
        setState(() {
          Globals.hasPermissions = hasPermission;
        });
      },
      (updatedQiblaDirection) {
        setState(() {
          Globals.qiblaDirection = updatedQiblaDirection;
        });
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    HomeServices.loadLastSurah((id, name) {
      setState(() {
        Globals.surahId = id;
        Globals.currentSora = name;
      });
    });

    Globals.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    Globals.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    HomeServices.loadLastSurah((id, name) {
      setState(() {
        Globals.surahId = id;
        Globals.currentSora = name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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

    Map<String, String> dayNamesMap = {
      'Monday': 'الإثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };

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
        return arabicNumerals[char] ?? char;
      }).join('');
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    String timeStatus = DateFormat("hh:mm a").format(DateTime.now());
    String currentDayName = DateFormat("EEEE").format(DateTime.now());
    int currentDay = DateTime.now().day;
    String currentMonth = DateFormat("MMMM").format(DateTime.now());
    String currentYear = DateFormat("y").format(DateTime.now());
    String currentDate = Globals.languageState!
        ? DateFormat('EEEE, MMMM d, y').format(DateTime.now())
        : "  ${dayNamesMap[currentDayName]} ,  ${monthNamesMap[currentMonth]} ${toArabicNumber(currentDay.toString())} ,  ${toArabicNumber(currentYear)}  ";

    Globals.languageState!
        ? HijriCalendar.setLocal("en")
        : HijriCalendar.setLocal("ar");

    HijriCalendar hijriDate = HijriCalendar.now();
    String currentHijriDate =
        HijriCalendar.fromDate(DateTime.now()).toFormat("dd MMMM yyyy");

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.09),
                // Combined Date Widget
                CombinedDateWidget(
                  gregorianDate: currentDate,
                  hijriDate: currentHijriDate,
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

                SizedBox(height: screenHeight * 0.05),
                // Daily Ayat Card
                const DailyAyatCard()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2),

                SizedBox(height: screenHeight * 0.05),
                // Categories Section
                SectionTitle(
                  title: Globals.languageState! ? "Categories" : "الفئات",
                )
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .slideX(begin: Globals.languageState! ? -0.2 : 0.2),

                SizedBox(height: screenHeight * 0.04),
                // First Row of Categories
                CategoryRow(
                  items: [
                    CategoryItem(
                      icon: FontAwesomeIcons.bookQuran,
                      label: Globals.languageState! ? "Quran" : "القرآن",
                      page: const QuranPage(),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
                    CategoryItem(
                      icon: FontAwesomeIcons.handsPraying,
                      label: Globals.languageState! ? "Azkar" : "الأذكار",
                      page: const AzkarPage(),
                    ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.3),
                    CategoryItem(
                      icon: FontAwesomeIcons.mosque,
                      label: Globals.languageState! ? "Prayers" : "الصلاة",
                      page: const PrayerTimesPage(),
                    ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),

                CategoryRow(
                  items: [
                    CategoryItem(
                      icon: FontAwesomeIcons.kaaba,
                      label: Globals.languageState! ? "Counter" : "التسبيح",
                      page: const Counter(),
                    ).animate().fadeIn(duration: 1100.ms).slideY(begin: 0.3),
                    CategoryItem(
                      icon: FontAwesomeIcons.calendarDays,
                      label: Globals.languageState! ? "Calendar" : "التقويم",
                      page: const EnhancedCalendar(),
                    ).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.3),
                    CategoryItem(
                      icon: FontAwesomeIcons.bookOpen,
                      label: Globals.languageState! ? "Ahadith" : "الأحاديث",
                      page: const HadithScreen(),
                    ).animate().fadeIn(duration: 1300.ms).slideY(begin: 0.3),
                  ],
                ),

                SizedBox(height: screenHeight * 0.03),
                // Compass Widget
                const CompassWidget()
                    .animate()
                    .fadeIn(duration: 1400.ms)
                    .slideY(begin: 0.3),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
