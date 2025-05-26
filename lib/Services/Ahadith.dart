import 'package:http/http.dart' as http;
import 'dart:convert';

class Hadith {
  final String arabicText;

  Hadith({required this.arabicText});

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      arabicText: json['arab'] ?? 'لا يوجد نص',
    );
  }
}

class HadithApi {
  static const String baseUrl =
      'https://hadis-api-id.vercel.app/hadith/abu-dawud';

  static Future<List<Hadith>> fetchHadiths(int page) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?page=$page'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('Response Data: $data');

        if (data['items'] != null) {
          return (data['items'] as List)
              .map((json) => Hadith.fromJson(json))
              .toList();
        } else {
          print('لا توجد بيانات في المفتاح "items"');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return [];
  }
}
