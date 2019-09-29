// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Story _$StoryFromJson(Map<String, dynamic> json) {
  return Story()
    ..id = json['id'] as num
    ..lon = json['lon'] as num
    ..lat = json['lat'] as num
    ..altitude = json['altitude'] as num
    ..cityCode = json['city_code'] as String
    ..adCode = json['ad_code'] as String
    ..country = json['country'] as String
    ..province = json['province'] as String
    ..city = json['city'] as String
    ..district = json['district'] as String
    ..road = json['road'] as String
    ..street = json['street'] as String
    ..number = json['number'] as String
    ..poiId = json['poi_id'] as String
    ..poiName = json['poi_name'] as String
    ..aoiName = json['aoi_name'] as String
    ..address = json['address'] as String
    ..description = json['description'] as String
    ..createTime = json['create_time'] as String
    ..updateTime = json['update_time'] as String
    ..customAddress = json['custom_address'] as String
    ..tags = json['tags'] as String
    ..persons = json['persons'] as String;
}

Map<String, dynamic> _$StoryToJson(Story instance) => <String, dynamic>{
      'id': instance.id,
      'lon': instance.lon,
      'lat': instance.lat,
      'altitude': instance.altitude,
      'city_code': instance.cityCode,
      'ad_code': instance.adCode,
      'country': instance.country,
      'province': instance.province,
      'city': instance.city,
      'district': instance.district,
      'road': instance.road,
      'street': instance.street,
      'number': instance.number,
      'poi_id': instance.poiId,
      'poi_name': instance.poiName,
      'aoi_name': instance.aoiName,
      'address': instance.address,
      'description': instance.description,
      'create_time': instance.createTime,
      'update_time': instance.updateTime,
      'custom_address': instance.customAddress,
      'tags': instance.tags,
      'persons': instance.persons
    };
