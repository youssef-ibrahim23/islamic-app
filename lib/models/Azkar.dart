import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Azkar {
  final String category;
  final String count;
  final String description;
  final String reference;
  final String content;

  Azkar({
    required this.category,
    required this.count,
    required this.description,
    required this.reference,
    required this.content,
  });

  factory Azkar.fromJson(Map<String, dynamic> json) => Azkar(
        category: json["category"],
        count: json["count"],
        description: json["description"],
        reference: json["reference"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "count": count,
        "description": description,
        "reference": reference,
        "content": content,
      };

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

}