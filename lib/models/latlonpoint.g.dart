// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latlonpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Latlonpoint _$LatlonpointFromJson(Map<String, dynamic> json) {
  return Latlonpoint()
    ..latitude = json['latitude'] as num
    ..longitude = json['longitude'] as num;
}

Map<String, dynamic> _$LatlonpointToJson(Latlonpoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
