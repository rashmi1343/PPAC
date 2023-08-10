import 'dart:convert';

RtiResponse rtiResponseFromJson(String str) => RtiResponse.fromJson(json.decode(str));

String rtiResponseToJson(RtiResponse data) => json.encode(data.toJson());

class RtiResponse {
  RtiResponse({
    required this.rtiData,
    required this.htmlcontent,
    required this.pageTitle,
  });

  List<RtiData> rtiData;
  String htmlcontent;
  String pageTitle;

  factory RtiResponse.fromJson(Map<String, dynamic> json) => RtiResponse(
    rtiData: List<RtiData>.from(json["RtiData"].map((x) => RtiData.fromJson(x))),
    htmlcontent: json["htmlcontent"],
    pageTitle: json["Page Title"],
  );

  Map<String, dynamic> toJson() => {
    "RtiData": List<dynamic>.from(rtiData.map((x) => x.toJson())),
    "htmlcontent": htmlcontent,
    "Page Title": pageTitle,
  };
}

class RtiData {
  RtiData({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.imagePath,
    required this.externalUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;
  String title;
  String fileUrl;
  String imagePath;
  String externalUrl;
  String content;
  String createdAt;
  String updatedAt;

  factory RtiData.fromJson(Map<String, dynamic> json) => RtiData(
    id: json["id"],
    title: json["title"],
    fileUrl: json["file_url"],
    imagePath: json["image_path"],
    externalUrl: json["external_url"],
    content: json["content"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "file_url": fileUrl,
    "image_path": imagePath,
    "external_url": externalUrl,
    "content": content,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

