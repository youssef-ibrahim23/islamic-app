import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/screens/verses.dart';
import 'package:islamic_app/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Map<int, String> favoriteSurahs = {};
  final Color primaryColor = const Color(0xFF8B0000);
  final Color accentColor = const Color(0xFFFFD700);
  final Color backgroundColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);
  final Color secondaryTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      favoriteSurahs = {
        for (var entry in favorites)
          int.parse(entry.split(':')[0]): entry.split(':')[1],
      };
    });
  }

  Future<void> toggleFavorite(int surahId, String surahName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteSurahs.containsKey(surahId)) {
        favoriteSurahs.remove(surahId);
      } else {
        favoriteSurahs[surahId] = surahName;
      }
    });

    await prefs.setStringList(
      'favorites',
      favoriteSurahs.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = Globals.languageState!;
    final size = MediaQuery.of(context).size;
    final bool isPortrait = size.height > size.width;

    return Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.8),
                Colors.white.withOpacity(0.1),
              ],
            ),
            image: const DecorationImage(
              image: AssetImage("assets/background.jpg"),
              fit: BoxFit.cover,
              opacity: 0.9,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header with gradient overlay
                Container(
                  width: double.infinity,
                  height: isPortrait ? size.height * 0.25 : size.height * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        isEnglish ? 'Favorites' : 'المفضلة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isPortrait ? 32 : 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEnglish ? 'Your favorite surahs' : 'السور المفضلة لديك',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isPortrait ? 16 : 14,
                          fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isPortrait ? 30 : 40),
                    ],
                  ),
                ),
      
      
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      if (favoriteSurahs.isEmpty)
                        _buildEmptyState(isEnglish, isPortrait)
                            .animate()
                            .fadeIn()
                            .slideY(begin: 0.2),
                      if (favoriteSurahs.isNotEmpty)
                        _buildFavoritesList(isEnglish, isPortrait)
                            .animate()
                            .fadeIn()
                            .slideY(begin: 0.2),
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

  Widget _buildEmptyState(bool isEnglish, bool isPortrait) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: primaryColor.withOpacity(0.5),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .then(delay: 200.ms)
              .shake(),
              const SizedBox(height: 20),
              Text(
                isEnglish ? 'No favorites yet' : 'لا يوجد مفضلة',
                style: TextStyle(
                  fontSize: isPortrait ? 22 : 20,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.5),
              const SizedBox(height: 12),
              Text(
                isEnglish
                    ? 'Tap the heart icon to add surahs'
                    : 'اضغط على أيقونة القلب لإضافة السور المفضلة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isPortrait ? 16 : 14,
                  color: textColor.withOpacity(0.8),
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(bool isEnglish, bool isPortrait) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite, color: primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEnglish ? 'Your Favorites' : 'المفضلة لديك',
                    style: TextStyle(
                      color: textColor,
                      fontSize: isPortrait ? 20 : 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: favoriteSurahs.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: primaryColor.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final surah = favoriteSurahs.entries.elementAt(index);
                return _buildSurahCard(
                    surah.key, surah.value, index, isEnglish, isPortrait);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahCard(
      int surahId, String surahName, int index, bool isEnglish, bool isPortrait) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(surahName, surahId, surahName),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Text(
                surahId.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isPortrait ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                surahName ,
                style: TextStyle(
                  fontSize: isPortrait ? 18 : 16,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: isEnglish ? 'Roboto' : 'Tajawal',
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: primaryColor,
                size: isPortrait ? 28 : 24,
              ),
              onPressed: () => toggleFavorite(surahId, surahName),
            ),
          ],
        ),
      ),
    ).animate(delay: 50.ms * index).fadeIn().slideX(begin: index.isEven ? -0.5 : 0.5);
  }
}