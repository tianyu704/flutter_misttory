import 'package:flutter/material.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:amap_base_map/src/map/calculate_tool.dart';
import 'package:amap_base_map/amap_base_map.dart';
///
/// Create by Hugo.Guo
/// Date: 2019-09-29
///
class StoryHelper{
  final String tableName = "Story";
  final String columnId = "id";
  final String columnTime = "time";

  static final StoryHelper _instance = new StoryHelper._internal();

  factory StoryHelper() => _instance;

  StoryHelper._internal();

  /// 创建Story 一条记录
  Future createStoryWithLocation(Mslocation location) async {
    Story story = Story();
    story.lat = location.lat;
    story.lon = location.lon;
    story.poiId = location.poiid;
    story.aoiName = location.aoiname;
    story.poiName = location.poiname;
    story.country = location.country;
    story.province = location.province;
    story.city = location.city;
    story.cityCode = location.citycode;
    story.adCode = location.adcode;
    story.address = location.address;
    story.road = location.road;
    story.street = location.street;
    story.number = location.number;
    story.description = location.description;

    story.createTime = location.time;
    story.updateTime =location.time;
    //TODO:
    return story;
  }

  Future updateStory(Story story) async {
    //TODO:
  }

}

///参数
Story storyStamp;                  ///每次用来比较的当前故事
final num judgeDistanceNum = 5000; ///5000m 计算距离比较的阈值

Future<void> judgeLocation(Mslocation location) async {
  Story story = storyStamp;
  bool isNew = false;
  if (story == null) {
    isNew = true;
  } else if (location.aoiname == null) {
       if (location.poiname == story.poiName) {
       } else {
          isNew = true;
       }
  } else if (location.aoiname == story.aoiName){
  } else {
       isNew = true;
  }
  //
  if (isNew) {
    storyStamp = await StoryHelper().createStoryWithLocation(location);
  } else {
     if (await getDistanceBetween(location, story) > judgeDistanceNum) {
      storyStamp = await StoryHelper().createStoryWithLocation(location);
     } else {
       story.updateTime = location.time;
       storyStamp = story;
       await StoryHelper().updateStory(story);
     }
  }
}

///求值：两个坐标点的距离
Future<double> getDistanceBetween(Mslocation location,Story story) async {
  LatLng latLng1 = LatLng(location.lat,location.lon);
  LatLng latLng2 = LatLng(story.lat,story.lon);
  return await CalculateTools().calcDistance(latLng1, latLng2);
}
