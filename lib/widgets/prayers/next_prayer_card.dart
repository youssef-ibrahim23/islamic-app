import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/prayers/prayer_icon.dart';

class NextPrayerCard extends StatelessWidget {
  final bool isEnglish;
  final double screenWidth;

  const NextPrayerCard({
    super.key,
    required this.isEnglish,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final location = Globals.currentLocation;
    final nextPrayer = Globals.nextPrayer;
    final nextArabicPrayer = Globals.nextArabicPrayer;
    final nextPrayerTime = Globals.nextPrayerTime;
    final timeRemaining = Globals.timeRemaining;

    return Container(
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
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(0, 0, 0, 0.3),
              Color.fromRGBO(0, 0, 0, 0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            if (location != null) _buildLocationRow(location),
            const SizedBox(height: 10),
            _buildText(
              isEnglish ? "Next Prayer" : "الصلاة القادمة",
              screenWidth * 0.045,
              FontWeight.w600,
              0.95,
            ),
            const SizedBox(height: 10),
            _buildText(
              isEnglish ? nextPrayer : nextArabicPrayer ?? nextPrayer,
              screenWidth * 0.065,
              FontWeight.bold,
            ),
            const SizedBox(height: 14),
            _buildPrayerTimeRow(nextPrayer, nextPrayerTime),
            const SizedBox(height: 20),
            _buildCountdownContainer(timeRemaining),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String location) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.location_on, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            location,
            style: GoogleFonts.getFont(
              isEnglish ? 'Roboto' : 'Tajawal',
              color: Colors.white70,
              fontSize: screenWidth * 0.035,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildText(String text, double fontSize, FontWeight weight, [double opacity = 1]) {
    return Text(
      text,
      style: GoogleFonts.getFont(
        isEnglish ? 'Roboto' : 'Tajawal',
        color: Colors.white.withOpacity(opacity),
        fontSize: fontSize,
        fontWeight: weight,
      ),
    );
  }

  Widget _buildPrayerTimeRow(String prayer, String time) {
    final timeText = isEnglish
        ? "at ${PrayerTimesService.convertTo12HourFormat(time)}"
        : "في ${Globals.toArabicNumber(
            PrayerTimesService.convertTo12HourFormat(time),
          )}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.1),
          radius: 18,
          child: Icon(
            PrayerIcon.getPrayerIcon(prayer),
            color: highlightColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          timeText,
          style: GoogleFonts.getFont(
            isEnglish ? 'Roboto' : 'Tajawal',
            color: Colors.white70,
            fontSize: screenWidth * 0.045,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownContainer(String timeRemaining) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isEnglish ? timeRemaining : Globals.toArabicNumber(timeRemaining),
        style: GoogleFonts.robotoMono(
          color: Colors.white,
          fontSize: screenWidth * 0.07,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
