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

  Widget _buildSearchDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Directionality(
        textDirection: textDirection,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? "Search Surah" : "بحث عن سورة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontFamily: fontFamily,
                ),
              ).animate().fadeIn(duration: 200.ms),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                decoration: InputDecoration(
                  hintText: isEnglish ? "Enter Surah Name" : "أدخل اسم السورة",
                  hintStyle: TextStyle(
                    color: secondaryTextColor,
                    fontFamily: fontFamily,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                style: TextStyle(
                  fontFamily: fontFamily,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      isEnglish ? "Cancel" : "إلغاء",
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      isEnglish ? "Search" : "بحث",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ],
          ),
        ),
      ).animate().scaleXY(begin: 0.9),
    );
  }

  Widget _buildSurahItem(Chapter chapter, int index) {
    final isFavorite = favoriteSurahIds.containsKey(chapter.id);
    final surahNames = isFavorite
        ? favoriteSurahIds[chapter.id]!.split('|')
        : [chapter.nameSimple, chapter.nameArabic];

    final revelationPlace = (chapter.revelationPlace.toLowerCase() == "makkah")
        ? (isEnglish ? "Makkah" : "مكة")
        : (isEnglish ? "Madinah" : "المدينة");

    return Globals.languageState! ? Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.ltr,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToSurahDetail(chapter),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Surah Number Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
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
                        fontFamily: fontFamily,
                        fontSize: 17
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isEnglish 
                        ? CrossAxisAlignment.start 
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        isEnglish ? surahNames[0] : surahNames[1],
                        textAlign: isEnglish ? TextAlign.right : TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        revelationPlace,
                        textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
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
    ) : Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.ltr,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToSurahDetail(chapter),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? primaryColor : secondaryTextColor,
                  ),
                  onPressed: () => _toggleFavorite(chapter),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isEnglish 
                        ? CrossAxisAlignment.start 
                        : CrossAxisAlignment.end,
                    children: [
                      Text(
                        isEnglish ? surahNames[0] : surahNames[1],
                        textAlign: isEnglish ? TextAlign.right : TextAlign.right,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        revelationPlace,
                        textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 16,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Surah Number Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
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
                        fontFamily: fontFamily,
                        fontSize: 17
                      ),
                    ),
                  ),
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
      title: Text(
        isEnglish ? "Al Quran" : "القرآن الكريم",
        style: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 26,
        ),
      ).animate().fadeIn(duration: 300.ms),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar()),
        ),
      ).animate().fadeIn(duration: 300.ms),
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () => showDialog(
            context: context,
            builder: (context) => _buildSearchDialog(),
          ),
          child: const Icon(Icons.search, color: Colors.white),
        ).animate().scale(delay: 500.ms),
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