import 'package:json_annotation/json_annotation.dart';

part 'customparams.g.dart';

@JsonSerializable()
class Customparams {
  Customparams();

  String itemId;

  num timeInterval;

  num distanceFilter;

  num storyRadiusMin;

  num storyRadiusMax;

  num storyKeepingTimeMin;

  num poiSearchInterval;

  num pictureRadius;

  num refreshHomePageTime;

  num judgeDistanceNum;

  String aMapTypes;

  String locationWebReqestType;

  factory Customparams.fromJson(Map<String, dynamic> json) => _$CustomparamsFromJson(json);

  Map<String, dynamic> toJson() => _$CustomparamsToJson(this);
}
