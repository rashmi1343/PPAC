
import 'dart:convert';

AllMediaGalleryResponse allMediaGalleryResponseFromJson(String str) => AllMediaGalleryResponse.fromJson(json.decode(str));

String allMediaGalleryResponseToJson(AllMediaGalleryResponse data) => json.encode(data.toJson());




class AllMediaGalleryResponse {
  List<AllMediaGalleryList>? allMediaGallery;

  AllMediaGalleryResponse({this.allMediaGallery});

  AllMediaGalleryResponse.fromJson(Map<String, dynamic> json) {
    if (json['Media Gallery'] != null) {
      allMediaGallery = <AllMediaGalleryList>[];
      json['Media Gallery'].forEach((v) {
        allMediaGallery!.add(new AllMediaGalleryList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.allMediaGallery != null) {
      data['Media Gallery'] = this.allMediaGallery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllMediaGalleryList {
  String? id;
  String? catTitle;
  String? thumbnailImage;
  String? createdDate;
  String? updatedAt;

  AllMediaGalleryList(
      {this.id,
        this.catTitle,
        this.thumbnailImage,
        this.createdDate,
        this.updatedAt});

  AllMediaGalleryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    catTitle = json['cat_title'];
    thumbnailImage = json['thumbnail_image'];
    createdDate = json['created_date'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cat_title'] = this.catTitle;
    data['thumbnail_image'] = this.thumbnailImage;
    data['created_date'] = this.createdDate;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}