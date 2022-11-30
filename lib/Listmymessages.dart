// To parse this JSON data, do
//
//     final listArticlemessages = listArticlemessagesFromJson(jsonString);

import 'dart:convert';

import 'Reservationmessages.dart';

List<Listmymessages> listArticlemessagesFromJson(String str) => List<Listmymessages>.from(json.decode(str).map((x) => Listmymessages.fromJson(x)));

String listArticlemessagesToJson(List<Listmymessages> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Listmymessages {

  Listmymessages({
    required this.id,
    required this.content,
    required this.status,
    required this.sendermessage,
    required this.receivermessage,
    required this.date,
    this.reservationDto,
    this.articleDto,
  });

  String id;
  String content;
  String status;
  Receivermessage sendermessage;
  Receivermessage receivermessage;
  String date;
  ReservationDto? reservationDto;
  ArticleDto? articleDto;

  factory Listmymessages.fromJson(Map<String, dynamic> json) => Listmymessages(
    id: json["id"],
    content: json["content"],
    status: json["status"],
    sendermessage: Receivermessage.fromJson(json["sendermessage"]),
    receivermessage: Receivermessage.fromJson(json["receivermessage"]),
    date: json["date"],
    articleDto: ArticleDto.fromJson(json["articleDto"] ?? json['reservationDto']),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "status": status,
    "sendermessage": sendermessage.toJson(),
    "receivermessage": receivermessage.toJson(),
    "date": date,
    "reservationDto": reservationDto!.toJson(),
    "articleDto": articleDto!.toJson(),
  };
}

class ArticleDto {
  ArticleDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.mainImage,
    required this.status,
    required this.date,
    required this.location,
    //required this.user,
    //required this.cathegory,
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
  //Receivermessage user;
  //Cathegory cathegory;

  factory ArticleDto.fromJson(Map<String, dynamic> json) => ArticleDto(
    id: json["id"],
    name: json["name"] ?? "",
    description: json["description"],
    price: json["price"] ?? 0,
    quantity: json["quantity"] ?? 0,
    mainImage: json["mainImage"] ?? "",
    status: json["status"],
    date: json["date"] ?? "",
    location: json["location"] ?? "",
    //user: Receivermessage.fromJson(json["user"] ?? json[""]),
    //cathegory: Cathegory.fromJson(json["cathegory"] ?? json[""]),
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
    //"user": user.toJson(),
    //"cathegory": cathegory.toJson(),
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
  Receivermessage user;

  factory Cathegory.fromJson(Map<String, dynamic> json) => Cathegory(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    status: json["status"],
    user: Receivermessage.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "status": status,
    "user": user.toJson(),
  };
}

class Receivermessage {
  Receivermessage({
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

  factory Receivermessage.fromJson(Map<String, dynamic> json) => Receivermessage(
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
