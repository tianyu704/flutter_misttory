// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location()
    ..id = json['id'] as String
    ..time = json['time'] as num
    ..lat = json['lat'] as num
    ..lon = json['lon'] as num
    ..altitude = json['altitude'] as num
    ..accuracy = json['accuracy'] as num
    ..verticalAccuracy = json['vertical_accuracy'] as num
    ..speed = json['speed'] as num
    ..bearing = json['bearing'] as num
    ..count = json["count"] as num;
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'id': instance.id,
      'time': instance.time,
      'lat': instance.lat,
      'lon': instance.lon,
      'altitude': instance.altitude,
      'accuracy': instance.accuracy,
      'vertical_accuracy': instance.verticalAccuracy,
      'speed': instance.speed,
      'bearing': instance.bearing,
      'count': instance.count,
    };
