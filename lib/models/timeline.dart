import 'package:json_annotation/json_annotation.dart';
import 'package:misstory/models/picture.dart';

part 'timeline.g.dart';

@JsonSerializable()
class Timeline {
  Timeline();

  String uuid;

  @JsonKey(name: "poi_id")
  String poiId;

  @JsonKey(name: "poi_name")
  String poiName;

  @JsonKey(name: "poi_type")
  String poiType;

  @JsonKey(name: "poi_type_code")
  String poiTypeCode;

  @JsonKey(name: "poi_location")
  String poiLocation;

  @JsonKey(name: "poi_address")
  String poiAddress;

  String distance;

  String country;

  String province;

  String city;

  String district;

  @JsonKey(name: "custom_address")
  String customAddress;

  String desc;

  num lat;

  num lon;

  num altitude;

  num radius;

  @JsonKey(name: "radius_sd")
  num radiusSd;

  @JsonKey(name: "start_time")
  num startTime;

  @JsonKey(name: "end_time")
  num endTime;

  @JsonKey(name: "interval_time")
  num intervalTime;

  @JsonKey(name: "is_delete")
  num isDelete;

  @JsonKey(name: "is_from_picture")
  num isFromPicture;

  @JsonKey(name: "need_update_poi")
  num needUpdatePoi;

  @JsonKey(name: "same_id")
  String sameId;

  ///以下为附加字段不存入数据库,显示时使用
  String date;

  List<Picture> pictures;

  factory Timeline.fromJson(Map<String, dynamic> json) => _$TimelineFromJson(json);

  Map<String, dynamic> toJson() => _$TimelineToJson(this);
}
