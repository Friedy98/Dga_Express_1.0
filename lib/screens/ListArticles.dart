// To parse this JSON data, do
//
//     final listArticles = listArticlesFromJson(jsonString);

import 'dart:convert';

List<ListArticles> listArticlesFromJson(String str) => List<ListArticles>.from(json.decode(str).map((x) => ListArticles.fromJson(x)));

String listArticlesToJson(List<ListArticles> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListArticles {
  ListArticles({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.mainImage,
    required this.status,
    required this.date,
    required this.location,
    required this.paymentMethod,
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
  String paymentMethod;
  User user;
  Cathegory cathegory;

  factory ListArticles.fromJson(Map<String, dynamic> json) => ListArticles(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"],
    quantity: json["quantity"],
    mainImage: json["mainImage"],
    status: json["status"],
    date: json['date'],
    location: json['location'],
    paymentMethod: json['paymentMethod'],
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
    "paymentMethod": paymentMethod,
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
  });

  String id;
  String firstName;
  String lastName;
  String profileimgage;
  String? pseudo;
  String email;
  String phone;
  List<RoleDto> roleDtos;
  String status;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profileimgage: json["profileimgage"],
    pseudo: json["pseudo"] ?? json[""],
    email: json["email"],
    phone: json["phone"],
    roleDtos: List<RoleDto>.from(json["roleDtos"].map((x) => RoleDto.fromJson(x))),
    status: json["status"],
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
