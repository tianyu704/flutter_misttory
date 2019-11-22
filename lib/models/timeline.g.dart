// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timeline _$TimelineFromJson(Map<String, dynamic> json) {
  return Timeline()
    ..uuid = json['uuid'] as String
    ..poiId = json['poi_id'] as String
    ..poiName = json['poi_name'] as String
    ..poiType = json['poi_type'] as String
    ..poiTypeCode = json['poi_type_code'] as String
    ..poiLocation = json['poi_location'] as String
    ..poiAddress = json['poi_address'] as String
    ..distance = json['distance'] as String
    ..country = json['country'] as String
    ..province = json['province'] as String
    ..city = json['city'] as String
    ..district = json['district'] as String
    ..customAddress = json['custom_address'] as String
    ..desc = json['desc'] as String
    ..lat = json['lat'] as num
    ..lon = json['lon'] as num
    ..altitude = json['altitude'] as num
    ..radius = json['radius'] as num
    ..radiusSd = json['radius_sd'] as num
    ..startTime = json['start_time'] as num
    ..endTime = json['end_time'] as num
    ..intervalTime = json['interval_time'] as num
    ..isDelete = json['is_delete'] as num
    ..isFromPicture = json['is_from_picture'] as num
    ..needUpdatePoi = json['need_update_poi'] as num
    ..sameId = json['same_id'] as String
    ..isConfirm = json['is_confirm'] as num
    ..date = json['date'] as String
    ..pictures = (json['pictures'] as List)
        ?.map((e) =>
            e == null ? null : Picture.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$TimelineToJson(Timeline instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'poi_id': instance.poiId,
      'poi_name': instance.poiName,
      'poi_type': instance.poiType,
      'poi_type_code': instance.poiTypeCode,
      'poi_location': instance.poiLocation,
      'poi_address': instance.poiAddress,
      'distance': instance.distance,
      'country': instance.country,
      'province': instance.province,
      'city': instance.city,
      'district': instance.district,
      'custom_address': instance.customAddress,
      'desc': instance.desc,
      'lat': instance.lat,
      'lon': instance.lon,
      'altitude': instance.altitude,
      'radius': instance.radius,
      'radius_sd': instance.radiusSd,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'interval_time': instance.intervalTime,
      'is_delete': instance.isDelete,
      'is_from_picture': instance.isFromPicture,
      'need_update_poi': instance.needUpdatePoi,
      'same_id': instance.sameId,
      'is_confirm': instance.isConfirm,
      'date': instance.date,
      'pictures': instance.pictures,
    };
