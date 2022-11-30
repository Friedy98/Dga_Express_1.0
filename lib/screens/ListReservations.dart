// To parse this JSON data, do
//
//     final listReservation = listReservationFromJson(jsonString);

import 'dart:convert';

List<ListReservation> listReservationFromJson(String str) => List<ListReservation>.from(json.decode(str).map((x) => ListReservation.fromJson(x)));

String listReservationToJson(List<ListReservation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListReservation {
  ListReservation({
    required this.id,
    required this.description,
    required this.documents,
    required this.computer,
    required this.status,
    required this.quantitykilo,
    required this.date,
    required this.totalprice,
    required this.track,
    required this.confirm,
    required this.quantityDocument,
    required this.quantityComputer,
    required this.receiver,
    required this.tel,
    required this.receivernumbercni,
    required this.userDto,
    required this.announcementDto,
  });

  String id;
  String description;
  bool documents;
  bool computer;
  String status;
  int quantitykilo;
  String date;
  int totalprice;
  String track;
  bool confirm;
  int quantityDocument;
  int quantityComputer;
  String receiver;
  String tel;
  String receivernumbercni;
  UserDto userDto;
  AnnouncementDto announcementDto;

  factory ListReservation.fromJson(Map<String, dynamic> json) => ListReservation(
    id: json["id"],
    description: json["description"],
    documents: json["documents"],
    computer: json["computer"],
    status: json["status"],
    quantitykilo: json["quantitykilo"],
    date: json["date"],
    totalprice: json["totalprice"],
    track: json["track"],
    confirm: json["confirm"],
    quantityDocument: json["quantityDocument"],
    quantityComputer: json["quantityComputer"],
    receiver: json["receiver"],
    tel: json["tel"],
    receivernumbercni: json["receivernumbercni"],
    userDto: UserDto.fromJson(json["userDto"]),
    announcementDto: AnnouncementDto.fromJson(json["announcementDto"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "documents": documents,
    "computer": computer,
    "status": status,
    "quantitykilo": quantitykilo,
    "date": date,
    "totalprice": totalprice,
    "track": track,
    "confirm": confirm,
    "quantityDocument": quantityDocument,
    "quantityComputer": quantityComputer,
    "receiver": receiver,
    "tel": tel,
    "receivernumbercni": receivernumbercni,
    "userDto": userDto.toJson(),
    "announcementDto": announcementDto.toJson(),
  };
}

class AnnouncementDto {
  AnnouncementDto({
   required this.id,
    required this.departuredate,
    required this.arrivaldate,
    required this.departuretown,
    required this.destinationtown,
    required this.quantity,
    required this.computer,
    required this.restriction,
    required this.document,
    required this.status,
    required this.cni,
    required this.ticket,
    required this.covidtest,
    required this.price,
    required this.validation,
    required this.point,
    required this.userDto,
  });

  String id;
  DateTime departuredate;
  DateTime arrivaldate;
  String departuretown;
  String destinationtown;
  int quantity;
  bool computer;
  String restriction;
  bool document;
  String status;
  String cni;
  String ticket;
  String covidtest;
  int price;
  bool validation;
  int point;
  UserDto userDto;

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) => AnnouncementDto(
    id: json["id"],
    departuredate: DateTime.parse(json["departuredate"]),
    arrivaldate: DateTime.parse(json["arrivaldate"]),
    departuretown: json["departuretown"],
    destinationtown: json["destinationtown"],
    quantity: json["quantity"],
    computer: json["computer"],
    restriction: json["restriction"],
    document: json["document"],
    status: json["status"],
    cni: json["cni"],
    ticket: json["ticket"],
    covidtest: json["covidtest"],
    price: json["price"],
    validation: json["validation"],
    point: json["point"],
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
    "status": status,
    "cni": cni,
    "ticket": ticket,
    "covidtest": covidtest,
    "price": price,
    "validation": validation,
    "point": point,
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
    required this.phone,
    //required this.transactionCodes,
    required this.roleDtos,
    required this.status,
    required this.level,
  });

  String id;
  String firstName;
  String lastName;
  String profileimgage;
  String? pseudo;
  String email;
  String phone;
  //List<TransactionCode> transactionCodes;
  List<RoleDto> roleDtos;
  String status;
  int level;

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profileimgage: json["profileimgage"],
    pseudo: json["pseudo"] ?? json[""],
    email: json["email"],
    phone: json["phone"],
    //transactionCodes: List<TransactionCode>.from(json["transactionCodes"].map((x) => TransactionCode.fromJson(x))),
    roleDtos: List<RoleDto>.from(json["roleDtos"].map((x) => RoleDto.fromJson(x))),
    status: json["status"],
    level: json["level"]
    //articles: List<Article>.from(json["articles"].map((x) => Article.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "profileimgage": profileimgage,
    "pseudo": pseudo,
    "email": email,
    "phone": phone,
    //"transactionCodes": List<dynamic>.from(transactionCodes.map((x) => x.toJson())),
    "roleDtos": List<dynamic>.from(roleDtos.map((x) => x.toJson())),
    "status": status,
    "level": level
    //"articles": List<dynamic>.from(articles.map((x) => x.toJson())),
  };
}

class Article {
  Article({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.status,
    required this.messages,
    required this.seller,
  });

  String id;
  String name;
  String description;
  int price;
  int quantity;
  String status;
  List<Message> messages;
  String seller;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"],
    quantity: json["quantity"],
    status: json["status"],
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    seller: json["seller"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "price": price,
    "quantity": quantity,
    "status": status,
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    "seller": seller,
  };
}

class Message {
  Message({
    required this.id,
    required this.content,
    required this.status,
    required this.reservationDto,
    required this.sendermessage,
    required this.receivermessage,
    required this.date,
    required this.article,
  });

  String id;
  String content;
  String status;
  String reservationDto;
  String sendermessage;
  String receivermessage;
  String date;
  String article;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    content: json["content"],
    status: json["status"],
    reservationDto: json["reservationDto"],
    sendermessage: json["sendermessage"],
    receivermessage: json["receivermessage"],
    date: json["date"],
    article: json["article"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "status": status,
    "reservationDto": reservationDto,
    "sendermessage": sendermessage,
    "receivermessage": receivermessage,
    "date": date,
    "article": article,
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

class TransactionCode {
  TransactionCode({
    required this.id,
    required this.code,
  });

  int id;
  String code;

  factory TransactionCode.fromJson(Map<String, dynamic> json) => TransactionCode(
    id: json["id"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
  };
}
