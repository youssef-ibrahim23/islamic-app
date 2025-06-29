import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/models/surah.dart';
import 'package:islamic_app/screens/bottom_bar.dart';
import 'package:islamic_app/screens/verses.dart';
import 'package:islamic_app/services/surahs_list_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  List<Chapter>? chapters;
  List<Chapter>? filteredChapters;
  Map<int, String> favoriteSurahIds = {};
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  bool hasError = false;
  bool isSearching = false;
  final Color primaryColor = const Color(0xFF8B0000);
  final Color accentColor = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color secondaryTextColor = const Color(0xFF666666);

  // Helper getters for language and direction
  bool get isEnglish => Globals.languageState ?? true;
  TextDirection get textDirection => isEnglish ? TextDirection.ltr : TextDirection.ltr;
  String get fontFamily => isEnglish ? 'Roboto' : 'Tajawal';

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterChapters);
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadChapters(),
      _loadFavorites(),
    ]);
  }

  Future<void> _loadChapters() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await SurahsListServices.loadLocalChapters();
      setState(() {
        chapters = data.chapters;
        filteredChapters = data.chapters;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      _showErrorSnackbar(isEnglish ? "Failed to load Surahs" : "فشل تحميل السور");
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      favoriteSurahIds = {};
      for (var entry in favorites) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          final id = int.tryParse(parts[0]);
          if (id != null) {
            favoriteSurahIds[id] = parts[1];
          }
        }
      }
    });
  }

  Future<void> _saveLastSurah(Chapter chapter) async {
  final isEnglish = Globals.languageState ?? true;

  Globals.surahId = chapter.id;
  Globals.currentSora = isEnglish ? chapter.nameSimple : chapter.nameArabic;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('lastSurahId', chapter.id);
  await prefs.setString('lastSurahName', chapter.nameSimple);
  await prefs.setString('lastSurahArabicName', chapter.nameArabic);
}

  Future<void> _toggleFavorite(Chapter chapter) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (favoriteSurahIds.containsKey(chapter.id)) {
        favoriteSurahIds.remove(chapter.id);
      } else {
        favoriteSurahIds[chapter.id] = '${chapter.nameSimple} | ${chapter.nameArabic}';
      }
    });

    await prefs.setStringList(
      'favorites',
      favoriteSurahIds.entries
          .map((entry) => '${entry.key}:${entry.value}')
          .toList(),
    );
  }

  void _filterChapters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredChapters = chapters?.where((chapter) {
        final name = isEnglish ? chapter.nameSimple : chapter.nameArabic;
        return name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ).animate().fadeIn().slideY(begin: -1) as SnackBar,
    );
  }

  void _navigateToSurahDetail(Chapter chapter) {
    _saveLastSurah(chapter);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahDetailPage(
          chapter.nameSimple,
          chapter.id,
          chapter.nameArabic,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  Widget _buildSurahItem(Chapter chapter, int index) {
    final isFavorite = favoriteSurahIds.containsKey(chapter.id);
    final surahNames = isFavorite
        ? favoriteSurahIds[chapter.id]!.split('|')
        : [chapter.nameSimple, chapter.nameArabic];

    final revelationPlace = (chapter.revelationPlace.toLowerCase() == "makkah")
        ? (isEnglish ? "Makkeah" : "مكية")
        : (isEnglish ? "Madaneah" : "مدنية");

    final versesCountText = isEnglish
        ? "${chapter.versesCount} verses"
        : "${_toArabicNumber(chapter.versesCount.toString())} آيات";

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
          onTap: () => _navigateToSurahDetail(chapter),
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
                          : _toArabicNumber(chapter.id.toString()),
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
                          Icon(
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
                          Icon(
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
                  onPressed: () => _toggleFavorite(chapter),
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

  AppBar _buildAppBar() {
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

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: primaryColor, size: 48),
            const SizedBox(height: 16),
            Text(
              isEnglish ? "Error loading data" : "خطأ في تحميل البيانات",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChapters,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isEnglish ? "Retry" : "إعادة المحاولة",
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if ((chapters == null || chapters!.isEmpty) &&
        (filteredChapters == null || filteredChapters!.isEmpty)) {
      return Center(
        child: Text(
          isEnglish ? "No Surahs Available" : "لا توجد سور متاحة",
          style: TextStyle(
            fontSize: 18,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
      );
    }

    final isFilteredEmpty = filteredChapters != null && filteredChapters!.isEmpty;

    return Directionality(
      textDirection: textDirection,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/background.jpg").image,
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: _loadChapters,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: isFilteredEmpty ? 0 : filteredChapters!.length,
            itemBuilder: (context, index) {
              final chapter = filteredChapters![index];
              return _buildSurahItem(chapter, index);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _toArabicNumber(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicNumerals[digit] : char;
    }).join('');
  }
}