import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/models/hadith.dart';
import 'package:islamic_app/services/hadith_services.dart';
import 'package:islamic_app/widgets/app_them.dart';

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final bool isEnglish;
  final bool isPortrait;

  const HadithCard({
    Key? key,
    required this.hadith,
    required this.isEnglish,
    required this.isPortrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPortrait ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEnglish
                      ? 'Hadith #${hadith.number}'
                      : 'حديث رقم ${HadithService.convertNumbersToArabic(hadith.number.toString(), isEnglish)}',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isPortrait ? 16 : 18,
                    fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: secondaryTextColor, size: 20),
                  onPressed: () => HadithService.shareHadith(hadith, isEnglish),
                ),
              ],
            ),
            SizedBox(height: isPortrait ? 12 : 16),
            Container(
              padding: EdgeInsets.all(isPortrait ? 12 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hadith.arab,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: textColor,
                  fontSize: isPortrait ? 18 : 20,
                  fontFamily: 'Tajawal',
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: isPortrait ? 12 : 16),
            // You can add more content like translation or reference here
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}
