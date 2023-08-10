import 'dart:convert';

ImportantNewsResponse importantNewsResponseFromJson(String str) => ImportantNewsResponse.fromJson(json.decode(str));

String importantNewsResponseToJson(ImportantNewsResponse data) => json.encode(data.toJson());

class ImportantNewsResponse {
  List<ImpNews>? impNews;

  ImportantNewsResponse({ required this.impNews});

  ImportantNewsResponse.fromJson(Map<String, dynamic> json) {
    if (json['ImpNews'] != null) {
      impNews = <ImpNews>[];
      json['ImpNews'].forEach((v) {
        impNews!.add(ImpNews.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (impNews != null) {
      data['ImpNews'] = impNews!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImpNews {
  String? id;
  String? title;
  String? urlSlug;
  String? imagePath;
  String? content;
  String? language;
  String? status;
  String? createdAt;
  String? updatedAt;
  bool isdownload=false;

  ImpNews(
      {this.id,
        this.title,
        this.urlSlug,
        this.imagePath,
        this.content,
        this.language,
        this.status,
        this.createdAt,
        this.updatedAt});

  ImpNews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    urlSlug = json['url_slug'];
    imagePath = json['image_path'];
    content = json['content'];
    language = json['language'];
    status = json['status'];

    createdAt = json['created_date'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['url_slug'] = urlSlug;
    data['image_path'] = imagePath;
    data['content'] = content;
    data['language'] = language;
    data['status'] = status;

    data['created_date'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
