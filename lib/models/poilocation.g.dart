// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poilocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Poilocation _$PoilocationFromJson(Map<String, dynamic> json) {
  return Poilocation()
    ..id = json['id'] as num
    ..storyId = json['storyId'] as num
    ..distance = json['distance'] as num
    ..poiId = json['poiId'] as String
    ..snippet = json['snippet'] as String
    ..title = json['title'] as String
    ..typeCode = json['typeCode'] as String
    ..typeDes = json['typeDes'] as String
    ..latLonPoint = json['latLonPoint'] == null
        ? null
        : Latlonpoint.fromJson(json['latLonPoint'] as Map<String, dynamic>);
}

Map<String, dynamic> _$PoilocationToJson(Poilocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storyId': instance.storyId,
      'distance': instance.distance,
      'poiId': instance.poiId,
      'snippet': instance.snippet,
      'title': instance.title,
      'typeCode': instance.typeCode,
      'typeDes': instance.typeDes,
      'latLonPoint': instance.latLonPoint,
    };
