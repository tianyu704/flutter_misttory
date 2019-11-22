// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customparams.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customparams _$CustomparamsFromJson(Map<String, dynamic> json) {
  return Customparams()
    ..itemId = json['itemId'] as String
    ..timeInterval = json['timeInterval'] as num
    ..distanceFilter = json['distanceFilter'] as num
    ..storyRadiusMin = json['storyRadiusMin'] as num
    ..storyRadiusMax = json['storyRadiusMax'] as num
    ..storyKeepingTimeMin = json['storyKeepingTimeMin'] as num
    ..poiSearchInterval = json['poiSearchInterval'] as num
    ..pictureRadius = json['pictureRadius'] as num
    ..refreshHomePageTime = json['refreshHomePageTime'] as num
    ..judgeDistanceNum = json['judgeDistanceNum'] as num
    ..aMapTypes = json['aMapTypes'] as String;
}

Map<String, dynamic> _$CustomparamsToJson(Customparams instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'timeInterval': instance.timeInterval,
      'distanceFilter': instance.distanceFilter,
      'storyRadiusMin': instance.storyRadiusMin,
      'storyRadiusMax': instance.storyRadiusMax,
      'storyKeepingTimeMin': instance.storyKeepingTimeMin,
      'poiSearchInterval': instance.poiSearchInterval,
      'pictureRadius': instance.pictureRadius,
      'refreshHomePageTime': instance.refreshHomePageTime,
      'judgeDistanceNum': instance.judgeDistanceNum,
      'aMapTypes': instance.aMapTypes,
    };
