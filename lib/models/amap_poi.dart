import 'package:json_annotation/json_annotation.dart';

part 'amap_poi.g.dart';

@JsonSerializable()
class AmapPoi {
  AmapPoi();

  String id;

  String name;

  String type;

  String typecode;

  String address;

  String location;

  String pcode;

  String pname;

  String citycode;

  String cityname;

  String adcode;

  String adname;

  String shopinfo;

  DateTime gridcode;

  String distance;

  @JsonKey(name: "business_area")
  String businessArea;

  String match;

  String recommend;

  DateTime timestamp;

  @JsonKey(name: "indoor_map")
  String indoorMap;

  String country;

  factory AmapPoi.fromJson(Map<String, dynamic> json) => _$AmapPoiFromJson(json);

  Map<String, dynamic> toJson() => _$AmapPoiToJson(this);
}
