import 'package:flutter/material.dart';
import 'package:islamic_app/SurahP.dart';
import 'package:islamic_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Map<int, String> favoriteSurahs = {}; // Store Surah ID and Name in a Map

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  // Load the favorite Surahs from SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites =
        prefs.getStringList('favorites') ?? []; // Retrieve favorites list

    // Populate the favoriteSurahs map with ID and Name from saved favorites
    setState(() {
      favoriteSurahs = {
        for (var entry in favorites)
          int.parse(entry.split(':')[0]): entry.split(':')[1], // ID -> Name
      };
    });
  }

  // Add or Remove a Surah from favorites
  Future<void> toggleFavorite(int surahId, String surahName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteSurahs.containsKey(surahId)) {
        // If the Surah is already in favorites, remove it
        favoriteSurahs.remove(surahId);
      } else {
        // If it's not in favorites, add it
        favoriteSurahs[surahId] = surahName;
      }
    });

    // Update SharedPreferences by saving the updated list of favorites
    await prefs.setStringList(
      'favorites',
      favoriteSurahs.entries
          .map((e) => '${e.key}:${e.value}')
          .toList(), // ID:Name format
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b3d27),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          languageState! ? 'Favorites' : 'المفضلة',
          style: TextStyle(
              fontFamily: languageState! ? 'cursive' : 'Lateef',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 30),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0b3d27),
      ),
      body: favoriteSurahs.isEmpty
          ? Center(
              child: Text(
                languageState! ? 'No favorites added yet!' : 'لا يوجد مفضلة',
                style: TextStyle(
                    fontFamily: languageState! ? 'fantasy' : 'Lateef',
                    fontSize: 18,
                    color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: favoriteSurahs.length,
              itemBuilder: (context, index) {
                final surah = favoriteSurahs.entries
                    .elementAt(index); // Get entry by index
                return Card(
                  shadowColor: const Color(0xFF0b3d27),
                  elevation: 5,
                  color: const Color(0xFF0b3d27),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SurahDetailPage(
                                  surah.value, surah.key, surah.value)));
                    },
                    title: Text(
                      surah.value,
                      style: TextStyle(color: Colors.white),
                    ), // Display the name of the Surah
                    trailing: IconButton(
                      icon: Icon(
                        favoriteSurahs.containsKey(surah.key)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        // Toggle favorite status of Surah
                        toggleFavorite(surah.key, surah.value);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
