import 'package:flutter/cupertino.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:intl/intl.dart';
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
  final num judgeDistanceNum = 5000;
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
  Future updateStoryTime(num storyId, num time, num interval) async {
    await Query(DBManager.tableStory).primaryKey([storyId]).update(
        {"update_time": time, "interval_time": interval});
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
      result.reversed.forEach(
          (item) => list.add(Story.fromJson(Map<String, dynamic>.from(item))..date = getShowTime(item["createTime"])));
      if (lastStory == null || lastStory.id == list[0].id) {
        return list;
      } else {
        list.insert(0, lastStory);
        return list;
      }
    }
    if (lastStory != null) {
      list.add(lastStory);
    }
    return list;
  }

  //获取展示的时间 2019.09.23
  String getShowTime(String timeStr) {

    DateTime time = DateTime.fromMicrosecondsSinceEpoch(int.parse(timeStr));
    return DateFormat("yyyy.MM.dd").format(time);//time.year.toString() + "." + time.month.toString() + "." + time.day.toString();
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
    story.updateTime = location.time;
    story.intervalTime = 0;
    story.isDelete = false;
    //TODO:
    return story;
  }

  ///坐标点更新故事或创建故事
  Future<void> judgeLocation(Mslocation location) async {
    if (location != null &&
        location.lon != 0 &&
        location.lat != 0 &&
        (StringUtil.isNotEmpty(location.aoiname) ||
            StringUtil.isNotEmpty(location.poiname)) &&
        StringUtil.isNotEmpty(location.address)) {
      Story story = await queryLastStory();
      bool isNew = false;
      if (story == null) {
        isNew = true;
      } else if (StringUtil.isEmpty(location.aoiname)) {
        if (location.poiname == story.poiName) {
        } else {
          isNew = true;
        }
      } else if (location.aoiname == story.aoiName) {
      } else {
        isNew = true;
      }
      //
      if (isNew) {
        await createStory(createStoryWithLocation(location));
      } else {
        if (await getDistanceBetween(location, story) > judgeDistanceNum) {
          await createStory(createStoryWithLocation(location));
        } else {
          num interval = location.time - story.createTime;
          await updateStoryTime(story.id, location.time, interval);
        }
      }
    }
  }

  ///求值：两个坐标点的距离
  Future<double> getDistanceBetween(Mslocation location, Story story) async {
    LatLng latLng1 = LatLng(location.lat, location.lon);
    LatLng latLng2 = LatLng(story.lat, story.lon);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }

  Future<double> getDistanceBetween1( ) async {
    LatLng latLng1 = LatLng(116.4464662000868, 39.95498128255208);
    LatLng latLng2 = LatLng(116.44648111979167,39.95497856987847);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }


}
