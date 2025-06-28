import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/prayer_times_services.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'dart:ui' as ui;

import 'package:islamic_app/widgets/prayers/prayer_icon.dart';

class PrayerTimeTile{

  static Widget buildPrayerTimeTile(String prayerName, String prayerTime) {
    final isCurrentPrayer = prayerName == Globals.nextPrayer;
    final convertedTime = PrayerTimesService.convertTo12HourFormat(prayerTime);
    final displayTime = Globals.languageState! ? convertedTime : Globals.toArabicNumber(convertedTime);
    final arabicName = PrayerTimesService.getArabicPrayerName(prayerName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentPrayer ? primaryColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPrayer ? primaryColor : Colors.grey.shade200,
          width: isCurrentPrayer ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              textDirection: Globals.languageState! ? ui.TextDirection.ltr : ui.TextDirection.rtl,
              children: [
                // Prayer Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrentPrayer 
                        ? primaryColor.withOpacity(0.1) 
                        : Colors.grey.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(
                    PrayerIcon.getPrayerIcon(prayerName),
                    color: isCurrentPrayer ? primaryColor : Colors.grey.shade700,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Prayer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: Globals.languageState!
                        ? CrossAxisAlignment.start 
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        Globals.languageState! ? prayerName : arabicName,
                        style: GoogleFonts.getFont(
                          Globals.languageState! ? 'Roboto' : 'Tajawal',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCurrentPrayer ? primaryColor : textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayTime,
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCurrentPrayer 
                              ? primaryColor.withOpacity(0.8) 
                              : textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Current Prayer Indicator
                if (isCurrentPrayer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Globals.languageState! ? "Next" : "التالية",
                      style: GoogleFonts.getFont(
                        Globals.languageState! ? 'Roboto' : 'Tajawal',
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}