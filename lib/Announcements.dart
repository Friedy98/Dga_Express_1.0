// To parse this JSON data, do
//
//     final announcements = announcementsFromJson(jsonString);

import 'dart:convert';

List<Announcements> announcementsFromJson(String str) => List<Announcements>.from(json.decode(str).map((x) => Announcements.fromJson(x)));

String announcementsToJson(List<Announcements> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Announcements {
  Announcements({
    required this.id,
    required this.departuredate,
    required this.arrivaldate,
    required this.departuretown,
    required this.destinationtown,
    required this.quantity,
    required this.computer,
    required this.reserved,
    required this.restriction,
    required this.document,
    required this.status,
    required this.cni,
    required this.ticket,
    required this.covidtest,
    required this.price,
    required this.validation,
    required this.paymentMethod,
    required this.userDto,
  });

  String id;
  DateTime departuredate;
  DateTime arrivaldate;
  String departuretown;
  String destinationtown;
  int quantity;
  bool computer;
  bool reserved;
  String restriction;
  bool document;
  String status;
  String cni;
  String ticket;
  String covidtest;
  int price;
  bool validation;
  String paymentMethod;
  UserDto userDto;

  factory Announcements.fromJson(Map<String, dynamic> json) => Announcements(
    id: json["id"],
    departuredate: DateTime.parse(json["departuredate"]),
    arrivaldate: DateTime.parse(json["arrivaldate"]),
    departuretown: json["departuretown"],
    destinationtown: json["destinationtown"],
    quantity: json["quantity"],
    computer: json["computer"],
    restriction: json["restriction"],
    document: json["document"],
    reserved: json["reserved"],
    status: json["status"],
    cni: json["cni"],
    ticket: json["ticket"],
    covidtest: json["covidtest"],
    price: json["price"],
    validation: json["validation"],
    paymentMethod: json['paymentMethod'],
    userDto: UserDto.fromJson(json["userDto"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "departuredate": departuredate.toIso8601String(),
    "arrivaldate": arrivaldate.toIso8601String(),
    "departuretown": departuretown,
    "destinationtown": destinationtown,
    "quantity": quantity,
    "computer": computer,
    "restriction": restriction,
    "document": document,
    "cni": cni,
    "ticket": ticket,
    "covidtest": covidtest,
    "price": price,
    "validation": validation,
    "paymentMethod": paymentMethod,
    "userDto": userDto.toJson(),
  };
}

class UserDto {
  UserDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileimgage,
    required this.pseudo,
    required this.email,
    required this.roleDtos,
  });

  String id;
  String firstName;
  String lastName;
  String profileimgage;
  String? pseudo;
  String email;
  List<RoleDto> roleDtos;

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profileimgage: json["profileimgage"],
    pseudo: json["pseudo"] ?? json[""],
    email: json["email"],
    roleDtos: List<RoleDto>.from(json["roleDtos"].map((x) => RoleDto.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "profileimgage": profileimgage,
    "pseudo": pseudo,
    "email": email,
    "roleDtos": List<dynamic>.from(roleDtos.map((x) => x.toJson())),
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
