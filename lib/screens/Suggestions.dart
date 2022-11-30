// To parse this JSON data, do
//
//     final listImages = listImagesFromJson(jsonString);

import 'dart:convert';

List<Suggestions> listImagesFromJson(String str) => List<Suggestions>.from(json.decode(str).map((x) => Suggestions.fromJson(x)));

String listImagesToJson(List<Suggestions> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Suggestions {
  Suggestions({
    required this.description,
    required this.matchedSubstrings,
    required this.placeId,
    required this.reference,
    required this.structuredFormatting,
  });

  String description;
  List<MatchedSubstring> matchedSubstrings;
  String placeId;
  String reference;
  StructuredFormatting structuredFormatting;

  factory Suggestions.fromJson(Map<String, dynamic> json) => Suggestions(
    description: json["description"],
    matchedSubstrings: List<MatchedSubstring>.from(json["matched_substrings"].map((x) => MatchedSubstring.fromJson(x))),
    placeId: json["place_id"],
    reference: json["reference"],
    structuredFormatting: StructuredFormatting.fromJson(json["structured_formatting"]),
  );

  Map<String, dynamic> toJson() => {
    "description": description,
    "matched_substrings": List<dynamic>.from(matchedSubstrings.map((x) => x.toJson())),
    "place_id": placeId,
    "reference": reference,
    "structured_formatting": structuredFormatting.toJson(),
  };
}

class MatchedSubstring {
  MatchedSubstring({
    required this.length,
    required this.offset,
  });

  int length;
  int offset;

  factory MatchedSubstring.fromJson(Map<String, dynamic> json) => MatchedSubstring(
    length: json["length"],
    offset: json["offset"],
  );

  Map<String, dynamic> toJson() => {
    "length": length,
    "offset": offset,
  };
}

class StructuredFormatting {
  StructuredFormatting({
   required this.mainText,
    required this.mainTextMatchedSubstrings,
    required this.secondaryText,
  });

  String mainText;
  List<MatchedSubstring> mainTextMatchedSubstrings;
  String secondaryText;

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) => StructuredFormatting(
    mainText: json["main_text"],
    mainTextMatchedSubstrings: List<MatchedSubstring>.from(json["main_text_matched_substrings"].map((x) => MatchedSubstring.fromJson(x))),
    secondaryText: json["secondary_text"],
  );

  Map<String, dynamic> toJson() => {
    "main_text": mainText,
    "main_text_matched_substrings": List<dynamic>.from(mainTextMatchedSubstrings.map((x) => x.toJson())),
    "secondary_text": secondaryText,
  };
}
