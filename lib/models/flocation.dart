import 'package:json_annotation/json_annotation.dart';

part 'flocation.g.dart';

@JsonSerializable()
class Flocation {
  Flocation();

  String address;

  num lat;

  num lng;

  num distance;

  String postalCode;

  String cc;

  String city;

  String state;

  String country;

  factory Flocation.fromJson(Map<String, dynamic> json) => _$FlocationFromJson(json);

  Map<String, dynamic> toJson() => _$FlocationToJson(this);
}
