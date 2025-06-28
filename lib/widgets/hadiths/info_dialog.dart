import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/hadith_services.dart';
import 'package:islamic_app/widgets/app_them.dart';

class InfoDialog {
  static void showInfoDialog(BuildContext context) {

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      body: Directionality(
        textDirection: Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                Globals.languageState! ? 'About Sahih Bukhari' : 'عن صحيح البخاري',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Globals.languageState!
                    ? 'Currently showing hadiths ${Globals.currentRangeStart}-${Globals.currentRangeEnd}'
                    : 'عرض الأحاديث من ${HadithService.convertNumbersToArabic(Globals.currentRangeStart.toString() , Globals.languageState!)} إلى ${HadithService.convertNumbersToArabic(Globals.currentRangeEnd.toString() , Globals.languageState!)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Globals.languageState!
                    ? 'Sahih al-Bukhari is one of the most authentic collections of hadith in Islam.'
                    : 'صحيح البخاري هو أحد أصح كتب الحديث النبوي في الإسلام',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontFamily: Globals.languageState! ? 'Roboto' : 'Tajawal',
                ),
              ),
            ],
          ),
        ),
      ),
    ).show();
  }
}
