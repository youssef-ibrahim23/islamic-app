import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/widgets/app_them.dart';

class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final Function() onBackPressed;
  final Function() onSearchPressed;
  final Function() onCloseSearchPressed;
  final String fontFamily;
  final bool isEnglish;

  const QuranAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onBackPressed,
    required this.onSearchPressed,
    required this.onCloseSearchPressed,
    required this.fontFamily,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: primaryColor,
      elevation: 0,
      title: isSearching
          ? Directionality(
            textDirection: Globals.languageState! ? TextDirection.ltr : TextDirection.rtl,
            child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: fontFamily,
                ),
                decoration: InputDecoration(
                  hintText: isEnglish ? "Search Surah..." : "ابحث عن سورة...",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: fontFamily,
                  ),
                  border: InputBorder.none,
                ),
              ),
          )
          : Text(
              isEnglish ? "Al Quran" : "القرآن الكريم",
              style: TextStyle(
                fontFamily: fontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 26,
              ),
            ).animate().fadeIn(duration: 300.ms),
      centerTitle: true,
      leading: isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  _searchController.clear();
                  filteredChapters = chapters;
                });
              },
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BottomBar()),
              ),
            ).animate().fadeIn(duration: 300.ms),
      actions: [
        if (!isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
          ).animate().fadeIn(duration: 300.ms),
        if (isSearching)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = false;
                _searchController.clear();
                filteredChapters = chapters;
              });
            },
          ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}