import 'package:json_annotation/json_annotation.dart';
import "picture.dart";
part 'mslocation.g.dart';

@JsonSerializable()
class Mslocation {
  Mslocation();

  num id;

  num altitude;

  num speed;

  num bearing;

  String citycode;

  String adcode;

  String country;

  String province;

  String city;

  String district;

  String road;

  String street;

  String number;

  String poiname;

  num errorCode;

  String errorInfo;

  num locationType;

  String locationDetail;

  String aoiname;

  String address;

  String poiid;

  String floor;

  String description;

  num time;

  num updatetime;

  String provider;

  num lon;

  num lat;

  num accuracy;

  bool isOffset;

  bool isFixLastLocation;

  String coordType;

  @JsonKey(name: "is_delete")
  bool isDelete;

  List<Picture> pictures;

  factory Mslocation.fromJson(Map<String, dynamic> json) => _$MslocationFromJson(json);

  Map<String, dynamic> toJson() => _$MslocationToJson(this);
}
