import 'package:flutter/material.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/screens/verses.dart';

class DailyAyatCard extends StatelessWidget {
  final String currentSora;
  final String? currentSoraEn;
  final String? currentSoraAr;
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
    this.currentSoraEn,
    this.currentSoraAr,
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

    // Determine the appropriate surah name based on current language
    final displayName = isArabic
        ? (currentSoraAr ?? currentSora)
        : (currentSoraEn ?? currentSora);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(
              currentSoraEn ?? currentSora, // English name
              surahId,
              currentSoraAr ?? currentSora, // Arabic name
              targetVerseNumber: verseNumber, // Scroll to this verse
              openSource: 'daily_ayah', // Mark as opened from daily ayah
            ),
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
            const Positioned(
              top: 10,
              right: 10,
              child: Opacity(
                opacity: 0.15,
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
                                  const Icon(Icons.book_outlined,
                                      color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
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
                                  const Text(
                                    "Verse of the Day",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.book_outlined,
                                      color: primaryColor, size: 18),
                                ],
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
                    ayatTextAr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      wordSpacing: 5,
                      fontSize: isArabic ? 20 : 18,
                      color: primaryColor,
                      fontFamily: 'Kitab',
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // Removed translation name display to avoid duplicate surah name in English mode

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
                              currentSoraEn ?? currentSora, // English name
                              surahId,
                              currentSoraAr ?? currentSora, // Arabic name
                              targetVerseNumber:
                                  verseNumber, // Scroll to this verse
                              openSource:
                                  'daily_ayah', // Mark as opened from daily ayah
                            ),
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
                                  const Icon(Icons.import_contacts,
                                      color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "سورة $displayName",
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontFamily: 'Tajawal',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ]
                              : [
                                  Text(
                                    "Surah $displayName",
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontFamily: 'Roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.import_contacts,
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
