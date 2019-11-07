import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  Location();

  String id;

  num time;

  num lat;

  num lon;

  num altitude;

  num accuracy;

  @JsonKey(name: "vertical_accuracy")
  num verticalAccuracy;

  num speed;

  num bearing;

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
