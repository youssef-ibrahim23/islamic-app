import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranAPIService {
  final String baseUrl = "https://api.quran.com/api/v4";

  Future<List<dynamic>> getSurahList() async {
    final response = await http.get(Uri.parse("$baseUrl/chapters"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['chapters'];
    } else {
      throw Exception("Failed to fetch Surah list");
    }
  }

  Future<List<dynamic>> getVersesForSurah(int surahId) async {
    final response = await http.get(
        Uri.parse("$baseUrl/quran/verses/uthmani?chapter_number=$surahId"));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body)['verses']);
      return jsonDecode(response.body)['verses'];
    } else {
      throw Exception("Failed to fetch verses");
    }
  }

  Future<List<dynamic>> getTranslationsForSurah(
      int surahId, int translationId) async {
    final response = await http.get(Uri.parse(
        "$baseUrl/quran/translations/$translationId?chapter_number=$surahId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['translations'];
    } else {
      throw Exception("Failed to fetch translations");
    }
  }
}
