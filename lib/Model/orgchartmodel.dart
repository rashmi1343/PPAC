import 'dart:convert';
import 'dart:core';

class objnodes {
  objnodes({required this.orgchartlist, required this.edges});

  List<orgchartmodel> orgchartlist;
  List<objedges> edges;

  Map toJson() => {
        'nodes': orgchartlist,
        'edges': edges,
      };
}

class objedges {
  objedges({required this.from, required this.to});

  String from;
  String to;

  Map toJson() => {
        'from': from,
        'to': to,
      };
}

class orgchartmodel {
  orgchartmodel(
      {required this.department,
      required this.membername,
      required this.designation,
      required this.counter});

  String department;
  String membername;
  String designation;
  int counter;

  Map toJson() => {
        'department': department,
        'membername': membername,
        'designation': designation,
        'counter': counter
      };
}

class contentdataindexwise {
  contentdataindexwise(
      {required this.counter, required this.introductioncontent});

  int counter;
  String introductioncontent;
}

class memberinfo {
  memberinfo(
      {required this.department,
      required this.membername,
      required this.designation,
      required this.counter,
      required this.introductioncontent});

  String department;
  String membername;
  String designation;
  int counter;
  String introductioncontent;
}

objmemberresponse orgchartResponseFromJson(String str) =>
    objmemberresponse.fromJson(json.decode(str));

String menuByCountryResponseToJson(objmemberresponse data) =>
    json.encode(data.toJson());

class objmemberresponse {
  objmemberresponse({required this.arrorgmember});

  List<objmember> arrorgmember;

  factory objmemberresponse.fromJson(Map<String, dynamic> json) =>
      objmemberresponse(
          arrorgmember: List<objmember>.from(
        json["OrgChart"].map((x) => objmember.fromJson(x)),
      ));

  Map<String, dynamic> toJson() => {
        "OrgChart": List<dynamic>.from(arrorgmember.map((x) => x.toJson())),
      };
}

class objmember {
  objmember({
    required this.department,
    required this.membername,
    required this.designation,
    required this.introductioncontent,
    required this.imgurl,
    required this.isexpand,
    required this.childData,
  });

  String department;
  String membername;
  String designation;
  String introductioncontent;
  String imgurl;
  List<objmember> childData;
  bool isexpand;

  factory objmember.fromJson(Map<String, dynamic> json) => objmember(
        department: json["department"].isNull ? '' : json["department"],
        membername: json["membername"],
        designation: json["designation"],
        introductioncontent: json["introductioncontent"],
        imgurl: json["imgurl"],
        childData: json["children"].length > 0
            ? List<objmember>.from(
                json["children"].map((x) => objmember.fromJson(x)))
            : [],
        isexpand: json["children"].length > 0 ? true : false,
      );

  Map<String, dynamic> toJson() => {
        'department': department,
        'membername': membername,
        'designation': designation,
        'introductioncontent': introductioncontent,
        'imgurl': imgurl,
        'childData': List<dynamic>.from(childData.map((x) => x.toJson())),
        'isexpand': childData.length > 0 ? true : false,
      };
}
