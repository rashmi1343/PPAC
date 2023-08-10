

import 'dart:convert';

MainMenu mainMenuFromJson(String str) => MainMenu.fromJson(json.decode(str));

String mainMenuToJson(MainMenu data) => json.encode(data.toJson());

class MainMenu {
  MainMenu({
    required this.menu,
  });

  final List<Menu> menu;

  factory MainMenu.fromJson(Map<String, dynamic> json) => MainMenu(
        menu: List<Menu>.from(json["Menu"].map((x) => Menu.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Menu": List<dynamic>.from(menu.map((x) => x.toJson())),
      };
}

class Menu {
  Menu({
    this.nId = '',
    this.parentId = '',
    this.name = '',
    this.slug = '',
    this.targetBlank = '',
    this.position = '',
    this.language = '',
    this.status = '',
    this.createdAt = '',
    this.createdBy = '',
    this.updatedAt = '',
    this.updatedBy = '',
    this.relId = '',
    this.menuId = '',
    this.groupId = '',
    this.menuIcon = '',
  });

  final String nId;
  final String parentId;
  final String name;
  final String slug;
  final String targetBlank;
  final String position;
  final String language;
  final String status;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  final String relId;
  final String menuId;
  final String groupId;
  final String menuIcon;

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        nId: json["n_id"],
        parentId: json["parent_id"],
        name: json["name"],
        slug: json["slug"],
        targetBlank: json["target_blank"],
        position: json["position"],
        language: json["language"],
        status: json["status"],
        createdAt: json["created_at"],
        createdBy: json["created_by"],
        updatedAt: json["updated_at"],
        updatedBy: json["updated_by"],
        relId: json["rel_id"],
        menuId: json["menu_id"],
        groupId: json["group_id"],
      );

  Map<String, dynamic> toJson() => {
        "n_id": nId,
        "parent_id": parentId,
        "name": name,
        "slug": slug,
        "target_blank": targetBlank,
        "position": position,
        "language": language,
        "status": status,
        "created_at": createdAt,
        "created_by": createdBy,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
        "rel_id": relId,
        "menu_id": menuId,
        "group_id": groupId,
      };
}
