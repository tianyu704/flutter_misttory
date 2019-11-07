// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latlonpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Latlonpoint _$LatlonpointFromJson(Map<String, dynamic> json) {
  return Latlonpoint(
    json['latitude'] as num,
    json['longitude'] as num,
  )..radius = json['radius'] as num;
}

Map<String, dynamic> _$LatlonpointToJson(Latlonpoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
    };
