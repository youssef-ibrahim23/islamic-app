import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/models/Azkar.dart';

class AzkarService {

  static late SharedPreferences _prefs;

  static Future<Map<String, List<Azkar>>> loadLocalAzkar() async {
  try {
    final String response = await rootBundle.loadString('assets/Azkar.JSON');
    final Map<String, dynamic> data = json.decode(response);

    Map<String, List<Azkar>> azkarCategories = {};

    data.forEach((key, value) {
      if (value is List) {
        List<Azkar> azkarList = value
            .whereType<Map<String, dynamic>>()
            .map((item) => Azkar.fromJson(item))
            .toList();

        azkarCategories[key] = azkarList;
      }
    });

    return azkarCategories;
  } catch (e) {
    print("Error loading local azkar: $e");
    return {};
  }
}

  // Initialize SharedPreferences
  static Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Load Azkar data from local JSON asset
  static Future<Map<String, List<Azkar>>> loadAzkarData() async {
    return loadLocalAzkar();
  }

  // Save completion count for a specific zikr
  static Future<void> saveCompletionCount(int index, int count) async {
    await _prefs.setInt('azkar_completion_$index', count);
  }

  // Load saved completion count
  static int loadCompletionCount(int index) {
    return _prefs.getInt('azkar_completion_$index') ?? 0;
  }
}
