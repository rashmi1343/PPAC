import 'dart:convert';

GasPriceResponse gasPriceResponseFromJson(String str) => GasPriceResponse.fromJson(json.decode(str));

String gasPriceResponseToJson(GasPriceResponse data) => json.encode(data.toJson());

class GasPriceResponse {
  GasPriceResponse({
    required this.gasPrice,
    required this.htmlcontent,
    required this.pageTitle,
  });

  List<GasPrice> gasPrice;
  String htmlcontent;
  String pageTitle;

  factory GasPriceResponse.fromJson(Map<String, dynamic> json) => GasPriceResponse(
    gasPrice: List<GasPrice>.from(json["GasPrice"].map((x) => GasPrice.fromJson(x))),
    htmlcontent: json["htmlcontent"],
    pageTitle: json["Page Title"],
  );

  Map<String, dynamic> toJson() => {
    "GasPrice": List<dynamic>.from(gasPrice.map((x) => x.toJson())),
    "htmlcontent": htmlcontent,
    "Page Title": pageTitle,
  };
}

class GasPrice {
  GasPrice({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;
  String title;
  String imagePath;
  String content;
  String createdAt;
  String updatedAt;

  factory GasPrice.fromJson(Map<String, dynamic> json) => GasPrice(
    id: json["id"],
    title: json["title"],
    imagePath: json["image_path"],
    content: json["content"],
    createdAt:json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "image_path": imagePath,
    "content": content,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
