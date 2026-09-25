// ignore_for_file: file_names

class Azkar {
  final String category;
  final String count;
  final String description;
  final String reference;
  final String content;
  final bool basmala;

  Azkar({
    required this.category,
    required this.count,
    required this.description,
    required this.reference,
    required this.content,
    this.basmala = false,
  });

  factory Azkar.fromJson(Map<String, dynamic> json) => Azkar(
        category: json["category"],
        count: json["count"],
        description: json["description"],
        reference: json["reference"],
        content: json["content"],
        basmala: json["basmala"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "category": category,
        "count": count,
        "description": description,
        "reference": reference,
        "content": content,
        "basmala": basmala,
      };
}
