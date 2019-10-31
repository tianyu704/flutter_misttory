// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location()
    ..address = json['address'] as String
    ..lat = json['lat'] as num
    ..lng = json['lng'] as num
    ..distance = json['distance'] as num
    ..postalCode = json['postalCode'] as String
    ..cc = json['cc'] as String
    ..city = json['city'] as String
    ..state = json['state'] as String
    ..country = json['country'] as String;
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'distance': instance.distance,
      'postalCode': instance.postalCode,
      'cc': instance.cc,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
    };
