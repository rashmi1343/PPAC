import 'dart:convert';

PriceResponse priceResponseFromJson(String str) => PriceResponse.fromJson(json.decode(str));

String priceResponseToJson(PriceResponse data) => json.encode(data.toJson());

class PriceResponse {
  PriceResponse({
    required this.tableContents,
  });

  List<TableContent> tableContents;

  factory PriceResponse.fromJson(Map<String, dynamic> json) => PriceResponse(
    tableContents: List<TableContent>.from(json["TableContents"].map((x) => TableContent.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "TableContents": List<dynamic>.from(tableContents.map((x) => x.toJson())),
  };
}

class TableContent {
  TableContent({
    required this.productTitle,
    required this.reportFileName,
    required this.createdAt,
    required this.updatedAt,
    required this.rdId,
    required this.april,
    required this.may,
    required this.june,
    required this.july,
    required this.august,
    required this.september,
    required this.october,
    required this.november,
    required this.december,
    required this.january,
    required this.february,
    required this.march,
    required this.cols,
    required this.reportId,
  });

  String productTitle;
  String reportFileName;
  String createdAt;
  String updatedAt;
  String rdId;
  String april;
  String may;
  String june;
  String july;
  String august;
  String september;
  String october;
  String november;
  String december;
  String january;
  String february;
  String march;
  bool? cols;
  String reportId;

  factory TableContent.fromJson(Map<String, dynamic> json) => TableContent(
    productTitle: json["product_title"],
    reportFileName: json["report_file_name"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    rdId: json["rd_id"],
    april: json["april"],
    may: json["may"],
    june: json["june"],
    july: json["july"],
    august: json["august"],
    september: json["september"],
    october: json["october"],
    november: json["november"],
    december: json["december"],
    january: json["january"],
    february: json["february"],
    march: json["march"],
    cols: json["cols"],
    reportId: json["report_id"],
  );

  Map<String, dynamic> toJson() => {
    "product_title": productTitle,
    "report_file_name": reportFileName,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "rd_id": rdId,
    "april": april,
    "may": may,
    "june": june,
    "july": july,
    "august": august,
    "september": september,
    "october": october,
    "november": november,
    "december": december,
    "january": january,
    "february": february,
    "march": march,
    "cols": cols,
    "report_id": reportId,
  };
}
