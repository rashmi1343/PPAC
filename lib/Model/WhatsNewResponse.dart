

import 'dart:convert';

WhatsNewResponse whatsNewResponseFromJson(String str) =>
    WhatsNewResponse.fromJson(json.decode(str));

String whatsNewResponseToJson(WhatsNewResponse data) =>
    json.encode(data.toJson());

class WhatsNewResponse {
  WhatsNewResponse({
    this.whatsNew,
  });

  final List<WhatsNew>? whatsNew;

  factory WhatsNewResponse.fromJson(Map<String, dynamic> json) =>
      WhatsNewResponse(
        whatsNew: json["Whats New"] == null
            ? []
            : List<WhatsNew>.from(
                json["Whats New"]!.map((x) => WhatsNew.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Whats New": whatsNew == null
            ? []
            : List<dynamic>.from(whatsNew!.map((x) => x.toJson())),
      };
}

class WhatsNew {
  WhatsNew({
    this.id,
    this.title,
    this.urlSlug,
    this.imagePath,
    this.content,
    this.language,
    this.status,
    this.createdDate,
    this.updatedAt,
  });

  final String? id;
  final String? title;
  final String? urlSlug;
  final String? imagePath;
  final String? content;
  final Language? language;
  final String? status;
  final String? createdDate;
  final UpdatedAt? updatedAt;
  bool isdownload = false;

  factory WhatsNew.fromJson(Map<String, dynamic> json) => WhatsNew(
        id: json["id"],
        title: json["title"],
        urlSlug: json["url_slug"],
        imagePath: json["image_path"],
        content: json["content"],
        language: languageValues.map[json["language"]]!,
        status: json["status"],
        createdDate: json["created_date"],
        updatedAt: updatedAtValues.map[json["updated_at"]]!,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "url_slug": urlSlug,
        "image_path": imagePath,
        "content": content,
        "language": languageValues.reverse[language],
        "status": status,
        "created_date": createdDate,
        "updated_at": updatedAtValues.reverse[updatedAt],
      };
}

enum Language { EN }

final languageValues = EnumValues({"en": Language.EN});

enum UpdatedAt { THE_01011970 }

final updatedAtValues = EnumValues({"01-01-1970": UpdatedAt.THE_01011970});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
