import 'dart:convert';
import 'package:http/http.dart' as http;

class AladhanAPIService {
  final String baseUrl = "http://api.aladhan.com/v1";

  Future<Map<String, dynamic>> getPrayerTimes(
      String address, String country) async {
    
    
    
    final response = await http.get(Uri.parse(
        "https://api.aladhan.com/v1/timingsByAddress?address=$address,$country"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load prayer times");
    }
  }
}
