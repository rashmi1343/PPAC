
import 'dart:convert';

CentralResponse centralResponseFromJson(String str) => CentralResponse.fromJson(json.decode(str));

String centralResponseToJson(CentralResponse data) => json.encode(data.toJson());

class CentralResponse {
  CentralResponse({
    required this.pageContents,
    required this.yearList,
    required this.viewDataIn,
    required this.htmlcontent,
    required this.tab,
    required this.tabs,
    required this.strtab
  });

  PageContents pageContents;
  List<String> yearList;
  List<String> viewDataIn;
  String htmlcontent;
  List<CentralTab> tab;
  List<String> tabs;
  List<String> strtab;

  factory CentralResponse.fromJson(Map<String, dynamic> json) => CentralResponse(
    pageContents: PageContents.fromJson(json["PageContents"]),
    yearList: List<String>.from(json["YearList"].map((x) => x)),
    viewDataIn: List<String>.from(json["View Data In"].map((x) => x)),
    htmlcontent: json["htmlcontent"],
    tab: List<CentralTab>.from(json["Tab"].map((x) => CentralTab.fromJson(x))),
    tabs: List<String>.from(json["Tabs"].map((x) => x)),
    strtab:List<String>.from(json["StrTab"].map((x) => x))
  );

  Map<String, dynamic> toJson() => {
    "PageContents": pageContents.toJson(),
    "YearList": List<dynamic>.from(yearList.map((x) => x)),
    "View Data In": List<dynamic>.from(viewDataIn.map((x) => x)),
    "htmlcontent": htmlcontent,
    "Tab": List<dynamic>.from(tab.map((x) => x.toJson())),
    "Tabs": List<dynamic>.from(tabs.map((x) => x)),
    "StrTab" : List<dynamic>.from(strtab.map((x) => x))
  };
}

class PageContents {
  String? id;
  String? pageName;
  String? pageTitle;
  String? pageSlug;
  String? metaTitle;
  String? metaDescriptions;
  String? metaKeywords;
  String? pageHeaderImage;
  String? pageContents;
  String? department;
  String? historyUpload;
  String? status;
  String? notification;
  String? language;
  String? isWhatsnew;
  String? createdAt;
  String? createdBy;
  String? updatedBy;
  String? updatedAt;
  String? baseurl;
  String? sourceUpload;

  PageContents(
      {this.id,
        this.pageName,
        this.pageTitle,
        this.pageSlug,
        this.metaTitle,
        this.metaDescriptions,
        this.metaKeywords,
        this.pageHeaderImage,
        this.pageContents,
        this.department,
        this.historyUpload,
        this.status,
        this.notification,
        this.language,
        this.isWhatsnew,
        this.createdAt,
        this.createdBy,
        this.updatedBy,
        this.updatedAt,
        this.baseurl,
        this.sourceUpload});

  PageContents.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pageName = json['page_name'];
    pageTitle = json['page_title'];
    pageSlug = json['page_slug'];
    metaTitle = json['meta_title'];
    metaDescriptions = json['meta_descriptions'];
    metaKeywords = json['meta_keywords'];
    pageHeaderImage = json['page_header_image'];
    pageContents = json['page_contents'];
    department = json['department'];
    historyUpload = json['history_upload'];
    status = json['status'];
    notification = json['notification'];
    language = json['language'];
    isWhatsnew = json['is_whatsnew'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    baseurl = json['baseurl'];
    sourceUpload = json['source_upload'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['page_name'] = this.pageName;
    data['page_title'] = this.pageTitle;
    data['page_slug'] = this.pageSlug;
    data['meta_title'] = this.metaTitle;
    data['meta_descriptions'] = this.metaDescriptions;
    data['meta_keywords'] = this.metaKeywords;
    data['page_header_image'] = this.pageHeaderImage;
    data['page_contents'] = this.pageContents;
    data['department'] = this.department;
    data['history_upload'] = this.historyUpload;
    data['status'] = this.status;
    data['notification'] = this.notification;
    data['language'] = this.language;
    data['is_whatsnew'] = this.isWhatsnew;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['baseurl'] = this.baseurl;
    data['source_upload'] = this.sourceUpload;
    return data;
  }
}

class CentralTab {

  String? nonGSTGoods;
  String? gSTGoods;
  String? exciseDutyOnExportOfPetrolDieselATF;


  CentralTab({required this.nonGSTGoods,
    required this.gSTGoods,
    required this.exciseDutyOnExportOfPetrolDieselATF});



  CentralTab.fromJson(Map<String, dynamic> json) {
    nonGSTGoods = json['Non-GST Goods'];
    gSTGoods = json['GST Goods'];
    exciseDutyOnExportOfPetrolDieselATF =
    json['Excise duty on Export of Petrol, Diesel & ATF'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Non-GST Goods'] = this.nonGSTGoods;
    data['GST Goods'] = this.gSTGoods;
    data['Excise duty on Export of Petrol, Diesel & ATF'] =
        this.exciseDutyOnExportOfPetrolDieselATF;
    return data;
  }
}

