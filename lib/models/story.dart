import 'package:json_annotation/json_annotation.dart';
import "tag.dart";
import "person.dart";
import "picture.dart";
part 'story.g.dart';

@JsonSerializable()
class Story {
  Story();

  num id;

  num lon;

  num lat;

  num altitude;

  @JsonKey(name: "city_code")
  String cityCode;

  @JsonKey(name: "ad_code")
  String adCode;

  String country;

  String province;

  String city;

  String district;

  String road;

  String street;

  String number;

  @JsonKey(name: "poi_id")
  String poiId;

  @JsonKey(name: "poi_name")
  String poiName;

  @JsonKey(name: "aoi_name")
  String aoiName;

  String address;

  String description;

  @JsonKey(name: "create_time")
  num createTime;

  @JsonKey(name: "update_time")
  num updateTime;

  @JsonKey(name: "interval_time")
  num intervalTime;

  @JsonKey(name: "custom_address")
  String customAddress;

  @JsonKey(name: "default_address")
  String defaultAddress;

  String desc;

  List<Tag> tags;

  List<Person> persons;

  String date;

  String pictures;

  num isFromPicture;

  @JsonKey(name: "coord_type")
  String coordType;

  List<Picture> localImages;

  @JsonKey(name: "is_deleted")
  num isDeleted;

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}
