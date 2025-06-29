import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:islamic_app/services/home_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/home/category_item.dart';
import 'package:islamic_app/widgets/home/combined_date_widget.dart';
import 'package:islamic_app/widgets/home/daily_ayat_card.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/azkar.dart';
import 'package:islamic_app/screens/surahs_list.dart';
import 'package:islamic_app/screens/hadith.dart';
import 'package:islamic_app/screens/counter.dart';
import 'package:islamic_app/screens/calender.dart';
import 'package:islamic_app/screens/prayer_times.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSurahData();
    Globals.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _loadSurahData();
  }

  void _loadSurahData() {
    HomeServices.loadLastSurah((loadedId, loadedName) {
      setState(() {
        Globals.currentSora = loadedName;
        Globals.surahId = loadedId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isEnglish = Globals.languageState!;

    final firstRow = [
      CategoryItem(
        icon: FontAwesomeIcons.bookQuran,
        label: isEnglish ? "Quran" : "القرآن",
        page: const QuranPage(),
        primaryColor: primaryColor,
        cardColor: cardColor,
        textColor: textColor,
        backgroundColor: backgroundColor,
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
      CategoryItem(
        icon: FontAwesomeIcons.handsPraying,
        label: isEnglish ? "Azkar" : "الأذكار",
        page: const AzkarPage(),
        primaryColor: primaryColor,
        cardColor: cardColor,
        textColor: textColor,
        backgroundColor: backgroundColor,
      ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.3),
      CategoryItem(
        icon: FontAwesomeIcons.mosque,
        label: isEnglish ? "Prayers" : "الصلاة",
        page: const PrayerTimesPage(),
        primaryColor: primaryColor,
        cardColor: cardColor,
        textColor: textColor,
        backgroundColor: backgroundColor,
      ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3),
    ];

    final secondRow = [
      CategoryItem(
        icon: FontAwesomeIcons.kaaba,
        label: isEnglish ? "Counter" : "التسبيح",
        page: const Counter(),
        primaryColor: primaryColor,
        cardColor: cardColor,
        textColor: textColor,
        backgroundColor: backgroundColor,
      ).animate().fadeIn(duration: 1100.ms).slideY(begin: 0.3),
      CategoryItem(
        icon: FontAwesomeIcons.calendarDays,
        label: isEnglish ? "Calendar" : "التقويم",
        page: const EnhancedCalendar(),
        primaryColor: primaryColor,
        cardColor: cardColor,
        textColor: textColor,
        backgroundColor: backgroundColor,
      ).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.3),
      CategoryItem(
        icon: FontAwesomeIcons.bookOpen,
        label: isEnglish ? "Ahadith" : "الأحاديث",
        page: const HadithScreen(),
        primaryColor: primaryColor,
        cardColor: cardColor,
        textColor: textColor,
        backgroundColor: backgroundColor,
      ).animate().fadeIn(duration: 1300.ms).slideY(begin: 0.3),
    ];

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
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),
                const CombinedDateWidget(
                  cardColor: cardColor,
                  textColor: textColor,
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                SizedBox(height: screenHeight * 0.02),
                DailyAyatCard(
                  currentSora: Globals.currentSora,
                  surahId: Globals.surahId!,
                  accentColor: accentColor,
                  cardColor: cardColor,
                  textColor: textColor,
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                SizedBox(height: screenHeight * 0.02),
                // Category rows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: isEnglish ? firstRow : firstRow.reversed.toList(),
                ),
                SizedBox(height: screenHeight * 0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: isEnglish ? secondRow : secondRow.reversed.toList(),
                ),
                SizedBox(height: screenHeight * 0.04),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}