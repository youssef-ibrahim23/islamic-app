import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/surah.dart';
import 'package:islamic_app/services/surahs_list_services.dart';
import 'package:islamic_app/widgets/app_them.dart';

class SurahItem extends StatefulWidget {
  final Chapter chapter;
  final int index;

  const SurahItem({
    Key? key,
    required this.chapter,
    required this.index,
  }) : super(key: key);

  @override
  State<SurahItem> createState() => _SurahItemState();
}

class _SurahItemState extends State<SurahItem> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = Globals.favoriteSurahIds.containsKey(widget.chapter.id);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> surahNames = isFavorite
        ? Globals.favoriteSurahIds[widget.chapter.id]!.split('|')
        : [widget.chapter.nameSimple, widget.chapter.nameArabic];

    final bool isEnglish = Globals.languageState!;
    final String surahName = isEnglish ? surahNames[0] : surahNames[1];
    final String revelationPlace =
        (widget.chapter.revelationPlace.toLowerCase() == "makkah")
            ? (isEnglish ? "Makkah" : "مكة")
            : (isEnglish ? "Madinah" : "المدينة");

    final TextDirection textDir = isEnglish ? TextDirection.ltr : TextDirection.rtl;
    final CrossAxisAlignment alignment =
        isEnglish ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final TextAlign textAlign = isEnglish ? TextAlign.left : TextAlign.right;

    return Directionality(
      textDirection: textDir,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => SurahsListServices.navigateToSurahDetail(context, widget.chapter),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (isEnglish) _buildSurahNumberCircle(widget.chapter.id, isEnglish),
                if (!isEnglish) _buildFavoriteIcon(),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: alignment,
                    children: [
                      Text(
                        surahName,
                        textAlign: textAlign,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: Globals.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        revelationPlace,
                        textAlign: textAlign,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                          fontFamily: Globals.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                if (isEnglish) _buildFavoriteIcon(),
                if (!isEnglish) _buildSurahNumberCircle(widget.chapter.id, isEnglish),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (widget.index * 50).ms).slideX(
            begin: isEnglish ? -0.2 : 0.2,
            curve: Curves.easeOut,
          ),
    );
  }

  Widget _buildFavoriteIcon() {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? primaryColor : secondaryTextColor,
      ),
      onPressed: () {
        SurahsListServices.toggleFavorite(widget.chapter);
        setState(() {
          isFavorite = !isFavorite;
        });
      },
    );
  }

  Widget _buildSurahNumberCircle(int id, bool isEnglish) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          isEnglish ? id.toString() : Globals.toArabicNumber(id.toString()),
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: Globals.fontFamily,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
