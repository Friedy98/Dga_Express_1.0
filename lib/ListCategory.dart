// To parse this JSON data, do
//
//     final listCategory = listCategoryFromJson(jsonString);

import 'dart:convert';

List<ListCategory> listCategoryFromJson(String str) => List<ListCategory>.from(json.decode(str).map((x) => ListCategory.fromJson(x)));

String listCategoryToJson(List<ListCategory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListCategory {
  ListCategory({
    required this.id,
    required this.name,
    required this.description,
    //required this.status,
    required this.user,
  });

  String id;
  String name;
  String description;
  //String status;
  User user;

  factory ListCategory.fromJson(Map<String, dynamic> json) => ListCategory(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    //status: json["status"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    //"status": status,
    "user": user.toJson(),
  };
}

class User {
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    //required this.profileimgage,
    required this.pseudo,
    required this.email,
    required this.phone,
    required this.roleDtos,
    required this.status,
    required this.level,
  });

  String id;
  String firstName;
  String lastName;
  //String profileimgage;
  String pseudo;
  String email;
  String phone;
  List<RoleDto> roleDtos;
  String status;
  int level;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    //profileimgage: json["profileimgage"],
    pseudo: json["pseudo"],
    email: json["email"],
    phone: json["phone"],
    roleDtos: List<RoleDto>.from(json["roleDtos"].map((x) => RoleDto.fromJson(x))),
    status: json["status"],
    level: json["level"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    //"profileimgage": profileimgage,
    "pseudo": pseudo,
    "email": email,
    "phone": phone,
    "roleDtos": List<dynamic>.from(roleDtos.map((x) => x.toJson())),
    "status": status,
    "level": level,
  };
}

class RoleDto {
  RoleDto({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory RoleDto.fromJson(Map<String, dynamic> json) => RoleDto(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
