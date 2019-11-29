import 'package:json_annotation/json_annotation.dart';

part 'latlonpoint.g.dart';

@JsonSerializable()
class Latlonpoint {
  Latlonpoint(this.lat, this.lon);

  num lat;

  num lon;

  num radius;

  factory Latlonpoint.fromJson(Map<String, dynamic> json) =>
      _$LatlonpointFromJson(json);

  Map<String, dynamic> toJson() => _$LatlonpointToJson(this);
}
