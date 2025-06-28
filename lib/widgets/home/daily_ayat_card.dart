import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as ui;
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
  final int? verseNumber; // Added verse number parameter

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
    final textDirection =
        isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

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
        height: isPortrait ? size.height * 0.35 : size.height * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withOpacity(0.9),
              accentColor.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/ayah.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(180, 0, 0, 0),
              BlendMode.darken,
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                // Verse number badge if available
                if (verseNumber != null)
                  Positioned(
                    top: 10,
                    right: isArabic ? null : 10,
                    left: isArabic ? 10 : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        verseNumber.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                Directionality(
                  textDirection: textDirection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with more decorative elements
                      Row(
                        mainAxisAlignment: isArabic ? MainAxisAlignment.end : isArabic ? MainAxisAlignment.end : MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      
                                          Flexible(
                                            child: Text(
                                              isArabic
                                                  ? "آية اليوم"
                                                  : "Verse of the Day",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: isArabic
                                                    ? 'Tajawal'
                                                    : 'Roboto',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.menu_book_rounded,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            size: 18,
                                          ),
                                        ]),
                            ),
                          ),
                          if (revelationType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                revelationType!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: isArabic ? 'Tajawal' : 'Roboto',
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Arabic text with improved decoration
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Arabic text with decorative start/end marks
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isArabic ? '﷽ ' : '',
                                        style: TextStyle(
                                          fontSize: isArabic ? 24 : 0,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          isArabic ? ayatTextAr : ayatTextEn,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isArabic
                                                ? (isPortrait ? 26 : 22)
                                                : (isPortrait ? 18 : 16),
                                            color: Colors.white,
                                            fontFamily:
                                                isArabic ? 'Kitab' : 'Roboto',
                                            height: 1.8,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 10,
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                offset: const Offset(1, 1),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        isArabic ? ' ﷽' : '',
                                        style: TextStyle(
                                          fontSize: isArabic ? 24 : 0,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (translationName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        "($translationName)",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Surah name with improved button
                      Row(
                        mainAxisAlignment: isArabic ? MainAxisAlignment.start : isArabic ? MainAxisAlignment.start : MainAxisAlignment.start,
                        children: [
                          Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SurahDetailPage(
                                        currentSora, surahId, currentSora),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isArabic
                                          ? "سورة $currentSora"
                                          : "Surah $currentSora",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Tajawal',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4,
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            offset: const Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
