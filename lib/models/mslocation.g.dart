// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mslocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mslocation _$MslocationFromJson(Map<String, dynamic> json) {
  return Mslocation()
    ..id = json['id'] as num
    ..altitude = json['altitude'] as num
    ..speed = json['speed'] as num
    ..bearing = json['bearing'] as num
    ..citycode = json['citycode'] as String
    ..adcode = json['adcode'] as String
    ..country = json['country'] as String
    ..province = json['province'] as String
    ..city = json['city'] as String
    ..district = json['district'] as String
    ..road = json['road'] as String
    ..street = json['street'] as String
    ..number = json['number'] as String
    ..poiname = json['poiname'] as String
    ..errorCode = json['errorCode'] as num
    ..errorInfo = json['errorInfo'] as String
    ..locationType = json['locationType'] as num
    ..locationDetail = json['locationDetail'] as String
    ..aoiname = json['aoiname'] as String
    ..address = json['address'] as String
    ..poiid = json['poiid'] as String
    ..floor = json['floor'] as String
    ..description = json['description'] as String
    ..time = json['time'] as num
    ..updatetime = json['updatetime'] as num
    ..provider = json['provider'] as String
    ..lon = json['lon'] as num
    ..lat = json['lat'] as num
    ..accuracy = json['accuracy'] as num
    ..isOffset = json['isOffset'] as bool
    ..isFixLastLocation = json['isFixLastLocation'] as bool
    ..coordType = json['coordType'] as String
    ..isDelete = json['is_delete'] as bool;
}

Map<String, dynamic> _$MslocationToJson(Mslocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'altitude': instance.altitude,
      'speed': instance.speed,
      'bearing': instance.bearing,
      'citycode': instance.citycode,
      'adcode': instance.adcode,
      'country': instance.country,
      'province': instance.province,
      'city': instance.city,
      'district': instance.district,
      'road': instance.road,
      'street': instance.street,
      'number': instance.number,
      'poiname': instance.poiname,
      'errorCode': instance.errorCode,
      'errorInfo': instance.errorInfo,
      'locationType': instance.locationType,
      'locationDetail': instance.locationDetail,
      'aoiname': instance.aoiname,
      'address': instance.address,
      'poiid': instance.poiid,
      'floor': instance.floor,
      'description': instance.description,
      'time': instance.time,
      'updatetime': instance.updatetime,
      'provider': instance.provider,
      'lon': instance.lon,
      'lat': instance.lat,
      'accuracy': instance.accuracy,
      'isOffset': instance.isOffset,
      'isFixLastLocation': instance.isFixLastLocation,
      'coordType': instance.coordType,
      'is_delete': instance.isDelete
    };
