import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:islamic_app/screens/verses.dart';

class FavoritesListWidget extends StatelessWidget {
  final Map<int, String> favoriteSurahs;
  final bool isEnglish;
  final bool isPortrait;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Function(int, String) onToggleFavorite;
  final BuildContext context;

  const FavoritesListWidget({
    super.key,
    required this.favoriteSurahs,
    required this.isEnglish,
    required this.isPortrait,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
    required this.onToggleFavorite,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            _buildHeader(),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _buildList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
    );
  }

  Widget _buildList() {
    return ListView.separated(
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
        return _buildSurahCard(surah.key, surah.value, index);
      },
    );
  }

  Widget _buildSurahCard(int surahId, String surahName, int index) {
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
                surahName,
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
              onPressed: () => onToggleFavorite(surahId, surahName),
            ),
          ],
        ),
      ),
    ).animate(delay: 50.ms * index).fadeIn().slideX(begin: index.isEven ? -0.5 : 0.5);
  }
}