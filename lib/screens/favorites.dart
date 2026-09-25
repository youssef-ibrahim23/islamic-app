import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/globals.dart';
import 'package:islamic_app/services/favorites_service.dart';
import 'package:islamic_app/widgets/app_them.dart';
import 'package:islamic_app/widgets/favorites/empty_state_widget.dart';
import 'package:islamic_app/widgets/favorites/favorites_list_widget.dart';
import 'package:islamic_app/widgets/favorites/header_widget.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Map<int, String> favoriteSurahs = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.loadFavorites();
    setState(() => favoriteSurahs = favorites);
  }

  Future<void> _toggleFavorite(int surahId, String surahName) async {
    setState(() {
      if (favoriteSurahs.containsKey(surahId)) {
        favoriteSurahs.remove(surahId);
      } else {
        favoriteSurahs[surahId] = surahName;
      }
    });
    await FavoritesService.saveFavorites(favoriteSurahs);
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
              image: AssetImage("assets/images/background.jpg"),
              fit: BoxFit.cover,
              opacity: 0.9,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                HeaderWidget(isEnglish: isEnglish, isPortrait: isPortrait),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      if (favoriteSurahs.isEmpty)
                        EmptyStateWidget(
                          isEnglish: isEnglish,
                          isPortrait: isPortrait,
                          primaryColor: primaryColor,
                          textColor: textColor,
                        ).animate().fadeIn().slideY(begin: 0.2),
                      if (favoriteSurahs.isNotEmpty)
                        FavoritesListWidget(
                          favoriteSurahs: favoriteSurahs,
                          isEnglish: isEnglish,
                          isPortrait: isPortrait,
                          primaryColor: primaryColor,
                          accentColor: accentColor,
                          textColor: textColor,
                          onToggleFavorite: _toggleFavorite,
                          context: context,
                        ).animate().fadeIn().slideY(begin: 0.2),
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
