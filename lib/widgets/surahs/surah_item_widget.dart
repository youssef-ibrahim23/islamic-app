import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/surah.dart';
import 'package:islamic_app/widgets/app_them.dart';

class SurahItem extends StatelessWidget {
  final Chapter chapter;
  final int index;
  final bool isFavorite;
  final String fontFamily;
  final bool isEnglish;
  final Function() onTap;
  final Function() onFavoriteToggle;

  const SurahItem({
    super.key,
    required this.chapter,
    required this.index,
    required this.isFavorite,
    required this.fontFamily,
    required this.isEnglish,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final surahNames = isFavorite
        ? '${chapter.nameSimple} | ${chapter.nameArabic}'.split('|')
        : [chapter.nameSimple, chapter.nameArabic];

    final revelationPlace = (chapter.revelationPlace.toLowerCase() == "makkah")
        ? (isEnglish ? "Makkeah" : "مكية")
        : (isEnglish ? "Madaneah" : "مدنية");

    final versesCountText = isEnglish
        ? "${chapter.versesCount} verses"
        : "${Globals.toArabicNumber(chapter.versesCount.toString())} آيات";

    final direction = isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: direction,
      child: Card(
        color: const Color(0xFFF8F5EF),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Surah Number Circle
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      isEnglish
                          ? chapter.id.toString()
                          : Globals.toArabicNumber(chapter.id.toString()),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Surah Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnglish ? surahNames[0] : surahNames[1],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            revelationPlace,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontFamily: fontFamily,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.menu_book,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            versesCountText,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Favorite Button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? primaryColor : secondaryTextColor,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 1).ms).slideX(
            begin: isEnglish ? -0.2 : 0.2,
            curve: Curves.easeOut,
          ),
    );
  }
}