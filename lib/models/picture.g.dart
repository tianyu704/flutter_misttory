// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Picture _$PictureFromJson(Map<String, dynamic> json) {
  return Picture()
    ..id = json['id'] as String
    ..creationDate = json['creationDate'] as num
    ..pixelWidth = json['pixelWidth'] as num
    ..pixelHeight = json['pixelHeight'] as num
    ..lat = json['lat'] as num
    ..lon = json['lon'] as num
    ..isSynced = json['isSynced'] as bool;
}

Map<String, dynamic> _$PictureToJson(Picture instance) => <String, dynamic>{
      'id': instance.id,
      'creationDate': instance.creationDate,
      'pixelWidth': instance.pixelWidth,
      'pixelHeight': instance.pixelHeight,
      'lat': instance.lat,
      'lon': instance.lon,
      'isSynced': instance.isSynced,
    };
