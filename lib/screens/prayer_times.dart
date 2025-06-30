import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/prayers/next_prayer_card.dart';
import 'package:islamic_app/widgets/prayers/prayer_times_list.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  late Timer _localTimer;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    PrayerTimesService.checkLocationAndNavigate(context, _updateState);
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateState());
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: primaryColor),
    );
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    Globals.timer?.cancel();
    _localTimer.cancel();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final double screenWidth = MediaQuery.of(context).size.width;

    if (!Globals.locationSelected) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BottomBar()),
            );
          },
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEnglish ? "Prayer Times" : 'مواعيد الصلاة',
          style: GoogleFonts.getFont(
            isEnglish ? 'Roboto' : 'Tajawal',
            color: Colors.white,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            tooltip: isEnglish ? 'Change Location' : 'تغيير الموقع',
            onPressed: () {
              PrayerTimesService.changeLocation(context, () {
                if (mounted) setState(() {});
              });
            },
          ),
        ],
      ),
      body: Globals.prayerTimesIsLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  NextPrayerCard(
                    isEnglish: isEnglish,
                    screenWidth: screenWidth,
                  ),
                  Expanded(
                    child: PrayerTimesList(),
                  ),
                ],
              ),
            ),
    );
  }
}