class YearImportExportResponse {
  List<TableContents>? tableContents;

  YearImportExportResponse({required this.tableContents});

  YearImportExportResponse.fromJson(Map<String, dynamic> json) {
    if (json['TableContents'] != null) {
      tableContents = <TableContents>[];
      json['TableContents'].forEach((v) {
        tableContents!.add( TableContents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    if (tableContents != null) {
      data['TableContents'] =
          tableContents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TableContents {
  String? productTitle;
  String? reportFileName;
  String? createdAt;
  String? updatedAt;
  String? rdId;
  String? april;
  String? may;
  String? june;
  String? july;
  String? august;
  String? september;
  String? october;
  String? november;
  String? december;
  String? january;
  String? february;
  String? march;
  String? total;
  bool? cols;
  String? reportId;

  TableContents(
      {required this.productTitle,
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
      required this.total,
      required this.cols,
      required this.reportId});

  TableContents.fromJson(Map<String, dynamic> json) {
    productTitle = json['product_title'];
    reportFileName = json['report_file_name'];
    createdAt = json['created_date'];
    updatedAt = json['updated_at'];
    rdId = json['rd_id'];
    april = json['april'];
    may = json['may'];
    june = json['june'];
    july = json['july'];
    august = json['august'];
    september = json['september'];
    october = json['october'];
    november = json['november'];
    december = json['december'];
    january = json['january'];
    february = json['february'];
    march = json['march'];
    total = json['total'];
    cols = json['cols'];
    reportId = json['report_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['product_title'] = productTitle;
    data['report_file_name'] = reportFileName;
    data['created_date'] = createdAt;
    data['updated_at'] = updatedAt;
    data['rd_id'] = rdId;
    data['april'] = april;
    data['may'] = may;
    data['june'] = june;
    data['july'] = july;
    data['august'] = august;
    data['september'] = september;
    data['october'] = october;
    data['november'] = november;
    data['december'] = december;
    data['january'] = january;
    data['february'] = february;
    data['march'] = march;
    data['total'] = total;
    data['cols'] = cols;
    data['report_id'] = reportId;
    return data;
  }
}
