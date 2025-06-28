import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Hadith {
  final int number;
  final String arab;
  final String id;

  Hadith({
    required this.number,
    required this.arab,
    required this.id,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
        number: json["number"],
        arab: json["arab"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "arab": arab,
        "id": id,
      };

  static Future<List<Hadith>> loadHadithsByRange(int start, int end) async {
    try {
      final String response = await rootBundle.loadString('assets/Ahadith.JSON');
      final data = json.decode(response);
      final welcome = Welcome.fromJson(data);
      
      // Filter hadiths within the requested range
      return welcome.data.hadiths.where((hadith) => 
        hadith.number >= start && hadith.number <= end
      ).toList();
    } catch (e) {
      print("Error loading hadiths by range: $e");
      return [];
    }
  }
}

class Welcome {
  final Data data;

  Welcome({
    required this.data,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  final String name;
  final String id;
  final int available;
  final int requested;
  final List<Hadith> hadiths;

  Data({
    required this.name,
    required this.id,
    required this.available,
    required this.requested,
    required this.hadiths,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        name: json["name"],
        id: json["id"],
        available: json["available"],
        requested: json["requested"],
        hadiths: List<Hadith>.from(json["hadiths"].map((x) => Hadith.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "available": available,
        "requested": requested,
        "hadiths": List<dynamic>.from(hadiths.map((x) => x.toJson())),
      };
}