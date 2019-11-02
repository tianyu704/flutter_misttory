// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Venue _$VenueFromJson(Map<String, dynamic> json) {
  return Venue()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..location = json['location'] == null
        ? null
        : Location.fromJson(json['location'] as Map<String, dynamic>)
    ..referralId = json['referralId'] as String
    ..hasPerk = json['hasPerk'] as bool;
}

Map<String, dynamic> _$VenueToJson(Venue instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'referralId': instance.referralId,
      'hasPerk': instance.hasPerk,
    };
