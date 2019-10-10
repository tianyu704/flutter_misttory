import 'package:flutter/cupertino.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:intl/intl.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/string_util.dart';
import '../db_manager.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:amap_base/amap_base.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-29
///
class StoryHelper {
  final String tableName = "Story";
  final String columnId = "id";
  final String columnTime = "time";
  static final StoryHelper _instance = new StoryHelper._internal();

  factory StoryHelper() => _instance;

  StoryHelper._internal();

  /// 创建story
  Future createStory(Story story) async {
    if (story != null) {
      await FlutterOrmPlugin.saveOrm(DBManager.tableStory, story.toJson());
    }
  }

  /// 更新story时间
  Future updateStoryTime(Mslocation location, Story story) async {
    if (location != null && story != null) {
      num interval = location.updatetime - story.createTime;
      await Query(DBManager.tableStory).primaryKey([story.id]).update(
          {"update_time": location.updatetime, "interval_time": interval});
    }
  }

  /// 读取库中的全部数据
  Future<List> findAllStories() async {
    List result = await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction(
          "interval_time", WhereCondictionType.EQ_OR_MORE_THEN, 60000)
    ]).all();
    List<Story> list = [];
    Story lastStory = await queryLastStory();
    if (result != null && result.length > 0) {
      result.reversed.forEach((item) {
        Story story = Story.fromJson(Map<String, dynamic>.from(item));
        String time = getShowTime(story.createTime);
        story.date = time;
        list.add(story);
      });
      if (lastStory == null || lastStory.id == list[0].id) {
        return list;
      } else {
        lastStory.date = getShowTime(lastStory.createTime);
        list.insert(0, lastStory);
        return list;
      }
    }
    if (lastStory != null) {
      list.add(lastStory);
    }
    return list;
  }

  ///获取展示的时间 2019.09.23
  String getShowTime(num timeStr) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStr.toInt());
    String newTime = DateFormat("yyyy.MM.dd").format(time);
    return newTime;
  }

  /// 查询最后一条story
  Future<Story> queryLastStory() async {
    List result = await Query(DBManager.tableStory).orderBy([
      "id desc",
    ]).all();
    if (result != null && result.length > 0) {
      return Story.fromJson(Map<String, dynamic>.from(result[0]));
    }
    return null;
  }

  Story createStoryWithLocation(Mslocation location) {
    Story story = Story();
    story.lat = location.lat;
    story.lon = location.lon;
    story.altitude = location.altitude;
    story.poiId = location.poiid;
    story.aoiName = location.aoiname;
    story.poiName = location.poiname;
    story.country = location.country;
    story.province = location.province;
    story.city = location.city;
    story.cityCode = location.citycode;
    story.adCode = location.adcode;
    story.district = location.district;
    story.address = location.address;
    story.road = location.road;
    story.street = location.street;
    story.number = location.number;
    story.description = location.description;
    story.createTime = location.time;
    story.updateTime = location.updatetime;
    story.intervalTime = location.updatetime - location.time;
    story.isDelete = false;
    //TODO:
    return story;
  }

  ///坐标点更新故事或创建故事
  Future<void> judgeLocation(Mslocation location) async {
    if (location != null &&
        location.errorCode == 0 &&
        StringUtil.isNotEmpty(location.address)) {
      Story story = await queryLastStory();
      if (story != null) {
        if (location.aoiname == story.aoiName) {
          if (location.poiname == story.poiName) {
            if (location.address == story.address) {
              await updateStoryTime(location, story);
            } else {
              if (await getDistanceBetween(location, story) >
                  LocationConfig.judgeDistanceNum) {
                await createStory(createStoryWithLocation(location));
              } else {
                await updateStoryTime(location, story);
              }
            }
          } else {
            if (await getDistanceBetween(location, story) >
                LocationConfig.judgeDistanceNum) {
              await createStory(createStoryWithLocation(location));
            } else {
              await updateStoryTime(location, story);
            }
          }
        } else {
          await createStory(createStoryWithLocation(location));
        }
      } else {
        await createStory(createStoryWithLocation(location));
      }
    }
  }

  Future<void> deleteMisstory() async {
    await Query(DBManager.tableStory).delete();
  }

  ///求值：两个坐标点的距离
  Future<double> getDistanceBetween(Mslocation location, Story story) async {
    LatLng latLng1 = LatLng(location.lat, location.lon);
    LatLng latLng2 = LatLng(story.lat, story.lon);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }

  Future<double> getDistanceBetween1() async {
    LatLng latLng1 = LatLng(116.4464662000868, 39.95498128255208);
    LatLng latLng2 = LatLng(116.44648111979167, 39.95497856987847);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }
}
