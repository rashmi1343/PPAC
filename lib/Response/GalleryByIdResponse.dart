
import 'dart:convert';

GalleryByIdResponse galleryByIdResponseFromJson(String str) => GalleryByIdResponse.fromJson(json.decode(str));

String galleryByIdResponseToJson(GalleryByIdResponse data) => json.encode(data.toJson());


class GalleryByIdResponse {
  List<Gallery>? gallery;

  GalleryByIdResponse({this.gallery});

  GalleryByIdResponse.fromJson(Map<String, dynamic> json) {
    if (json['Gallery'] != null) {
      gallery = <Gallery>[];
      json['Gallery'].forEach((v) {
        gallery!.add(Gallery.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (gallery != null) {
      data['Gallery'] = gallery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Gallery {
  String? id;
  String? catId;
  String? catTitle;
  String? thumbnailImage;
  String? imageTitle;

  Gallery(
      {this.id,
        this.catId,
        this.catTitle,
        this.thumbnailImage,
        this.imageTitle});

  Gallery.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    catId = json['cat_id'];
    catTitle = json['cat_title'];
    thumbnailImage = json['thumbnail_image'];
    imageTitle = json['image_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['cat_id'] = catId;
    data['cat_title'] = catTitle;
    data['thumbnail_image'] = thumbnailImage;
    data['image_title'] = imageTitle;
    return data;
  }
}