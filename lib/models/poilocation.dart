import 'package:json_annotation/json_annotation.dart';
import "latlonpoint.dart";
part 'poilocation.g.dart';

@JsonSerializable()
class Poilocation {
  Poilocation();

  num id;

  num storyId;

  num distance;

  String poiId;

  String snippet;

  String title;

  String typeCode;

  String typeDes;

  Latlonpoint latLonPoint;

  factory Poilocation.fromJson(Map<String, dynamic> json) => _$PoilocationFromJson(json);

  Map<String, dynamic> toJson() => _$PoilocationToJson(this);
}
