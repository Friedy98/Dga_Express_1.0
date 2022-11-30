// To parse this JSON data, do
//
//     final modelclass = modelclassFromJson(jsonString);

import 'dart:convert';

Modelclass modelclassFromJson(String str) => Modelclass.fromJson(json.decode(str));

String modelclassToJson(Modelclass data) => json.encode(data.toJson());

class Modelclass {
  Modelclass({
    this.notificationSize,
    this.newNotification,
  });

  int? notificationSize;
  List<NewNotification>? newNotification;

  factory Modelclass.fromJson(Map<String, dynamic> json) => Modelclass(
    notificationSize: json["notificationSize"],
    newNotification: List<NewNotification>.from(json["newNotification"].map((x) => NewNotification.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "notificationSize": notificationSize,
    "newNotification": List<dynamic>.from(newNotification!.map((x) => x.toJson())),
  };
}

class NewNotification {
  NewNotification({
    this.receiver,
    this.title,
    this.content,
  });

  String? receiver;
  String? title;
  String? content;

  factory NewNotification.fromJson(Map<String, dynamic> json) => NewNotification(
    receiver: json["receiver"],
    title: json["title"],
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "receiver": receiver,
    "title": title,
    "content": content,
  };
}
