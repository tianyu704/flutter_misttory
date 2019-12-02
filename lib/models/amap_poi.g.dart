// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amap_poi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AmapPoi _$AmapPoiFromJson(Map<String, dynamic> json) {
  return AmapPoi()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..type = json['type'] as String
    ..typecode = json['typecode'] as String
    ..address = json['address'] as String
    ..location = json['location'] as String
    ..pcode = json['pcode'] as String
    ..pname = json['pname'] as String
    ..citycode = json['citycode'] as String
    ..cityname = json['cityname'] as String
    ..adcode = json['adcode'] as String
    ..adname = json['adname'] as String
    ..shopinfo = json['shopinfo'] as String
    ..gridcode = json['gridcode'] == null
        ? null
        : DateTime.parse(json['gridcode'] as String)
    ..distance = json['distance'] as String
    ..businessArea = json['business_area'] as String
    ..match = json['match'] as String
    ..recommend = json['recommend'] as String
    ..timestamp = json['timestamp'] == null
        ? null
        : DateTime.parse(json['timestamp'] as String)
    ..indoorMap = json['indoor_map'] as String
    ..country = json['country'] as String
    ..poiweight = json['poiweight'] as String;
}

Map<String, dynamic> _$AmapPoiToJson(AmapPoi instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'typecode': instance.typecode,
      'address': instance.address,
      'location': instance.location,
      'pcode': instance.pcode,
      'pname': instance.pname,
      'citycode': instance.citycode,
      'cityname': instance.cityname,
      'adcode': instance.adcode,
      'adname': instance.adname,
      'shopinfo': instance.shopinfo,
      'gridcode': instance.gridcode?.toIso8601String(),
      'distance': instance.distance,
      'business_area': instance.businessArea,
      'match': instance.match,
      'recommend': instance.recommend,
      'timestamp': instance.timestamp?.toIso8601String(),
      'indoor_map': instance.indoorMap,
      'country': instance.country,
      'poiweight': instance.poiweight,
    };
