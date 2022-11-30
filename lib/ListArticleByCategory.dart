// To parse this JSON data, do
//
//     final listArticleByCategory = listArticleByCategoryFromJson(jsonString);

import 'dart:convert';

List<ListArticleByCategory> listArticleByCategoryFromJson(String str) => List<ListArticleByCategory>.from(json.decode(str).map((x) => ListArticleByCategory.fromJson(x)));

String listArticleByCategoryToJson(List<ListArticleByCategory> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListArticleByCategory {
  ListArticleByCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.mainImage,
    required this.status,
    required this.date,
    required this.location,
    required this.user,
    required this.cathegory,
  });

  String id;
  String name;
  String description;
  int price;
  int quantity;
  String mainImage;
  String status;
  String date;
  String location;
  User user;
  Cathegory cathegory;

  factory ListArticleByCategory.fromJson(Map<String, dynamic> json) => ListArticleByCategory(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"],
    quantity: json["quantity"],
    mainImage: json["mainImage"],
    status: json["status"],
    date: json["date"],
    location: json["location"],
    user: User.fromJson(json["user"]),
    cathegory: Cathegory.fromJson(json["cathegory"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
    "quantity": quantity,
    "mainImage": mainImage,
    "status": status,
    "date": date,
    "location": location,
    "user": user.toJson(),
    "cathegory": cathegory.toJson(),
  };
}

class Cathegory {
  Cathegory({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.user,
  });

  String id;
  String name;
  String description;
  String status;
  User user;

  factory Cathegory.fromJson(Map<String, dynamic> json) => Cathegory(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    status: json["status"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "status": status,
    "user": user.toJson(),
  };
}

class User {
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileimgage,
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
  String profileimgage;
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
    profileimgage: json["profileimgage"],
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
    "profileimgage": profileimgage,
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
