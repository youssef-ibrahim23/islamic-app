// ignore_for_file: equal_keys_in_map

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/globals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/widgets/prayers/prayer_icon.dart';
import 'package:islamic_app/widgets/prayers/prayer_time_tile.dart';

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  @override
  void initState() {
    super.initState();
    PrayerTimesService.checkLocationAndNavigate(context, () {
      if (mounted) setState(() {});
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: primaryColor,
    ));
  }

  @override
  void dispose() {
    Globals.timer?.cancel();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Globals.locationSelected) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const BottomBar())),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          Globals.languageState! ? "Prayer Times" : 'مواعيد الصلاة',
          style: GoogleFonts.getFont(
            Globals.languageState! ? 'Roboto' : 'Tajawal',
            color: Colors.white,
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: () {
              PrayerTimesService.changeLocation(context, () {
                if (mounted) setState(() {});
              });
            },
            tooltip:
                Globals.languageState! ? 'Change Location' : 'تغيير الموقع',
          ),
        ],
      ),
      body: Globals.prayerTimesIsLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.asset("assets/background.jpg").image,
                      fit: BoxFit.cover)),
              child: Column(
                children: [
                  // Next Prayer Card - Enhanced
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const AssetImage("assets/prayer.jpg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
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
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (Globals.currentLocation != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      Globals.currentLocation!,
                                      style: GoogleFonts.getFont(
                                        Globals.languageState!
                                            ? 'Roboto'
                                            : 'Tajawal',
                                        color: Colors.white70,
                                        fontSize: screenWidth * 0.035,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            Globals.languageState!
                                ? "Next Prayer"
                                : "الصلاة القادمة",
                            style: GoogleFonts.getFont(
                              Globals.languageState! ? 'Roboto' : 'Tajawal',
                              color: Colors.white.withOpacity(0.95),
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            Globals.languageState!
                                ? Globals.nextPrayer
                                : Globals.nextArabicPrayer!,
                            style: GoogleFonts.getFont(
                              Globals.languageState! ? 'Roboto' : 'Tajawal',
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
                                Globals.languageState!
                                    ? "at ${PrayerTimesService.convertTo12HourFormat(Globals.nextPrayerTime)}"
                                    : "في ${Globals.toArabicNumber(PrayerTimesService.convertTo12HourFormat(Globals.nextPrayerTime))}",
                                style: GoogleFonts.getFont(
                                  Globals.languageState! ? 'Roboto' : 'Tajawal',
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              Globals.languageState!
                                  ? Globals.timeRemaining
                                  : Globals.toArabicNumber(
                                      Globals.timeRemaining),
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
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
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
                            if (Globals.prayerTimes != null) ...[
                              PrayerTimeTile.buildPrayerTimeTile(
                                  'Fajr', Globals.prayerTimes!['Fajr']!),
                              PrayerTimeTile.buildPrayerTimeTile(
                                  'Sunrise', Globals.prayerTimes!['Sunrise']!),
                              PrayerTimeTile.buildPrayerTimeTile(
                                  'Dhuhr', Globals.prayerTimes!['Dhuhr']!),
                              PrayerTimeTile.buildPrayerTimeTile(
                                  'Asr', Globals.prayerTimes!['Asr']!),
                              PrayerTimeTile.buildPrayerTimeTile(
                                  'Maghrib', Globals.prayerTimes!['Maghrib']!),
                              PrayerTimeTile.buildPrayerTimeTile(
                                  'Isha', Globals.prayerTimes!['Isha']!),
                            ],
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
