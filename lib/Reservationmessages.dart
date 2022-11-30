// To parse this JSON data, do
//
//     final listmessages = listmessagesFromJson(jsonString);

import 'dart:convert';

List<Listmessages> listmessagesFromJson(String str) => List<Listmessages>.from(json.decode(str).map((x) => Listmessages.fromJson(x)));

String listmessagesToJson(List<Listmessages> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Listmessages {
  Listmessages({
    required this.id,
    required this.content,
    required this.status,
    this.reservationDto,
    required this.sendermessage,
    required this.receivermessage,
    required this.date,
    //this.articleDto,
  });

  String id;
  String content;
  String status;
  ReservationDto? reservationDto;
  Receivermessage sendermessage;
  Receivermessage receivermessage;
  String date;
  //ArticleDto? articleDto;

  factory Listmessages.fromJson(Map<String, dynamic> json) => Listmessages(
    id: json["id"],
    content: json["content"],
    status: json["status"],
    reservationDto: ReservationDto.fromJson(json["reservationDto"] ?? json["receivermessage"]),
    sendermessage: Receivermessage.fromJson(json["sendermessage"]),
    receivermessage: Receivermessage.fromJson(json["receivermessage"]),
    date: json["date"],
    //articleDto: ArticleDto.fromJson(json["articleDto"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "status": status,
    "reservationDto": reservationDto!.toJson(),
    "sendermessage": sendermessage.toJson(),
    "receivermessage": receivermessage.toJson(),
    "date": date,
    //"articleDto": articleDto!.toJson(),
  };
}
class Receivermessage {
  Receivermessage({
    required this.id,
    //required this.notificationId,
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
  //String notificationId;
  String firstName;
  String lastName;
  String profileimgage;
  String pseudo;
  String email;
  String phone;
  List<RoleDto> roleDtos;
  String status;

  factory Receivermessage.fromJson(Map<String, dynamic> json) => Receivermessage(
    id: json["id"],
    //notificationId: json["notificationId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    profileimgage: json["profileimgage"],
    pseudo: json["pseudo"],
    email: json["email"],
    phone: json["phone"],
    roleDtos: List<RoleDto>.from(json["roleDtos"].map((x) => RoleDto.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    //"notificationId": notificationId,
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

class ReservationDto {
  ReservationDto({
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
    //this.userDto,
    //this.announcementDto,
  });

  String id;
  String? description;
  bool? documents;
  bool? computer;
  String? status;
  int? quantitykilo;
  String? date;
  int? totalprice;
  String? track;
  bool? confirm;
  int? quantityDocument;
  int? quantityComputer;
  String? receiver;
  String? tel;
  String? receivernumbercni;
  //Receivermessage? userDto;
  //AnnouncementDto? announcementDto;

  factory ReservationDto.fromJson(Map<String, dynamic> json) => ReservationDto(
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
    //userDto: Receivermessage.fromJson(json["userDto"] ?? json["receivernumbercni"]),
    //announcementDto: AnnouncementDto.fromJson(json["announcementDto"] ?? json["userDto"]),
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
    //"userDto": userDto!.toJson(),
    //"announcementDto": announcementDto!.toJson(),
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
    required this.reserved,
    required this.restriction,
    required this.document,
    required this.status,
    required this.cni,
    required this.ticket,
    required this.covidtest,
    required this.price,
    required this.validation,
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
  Receivermessage userDto;

  factory AnnouncementDto.fromJson(Map<String, dynamic> json) => AnnouncementDto(
    id: json["id"],
    departuredate: DateTime.parse(json["departuredate"]),
    arrivaldate: DateTime.parse(json["arrivaldate"]),
    departuretown: json["departuretown"],
    destinationtown: json["destinationtown"],
    quantity: json["quantity"],
    computer: json["computer"],
    reserved: json["reserved"],
    restriction: json["restriction"],
    document: json["document"],
    status: json["status"],
    cni: json["cni"],
    ticket: json["ticket"],
    covidtest: json["covidtest"],
    price: json["price"],
    validation: json["validation"],
    userDto: Receivermessage.fromJson(json["userDto"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "departuredate": departuredate.toIso8601String(),
    "arrivaldate": arrivaldate.toIso8601String(),
    "departuretown": departuretown,
    "destinationtown": destinationtown,
    "quantity": quantity,
    "computer": computer,
    "reserved": reserved,
    "restriction": restriction,
    "document": document,
    "status": status,
    "cni": cni,
    "ticket": ticket,
    "covidtest": covidtest,
    "price": price,
    "validation": validation,
    "userDto": userDto.toJson(),
  };
}
