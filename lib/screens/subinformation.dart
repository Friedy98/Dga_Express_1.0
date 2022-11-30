// To parse this JSON data, do
//
//     final subinformation = subinformationFromJson(jsonString);

import 'dart:convert';

List<Subinformation> subinformationFromJson(String str) => List<Subinformation>.from(json.decode(str).map((x) => Subinformation.fromJson(x)));

String subinformationToJson(List<Subinformation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Subinformation {
  Subinformation({
    required this.id,
    required this.informations,
    required this.currency,
    required this.computerPrice,
    required this.documentPrice,
    required this.link,
    //required this.user,
  });

  String id;
  String informations;
  String currency;
  String computerPrice;
  String documentPrice;
  String link;
  //User user;

  factory Subinformation.fromJson(Map<String, dynamic> json) => Subinformation(
    id: json["id"],
    informations: json["informations"],
    currency: json["currency"],
    computerPrice: json["computerPrice"],
    documentPrice: json["documentPrice"],
    link: json["link"],
    //user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "informations": informations,
    "currency": currency,
    "computerPrice": computerPrice,
    "documentPrice": documentPrice,
    "link": link,
    //"user": user.toJson(),
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
    required this.stars,
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
  int stars;

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
    stars: json["stars"],
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
    "stars": stars,
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
