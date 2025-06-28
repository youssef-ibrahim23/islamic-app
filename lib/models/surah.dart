class QuranChapters {
  final List<Chapter> chapters;

  QuranChapters({
    required this.chapters,
  });

  factory QuranChapters.fromJson(Map<String, dynamic> json) => QuranChapters(
        chapters: List<Chapter>.from(
            json["chapters"].map((x) => Chapter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "chapters": List<dynamic>.from(chapters.map((x) => x.toJson())),
      };
}

class Chapter {
  final int id;
  final String revelationPlace;
  final int revelationOrder;
  final bool bismillahPre;
  final String nameSimple;
  final String nameComplex;
  final String nameArabic;
  final int versesCount;
  final List<int> pages;
  final TranslatedName translatedName;

  Chapter({
    required this.id,
    required this.revelationPlace,
    required this.revelationOrder,
    required this.bismillahPre,
    required this.nameSimple,
    required this.nameComplex,
    required this.nameArabic,
    required this.versesCount,
    required this.pages,
    required this.translatedName,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json["id"],
        revelationPlace: json["revelation_place"],
        revelationOrder: json["revelation_order"],
        bismillahPre: json["bismillah_pre"],
        nameSimple: json["name_simple"],
        nameComplex: json["name_complex"],
        nameArabic: json["name_arabic"],
        versesCount: json["verses_count"],
        pages: List<int>.from(json["pages"].map((x) => x)),
        translatedName: TranslatedName.fromJson(json["translated_name"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "revelation_place": revelationPlace,
        "revelation_order": revelationOrder,
        "bismillah_pre": bismillahPre,
        "name_simple": nameSimple,
        "name_complex": nameComplex,
        "name_arabic": nameArabic,
        "verses_count": versesCount,
        "pages": List<dynamic>.from(pages.map((x) => x)),
        "translated_name": translatedName.toJson(),
      };
}

class TranslatedName {
  final String languageName;
  final String name;

  TranslatedName({
    required this.languageName,
    required this.name,
  });

  factory TranslatedName.fromJson(Map<String, dynamic> json) => TranslatedName(
        languageName: json["language_name"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "language_name": languageName,
        "name": name,
      };
}