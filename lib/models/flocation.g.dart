// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Flocation _$FlocationFromJson(Map<String, dynamic> json) {
  return Flocation()
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

Map<String, dynamic> _$FlocationToJson(Flocation instance) => <String, dynamic>{
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
