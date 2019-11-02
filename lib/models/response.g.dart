// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Response _$ResponseFromJson(Map<String, dynamic> json) {
  return Response()
    ..venues = (json['venues'] as List)
        ?.map(
            (e) => e == null ? null : Venue.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..confident = json['confident'] as bool;
}

Map<String, dynamic> _$ResponseToJson(Response instance) => <String, dynamic>{
      'venues': instance.venues,
      'confident': instance.confident,
    };
