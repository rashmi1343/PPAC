

import 'dart:convert';

AboutModel aboutModelFromJson(String str) =>
    AboutModel.fromJson(json.decode(str));

String aboutModelToJson(AboutModel data) => json.encode(data.toJson());

class AboutModel {
  AboutModel({
    required this.content,
  });

  final List<Content> content;

  factory AboutModel.fromJson(Map<String, dynamic> json) => AboutModel(
        content:
            List<Content>.from(json["Content"].map((x) => Content.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Content": List<dynamic>.from(content.map((x) => x.toJson())),
      };
}

class Content {
  Content({
    required this.pageContents,
  });

  final String pageContents;

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        pageContents: json["page_contents"],
      );

  Map<String, dynamic> toJson() => {
        "page_contents": pageContents,
      };
}
