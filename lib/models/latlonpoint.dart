import 'package:json_annotation/json_annotation.dart';

part 'latlonpoint.g.dart';

@JsonSerializable()
class Latlonpoint {
  Latlonpoint(this.latitude, this.longitude);

  num latitude;

  num longitude;

  num radius;

  factory Latlonpoint.fromJson(Map<String, dynamic> json) =>
      _$LatlonpointFromJson(json);

  Map<String, dynamic> toJson() => _$LatlonpointToJson(this);
}
