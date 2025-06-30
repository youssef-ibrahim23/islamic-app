import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SurahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String surahName;
  final String arabicName;
  final int surahId;
  final bool isSearching;
  final TextEditingController searchController;
  final bool isEnglish;
  final String fontFamily;
  final Color primaryColor;
  final VoidCallback onSearchChanged;
  final VoidCallback onBackPressed;

  const SurahAppBar({
    super.key,
    required this.surahName,
    required this.arabicName,
    required this.surahId,
    required this.isSearching,
    required this.searchController,
    required this.isEnglish,
    required this.fontFamily,
    required this.primaryColor,
    required this.onSearchChanged,
    required this.onBackPressed,
  });

  String _toArabicNumber(int number, bool withIcon) {
    final arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final arabicNumber = number.toString().split('').map((d) {
      return arabicDigits[int.parse(d)];
    }).join();
    return withIcon ? '۝$arabicNumber' : arabicNumber;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed,
      ),
      centerTitle: true,
      title: isSearching
          ? Directionality(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
              child: TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: isEnglish ? 'Search verses...' : 'ابحث في الآيات...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                cursorColor: Colors.white,
              ),
            )
          : Column(
              children: [
                Text(
                  isEnglish ? surahName : arabicName,
                  style: GoogleFonts.getFont(
                    fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${isEnglish ? 'Surah' : 'سورة'} ${isEnglish ? surahId : _toArabicNumber(surahId, false)}',
                  style: GoogleFonts.getFont(
                    fontFamily,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
          onPressed: onSearchChanged,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}