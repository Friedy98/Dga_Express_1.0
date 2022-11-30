// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

List<Post> postFromJson(String str) => List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

String postToJson(List<Post> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post {
  Post({
    required this.departureDate,
    required this.arrivalDate,
    required this.departureTown,
    required this.quantity,
    required this.description,
    required this.document,
    required this.status,
    required this.cni,
    required this.ticket,
    required this.covidTest,
    required this.price,
    required this.user,
    required this.destinationTown,
  });

  DateTime departureDate;
  DateTime arrivalDate;
  String departureTown;
  int quantity;
  String description;
  String document;
  String status;
  String cni;
  String ticket;
  String covidTest;
  int price;
  User user;
  String destinationTown;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    departureDate: DateTime.parse(json["departureDate"]),
    arrivalDate: DateTime.parse(json["arrival_date"]),
    departureTown: json["departure_town"],
    quantity: json["quantity"],
    description: json["description"],
    document: json["document"],
    status: json["status"],
    cni: json["cni"],
    ticket: json["ticket"],
    covidTest: json["covidTest"],
    price: json["price"],
    user: User.fromJson(json["user"]),
    destinationTown: json["destination_town"],
  );

  Map<String, dynamic> toJson() => {
    "departureDate": departureDate.toIso8601String(),
    "arrival_date": arrivalDate.toIso8601String(),
    "departure_town": departureTown,
    "quantity": quantity,
    "description": description,
    "document": document,
    "status": status,
    "cni": cni,
    "ticket": ticket,
    "covidTest": covidTest,
    "price": price,
    "user": user.toJson(),
    "destination_town": destinationTown,
  };
}

class User {
  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.pseudo,
    required this.role,
    required this.password,
    required this.email,
  });

  int userId;
  String firstName;
  String lastName;
  String pseudo;
  String role;
  String password;
  String email;

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["userId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    pseudo: json["pseudo"],
    role: json["role"],
    password: json["password"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "firstName": firstName,
    "lastName": lastName,
    "pseudo": pseudo,
    "role": role,
    "password": password,
    "email": email,
  };
}
