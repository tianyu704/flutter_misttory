// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foursquare.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Foursquare _$FoursquareFromJson(Map<String, dynamic> json) {
  return Foursquare()
    ..meta = json['meta'] == null
        ? null
        : Meta.fromJson(json['meta'] as Map<String, dynamic>)
    ..response = json['response'] == null
        ? null
        : Response.fromJson(json['response'] as Map<String, dynamic>);
}

Map<String, dynamic> _$FoursquareToJson(Foursquare instance) =>
    <String, dynamic>{
      'meta': instance.meta,
      'response': instance.response,
    };
