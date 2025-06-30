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
  String? _surahName;
  int? _surahId;

  @override
  void initState() {
    super.initState();
    _loadSurahData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Globals.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _loadSurahData();
  }

  void _loadSurahData() {
    HomeServices.loadLastSurah((loadedId, loadedName) {
      if (mounted) {
        setState(() {
          _surahId = loadedId;
          _surahName = loadedName;
        });
      }
    });
  }

  @override
  void dispose() {
    Globals.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isEnglish = Globals.languageState ?? true;

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
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.06),
                const CombinedDateWidget(
                  cardColor: cardColor,
                  textColor: textColor,
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

                SizedBox(height: screenHeight * 0.03),
                if (_surahId != null)
                  DailyAyatCard(
                    currentSora: _surahName ?? "",
                    surahId: _surahId!,
                    accentColor: accentColor,
                    cardColor: cardColor,
                    textColor: textColor,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                SizedBox(height: screenHeight * 0.03),
                _buildCategoryRow(isEnglish, [
                  _buildAnimatedCategory(FontAwesomeIcons.bookQuran, isEnglish ? "Quran" : "القرآن", const QuranPage(), 800),
                  _buildAnimatedCategory(FontAwesomeIcons.handsPraying, isEnglish ? "Azkar" : "الأذكار", const AzkarPage(), 900),
                  _buildAnimatedCategory(FontAwesomeIcons.mosque, isEnglish ? "Prayers" : "الصلاة", const PrayerTimesPage(), 1000),
                ]),
                SizedBox(height: screenHeight * 0.025),
                _buildCategoryRow(isEnglish, [
                  _buildAnimatedCategory(FontAwesomeIcons.kaaba, isEnglish ? "Counter" : "التسبيح", const Counter(), 1100),
                  _buildAnimatedCategory(FontAwesomeIcons.calendarDays, isEnglish ? "Calendar" : "التقويم", const EnhancedCalendar(), 1200),
                  _buildAnimatedCategory(FontAwesomeIcons.bookOpen, isEnglish ? "Ahadith" : "الأحاديث", const HadithScreen(), 1300),
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
