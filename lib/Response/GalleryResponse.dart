
import 'dart:convert';

GalleryResponse galleryResponseFromJson(String str) => GalleryResponse.fromJson(json.decode(str));

String galleryResponseToJson(GalleryResponse data) => json.encode(data.toJson());



class GalleryResponse {
  List<MediaGallery>? mediaGallery;

  GalleryResponse({required this.mediaGallery});

  GalleryResponse.fromJson(Map<String, dynamic> json) {
    if (json['Media Gallery'] != null) {
      mediaGallery = <MediaGallery>[];
      json['Media Gallery'].forEach((v) {
        mediaGallery!.add(new MediaGallery.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mediaGallery != null) {
      data['Media Gallery'] = this.mediaGallery!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MediaGallery {
  String? id;
  String? catTitle;
  String? imagePath;
  String? imageTitle;

  MediaGallery(
      {  this.id,
         this.catTitle,
         this.imagePath,
         this.imageTitle,});

  MediaGallery.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    catTitle = json['cat_title'];
    imagePath = json['image_path'];
    imageTitle = json['image_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cat_title'] = this.catTitle;
    data['image_path'] = this.imagePath;
    data['image_title'] = this.imageTitle;
    return data;
  }
}