// To parse this JSON data, do
//
//     final listComments = listCommentsFromJson(jsonString);

import 'dart:convert';

List<ListComments> listCommentsFromJson(String str) => List<ListComments>.from(json.decode(str).map((x) => ListComments.fromJson(x)));

String listCommentsToJson(List<ListComments> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListComments {
  ListComments({
   required this.id,
    required this.content,
    required this.booker,
    required this.announcement,
    required this.status,
  });

  int id;
  String content;
  Booker booker;
  Announcement announcement;
  String status;

  factory ListComments.fromJson(Map<String, dynamic> json) => ListComments(
    id: json["id"],
    content: json["content"],
    booker: Booker.fromJson(json["booker"]),
    announcement: Announcement.fromJson(json["announcement"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "booker": booker.toJson(),
    "announcement": announcement.toJson(),
    "status": status,
  };
}

class Announcement {
  Announcement({
    required this.id,
  });

  String id;

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}

class Booker {
  Booker({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileimgage,
    required this.pseudo,
  });

  String id;
  String firstName;
  String lastName;
  String profileimgage;
  String pseudo;

  factory Booker.fromJson(Map<String, dynamic> json) => Booker(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profileimgage: json["profileimgage"],
    pseudo: json["pseudo"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "profileimgage": profileimgage,
    "pseudo": pseudo,
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
