import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/verses.dart';

class DailyAyatCard extends StatelessWidget {
  final String currentSora;
  final int surahId;
  final Color accentColor;
  final Color cardColor;
  final Color textColor;
  final String ayatTextAr;
  final String ayatTextEn;
  final String? translationName;
  final String? revelationType;
  final int? verseNumber;

  const DailyAyatCard({
    super.key,
    required this.currentSora,
    required this.surahId,
    required this.accentColor,
    required this.cardColor,
    required this.textColor,
    this.ayatTextAr = "ذلك الكتاب لا ريب فيه هدى للمتقين",
    this.ayatTextEn =
        "This is the Scripture whereof there is no doubt, a guidance unto those who ward off (evil)",
    this.translationName,
    this.revelationType,
    this.verseNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = !Globals.languageState!;
    final size = MediaQuery.of(context).size;
    const primaryColor = Color(0xFF8B0000);
    const secondaryColor = Color(0xFF8B0000);
    const backgroundColor = Color(0xFFF8F5EF);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SurahDetailPage(currentSora, surahId, currentSora),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.mosque,
                  size: 120,
                  color: primaryColor,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: secondaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: isArabic
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 7),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: isArabic
                              ? [
                                  Icon(Icons.book_outlined,
                                      color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "آية اليوم",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Tajawal',
                                    ),
                                  ),
                                ]
                              : [
                                  Text(
                                    "Verse of the Day",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.book_outlined,
                                      color: primaryColor, size: 18),
                                ],
                        ),
                      ),
                      if (verseNumber != null)
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              verseNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Ayah content box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: secondaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isArabic ? ayatTextAr : ayatTextEn,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      wordSpacing: isArabic ? 5 : 2,
                      fontSize: isArabic ? 20 : 16,
                      color: isArabic ? primaryColor : Colors.grey[800],
                      fontFamily: isArabic ? 'Kitab' : 'Roboto',
                      height: 1.8,
                      fontWeight: isArabic ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                if (translationName != null && !isArabic)
                  Text(
                    "— $translationName",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 16),

                Align(
                  alignment:
                      isArabic ? Alignment.centerRight : Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SurahDetailPage(
                                currentSora, surahId, currentSora),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: isArabic
                              ? [
                                  Icon(Icons.import_contacts,
                                      color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "سورة $currentSora",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ]
                              : [
                                  Text(
                                    "Surah $currentSora",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.import_contacts,
                                      color: primaryColor, size: 18),
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
