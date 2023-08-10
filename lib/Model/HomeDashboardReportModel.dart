

import 'dart:convert';

HomeDashboardReportModel homeDashboardReportModelFromJson(String str) =>
    HomeDashboardReportModel.fromJson(json.decode(str));

String homeDashboardReportModelToJson(HomeDashboardReportModel data) =>
    json.encode(data.toJson());

class HomeDashboardReportModel {
  HomeDashboardReportModel({
    this.report,
  });

  List<Report>? report;

  factory HomeDashboardReportModel.fromJson(Map<String, dynamic> json) =>
      HomeDashboardReportModel(
        report: json["Report"] == null
            ? []
            : List<Report>.from(json["Report"]!.map((x) => Report.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Report": report == null
            ? []
            : List<dynamic>.from(report!.map((x) => x.toJson())),
      };
}

class Report {
  Report({
    this.id,
    this.title,
    this.image,
    this.viewReport,
    this.createdAt,
    this.updatedAt,
  });

  String? id;
  String? title;
  String? image;
  String? viewReport;
  String? createdAt;
  String? updatedAt;

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        id: json["id"] ?? "",
        title: json["title"] ?? "",
        image: json["Image"] ?? "",
        viewReport: json["ViewReport"] ?? "",
        createdAt: json["created_date"] ?? "",
        updatedAt: json["updated_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "Image": image,
        "ViewReport": viewReport,
        "created_date": createdAt,
        "updated_at": updatedAt,
      };
}
