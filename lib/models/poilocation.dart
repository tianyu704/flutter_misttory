import 'package:json_annotation/json_annotation.dart';
import "latlonpoint.dart";
part 'poilocation.g.dart';

@JsonSerializable()
class Poilocation {
  Poilocation();

  String id;

  @JsonKey(name: "story_uuid")
  String storyUuid;

  String adName;

  String businessArea;

  String cityCode;

  String cityName;

  String provinceCode;

  String provinceName;

  num distance;

  String poiId;

  String snippet;

  String title;

  String typeCode;

  String typeDes;

  Latlonpoint latLonPoint;

  num lat;

  num lon;

  factory Poilocation.fromJson(Map<String, dynamic> json) => _$PoilocationFromJson(json);

  Map<String, dynamic> toJson() => _$PoilocationToJson(this);
}
