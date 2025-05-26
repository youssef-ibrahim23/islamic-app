// To parse this JSON data, do
//
//     final apiModel = apiModelFromJson(jsonString);

import 'dart:convert';

ApiModel apiModelFromJson(String str) => ApiModel.fromJson(json.decode(str));

String apiModelToJson(ApiModel data) => json.encode(data.toJson());

class ApiModel {
    
    List<Empty> tentacled;
    List<Empty> indigo;
    List<Empty> indecent;
    List<Empty> sticky;
    List<Empty> purple;
    List<Empty> apiModel;
    List<Empty> empty;

    ApiModel({
        
        required this.tentacled,
        required this.indigo,
        required this.indecent,
        required this.sticky,
        required this.purple,
        required this.apiModel,
        required this.empty,
    });

    factory ApiModel.fromJson(Map<String, dynamic> json) => ApiModel(
       
        tentacled: List<Empty>.from(json["أذكار المساء"].map((x) => Empty.fromJson(x))),
        indigo: List<Empty>.from(json["أذكار بعد السلام من الصلاة المفروضة"].map((x) => Empty.fromJson(x))),
        indecent: List<Empty>.from(json["تسابيح"].map((x) => Empty.fromJson(x))),
        sticky: List<Empty>.from(json["أذكار النوم"].map((x) => Empty.fromJson(x))),
        purple: List<Empty>.from(json["أذكار الاستيقاظ"].map((x) => Empty.fromJson(x))),
        apiModel: List<Empty>.from(json["أدعية قرآنية"].map((x) => Empty.fromJson(x))),
        empty: List<Empty>.from(json["أدعية الأنبياء"].map((x) => Empty.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        
        "أذكار المساء": List<dynamic>.from(tentacled.map((x) => x.toJson())),
        "أذكار بعد السلام من الصلاة المفروضة": List<dynamic>.from(indigo.map((x) => x.toJson())),
        "تسابيح": List<dynamic>.from(indecent.map((x) => x.toJson())),
        "أذكار النوم": List<dynamic>.from(sticky.map((x) => x.toJson())),
        "أذكار الاستيقاظ": List<dynamic>.from(purple.map((x) => x.toJson())),
        "أدعية قرآنية": List<dynamic>.from(apiModel.map((x) => x.toJson())),
        "أدعية الأنبياء": List<dynamic>.from(empty.map((x) => x.toJson())),
    };
}

class Empty {
    Category category;
    String count;
    String description;
    String reference;
    String content;

    Empty({
        required this.category,
        required this.count,
        required this.description,
        required this.reference,
        required this.content,
    });

    factory Empty.fromJson(Map<String, dynamic> json) => Empty(
        category: categoryValues.map[json["category"]]!,
        count: json["count"],
        description: json["description"],
        reference: json["reference"],
        content: json["content"],
    );

    Map<String, dynamic> toJson() => {
        "category": categoryValues.reverse[category],
        "count": count,
        "description": description,
        "reference": reference,
        "content": content,
    };
}

enum Category {
    CATEGORY,
    EMPTY,
    FLUFFY,
    INDECENT,
    INDIGO,
    PURPLE,
    STICKY,
    STOP,
    TENTACLED
}

final categoryValues = EnumValues({
    "أدعية قرآنية": Category.CATEGORY,
    "أدعية الأنبياء": Category.EMPTY,
    "أذكار الصباح": Category.FLUFFY,
    "تسابيح": Category.INDECENT,
    "أذكار بعد السلام من الصلاة المفروضة": Category.INDIGO,
    "أذكار الاستيقاظ": Category.PURPLE,
    "أذكار النوم": Category.STICKY,
    "stop": Category.STOP,
    "أذكار المساء": Category.TENTACLED
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
