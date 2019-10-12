import 'package:json_annotation/json_annotation.dart';

part 'latlonpoint.g.dart';

@JsonSerializable()
class Latlonpoint {
  Latlonpoint();

  num latitude;

  num longitude;

  factory Latlonpoint.fromJson(Map<String, dynamic> json) => _$LatlonpointFromJson(json);

  Map<String, dynamic> toJson() => _$LatlonpointToJson(this);
}
