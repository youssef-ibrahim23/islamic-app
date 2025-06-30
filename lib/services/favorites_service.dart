import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static Future<Map<int, String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    return {
      for (var entry in favorites)
        int.parse(entry.split(':')[0]): entry.split(':')[1],
    };
  }

  static Future<void> saveFavorites(Map<int, String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites',
      favorites.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
  }
}