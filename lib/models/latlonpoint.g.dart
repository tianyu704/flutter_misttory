// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latlonpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Latlonpoint _$LatlonpointFromJson(Map<String, dynamic> json) {
  return Latlonpoint(
    json['lat'] as num,
    json['lon'] as num,
  )..radius = json['radius'] as num;
}

Map<String, dynamic> _$LatlonpointToJson(Latlonpoint instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'radius': instance.radius,
    };
