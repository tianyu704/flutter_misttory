import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  Location();

  String address;

  num lat;

  num lng;

  num distance;

  String postalCode;

  String cc;

  String city;

  String state;

  String country;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
