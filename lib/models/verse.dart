class QuranVerses {
  final List<Verse> verses;

  QuranVerses({required this.verses});

  factory QuranVerses.fromJson(Map<String, dynamic> json) {
    final verses = (json['verses'] as List)
        .map((verseJson) => Verse.fromJson(verseJson))
        .toList();
    return QuranVerses(verses: verses);
  }
}

class Verse {
  final int id;
  final String verseKey;
  final String textUthmani;

  Verse({
    required this.id,
    required this.verseKey,
    required this.textUthmani,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      id: json['id'],
      verseKey: json['verse_key'],
      textUthmani: json['text_uthmani'],
    );
  }
}
