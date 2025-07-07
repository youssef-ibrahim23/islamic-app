// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  late Future<Map<String, dynamic>> _surahFuture;

  @override
  void initState() {
    super.initState();
    _surahFuture = _fetchSurahData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Globals.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);

    // ✅ Preload background image to prevent initial lag
    precacheImage(const AssetImage('assets/background.jpg'), context);
  }

  Future<Map<String, dynamic>> _fetchSurahData() async {
    return await HomeServices.loadLastSurahAsync();
  }

  @override
  void didPopNext() {
    setState(() {
      _surahFuture = _fetchSurahData();
    });
  }

  @override
  void dispose() {
    Globals.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isEnglish = Globals.languageState ?? false;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low, // ✅ Speed up rendering
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),

                const CombinedDateWidget(
                  cardColor: cardColor,
                  textColor: textColor,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

                SizedBox(height: screenHeight * 0.03),

                FutureBuilder<Map<String, dynamic>>(
                  future: _surahFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return DailyAyatCard(
                        currentSora: snapshot.data!['name'],
                        surahId: snapshot.data!['id'],
                        accentColor: accentColor,
                        cardColor: cardColor,
                        textColor: textColor,
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2);
                    }
                    return const SizedBox.shrink();
                  },
                ),

                SizedBox(height: screenHeight * 0.03),

                _buildCategoryRow(isEnglish, [
                  _buildAnimatedCategory(FontAwesomeIcons.bookQuran, isEnglish ? "Quran" : "القرآن", const QuranPage(), 700),
                  _buildAnimatedCategory(FontAwesomeIcons.handsPraying, isEnglish ? "Azkar" : "الأذكار", const AzkarPage(), 800),
                  _buildAnimatedCategory(FontAwesomeIcons.mosque, isEnglish ? "Prayers" : "الصلاة", const PrayerTimesPage(), 900),
                ]),
                SizedBox(height: screenHeight * 0.025),
                _buildCategoryRow(isEnglish, [
                  _buildAnimatedCategory(FontAwesomeIcons.kaaba, isEnglish ? "Counter" : "التسبيح", const Counter(), 1000),
                  _buildAnimatedCategory(FontAwesomeIcons.calendarDays, isEnglish ? "Calendar" : "التقويم", const EnhancedCalendar(), 1100),
                  _buildAnimatedCategory(FontAwesomeIcons.bookOpen, isEnglish ? "Ahadith" : "الأحاديث", const HadithScreen(), 1200),
                ]),

                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCategory(IconData icon, String label, Widget page, int durationMs) {
    return CategoryItem(
      icon: icon,
      label: label,
      page: page,
      primaryColor: primaryColor,
      cardColor: cardColor,
      textColor: textColor,
      backgroundColor: backgroundColor,
    ).animate().fadeIn(duration: durationMs.ms).slideY(begin: 0.3);
  }

  Widget _buildCategoryRow(bool isEnglish, List<Widget> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: isEnglish ? items : items.reversed.toList(),
    );
  }
}
