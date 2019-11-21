// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poilocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Poilocation _$PoilocationFromJson(Map<String, dynamic> json) {
  return Poilocation()
    ..id = json['id'] as num
    ..storyUuid = json['story_uuid'] as String
    ..adName = json['adName'] as String
    ..businessArea = json['businessArea'] as String
    ..cityCode = json['cityCode'] as String
    ..cityName = json['cityName'] as String
    ..provinceCode = json['provinceCode'] as String
    ..provinceName = json['provinceName'] as String
    ..distance = json['distance'] as num
    ..poiId = json['poiId'] as String
    ..snippet = json['snippet'] as String
    ..title = json['title'] as String
    ..typeCode = json['typeCode'] as String
    ..typeDes = json['typeDes'] as String
    ..latLonPoint = json['latLonPoint'] == null
        ? null
        : Latlonpoint.fromJson(json['latLonPoint'] as Map<String, dynamic>)
    ..lat = json['lat'] as num
    ..lon = json['lon'] as num;
}

Map<String, dynamic> _$PoilocationToJson(Poilocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'story_uuid': instance.storyUuid,
      'adName': instance.adName,
      'businessArea': instance.businessArea,
      'cityCode': instance.cityCode,
      'cityName': instance.cityName,
      'provinceCode': instance.provinceCode,
      'provinceName': instance.provinceName,
      'distance': instance.distance,
      'poiId': instance.poiId,
      'snippet': instance.snippet,
      'title': instance.title,
      'typeCode': instance.typeCode,
      'typeDes': instance.typeDes,
      'latLonPoint': instance.latLonPoint,
      'lat': instance.lat,
      'lon': instance.lon,
    };
