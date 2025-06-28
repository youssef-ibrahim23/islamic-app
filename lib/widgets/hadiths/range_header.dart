import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/hadith_services.dart';
import 'package:islamic_app/widgets/app_them.dart';

class RangeHeader {
  static Widget buildRangeHeader(bool isEnglish, bool isPortrait) {
    return Container(
      padding: EdgeInsets.all(isPortrait ? 12 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${isEnglish ? 'Showing' : 'عرض'} ${HadithService.convertNumbersToArabic(Globals.currentRangeStart.toString(), isEnglish)} - ${HadithService.convertNumbersToArabic(Globals.currentRangeEnd.toString(), isEnglish)}',
          style: TextStyle(
            color: primaryColor,
            fontSize: isPortrait ? 18 : 20,
            fontWeight: FontWeight.bold,
            fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
          ),
        ),
      ),
    );
  }
}
