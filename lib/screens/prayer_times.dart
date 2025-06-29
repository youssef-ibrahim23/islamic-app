// ignore_for_file: equal_keys_in_map, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/prayers/prayer_icon.dart';
import 'package:islamic_app/widgets/prayers/prayer_time_tile.dart';

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

    // Get location and prayer times
    PrayerTimesService.checkLocationAndNavigate(context, () {
      if (mounted) setState(() {});
    });

    // Refresh countdown UI every second
    _localTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    // Update status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: primaryColor),
    );
  }

  @override
  void dispose() {
    Globals.timer?.cancel(); // Global countdown timer
    _localTimer.cancel();    // UI refresh timer
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
                  // Next Prayer Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/prayer.jpg"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          if (Globals.currentLocation != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    Globals.currentLocation!,
                                    style: GoogleFonts.getFont(
                                      isEnglish ? 'Roboto' : 'Tajawal',
                                      color: Colors.white70,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Text(
                            isEnglish ? "Next Prayer" : "الصلاة القادمة",
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              color: Colors.white.withOpacity(0.95),
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isEnglish
                                ? Globals.nextPrayer
                                : Globals.nextArabicPrayer ?? Globals.nextPrayer,
                            style: GoogleFonts.getFont(
                              isEnglish ? 'Roboto' : 'Tajawal',
                              color: Colors.white,
                              fontSize: screenWidth * 0.065,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                radius: 18,
                                child: Icon(
                                  PrayerIcon.getPrayerIcon(Globals.nextPrayer),
                                  color: highlightColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEnglish
                                    ? "at ${PrayerTimesService.convertTo12HourFormat(Globals.nextPrayerTime)}"
                                    : "في ${Globals.toArabicNumber(
                                        PrayerTimesService.convertTo12HourFormat(Globals.nextPrayerTime),
                                      )}",
                                style: GoogleFonts.getFont(
                                  isEnglish ? 'Roboto' : 'Tajawal',
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              isEnglish
                                  ? Globals.timeRemaining
                                  : Globals.toArabicNumber(Globals.timeRemaining),
                              style: GoogleFonts.robotoMono(
                                color: Colors.white,
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Prayer Times List
                  Expanded(
                    child: Container(
                      
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (Globals.prayerTimes != null)
                              ...Globals.prayerTimes!.entries.map(
                                (entry) => PrayerTimeTileWidget(
                                  prayerName: entry.key,
                                  prayerTime: entry.value,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
