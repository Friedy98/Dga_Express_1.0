// To parse this JSON data, do
//
//     final dataModel = dataModelFromJson(jsonString);

import 'dart:convert';

DataModel dataModelFromJson(String str) => DataModel.fromJson(json.decode(str));

String dataModelToJson(DataModel data) => json.encode(data.toJson());

class DataModel {
  DataModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.pseudo,
    required this.email,
    required this.roleDtos,
    required this.status,
  });

  String id;
  String firstName;
  String lastName;
  String pseudo;
  String email;
  List<RoleDto> roleDtos;
  String status;

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    pseudo: json["pseudo"],
    email: json["email"],
    roleDtos: List<RoleDto>.from(json["roleDtos"].map((x) => RoleDto.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "pseudo": pseudo,
    "email": email,
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
