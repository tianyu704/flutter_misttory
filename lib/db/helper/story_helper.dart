import 'package:flutter/cupertino.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:intl/intl.dart';
import 'package:misstory/db/helper/location_helper.dart';
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
      return await FlutterOrmPlugin.saveOrm(
          DBManager.tableStory, story.toJson());
    }
  }

  /// 更新story时间
  Future updateStoryTime(Mslocation location, Story story,{bool isNoneUserBefore = false}) async {
    if (location != null && story != null) {

      if (location.time < story.createTime) {
        story.createTime = location.time;
      }
      if (location.updatetime > story.updateTime) {
        story.updateTime = location.updatetime;
      }
      num interval = story.updateTime - story.createTime;

      if (StringUtil.isNotEmpty(location.pictures)) {
        story.pictures = location.pictures;
      }
      await Query(DBManager.tableStory).primaryKey([story.id]).update(
          {"update_time": story.updateTime, "interval_time": interval,"pictures":story.pictures,"create_time":story.createTime});
      debugPrint("=================update story time");
    }
  }

  /// 更新story地点
  Future<Map<num, Story>> updateCustomAddress(Story story) async {
    if (story != null) {
//      await Query(DBManager.tableStory).primaryKey([story.id]).update(
//          {"custom_address": story.customAddress});
      List list = await Query(DBManager.tableStory).whereByColumFilters([
        WhereCondiction(
            "default_address", WhereCondictionType.IN, [story.defaultAddress])
      ]).all();
      LatLng latLng1 = LatLng(story.lat, story.lon);

      if (list != null && list.length > 0) {
        Map<num, Story> stories = Map<num, Story>();
        LatLng latLng2;
        for (Map item in list) {
          latLng2 = LatLng(item["lat"], item["lon"]);
          num distance = await CalculateTools().calcDistance(latLng1, latLng2);
          if (distance < LocationConfig.poiSearchInterval) {
            item["custom_address"] = story.customAddress;
            await Query(DBManager.tableStory).primaryKey([item["id"]]).update({
              "custom_address": story.customAddress,
              "lon": story.lon,
              "lat": story.lat
            });
            stories[item["id"]] =
                Story.fromJson(Map<String, dynamic>.from(item));
          }
        }
        return stories;
      }
    }
    return null;
  }

  /// 更新story的经纬度
  Future<bool> updateStoryLonLat(Story story) async {
    if (story != null) {
      await Query(DBManager.tableStory)
          .primaryKey([story.id]).update({"lon": story.lon, "lat": story.lat});
      return true;
    }
    return false;
  }

  /// 更新事件描述
  Future<bool> updateStoryDesc(Story story) async {
    if (story != null) {
      await Query(DBManager.tableStory)
          .primaryKey([story.id]).update({"desc": story.desc});
      return true;
    }
    return false;
  }

  /// 读取库中的全部数据
  Future<List<Story>> findAllStories() async {
    List result = await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction("interval_time", WhereCondictionType.EQ_OR_MORE_THEN,
          LocationConfig.judgeUsefulLocation)
    ]).all();
    List<Story> list = [];

    if (result != null && result.length > 0) {
      result.reversed.forEach((item) {
        Story story = Story.fromJson(Map<String, dynamic>.from(item));
        list.addAll(separateStory(story));
      });
    }
    return list;
  }

  /// 根据给定time查询time-day到time之间的story
  Future<List<Story>> queryMoreHistories({num time}) async {
    if (time == null) {
      time = DateTime.now().millisecondsSinceEpoch;
    }
    List result = await Query(DBManager.tableStory)
        .orderBy(["create_time desc"])
        .whereByColumFilters([
          WhereCondiction("create_time", WhereCondictionType.LESS_THEN, time)
        ])
        .limit(20)
        .all();
    List<Story> list = [];
    if (result != null && result.length > 0) {
      result.forEach((item) {
        Story story = Story.fromJson(Map<String, dynamic>.from(item));
        list.addAll(separateStory(story));
      });
    }
    return list;
  }

  /// 检查当前story位置之后最新的story和Location，并放入story中
  Future<List<Story>> checkLatestStory(List<Story> stories) async {
    if (stories == null) {
      stories = List<Story>();
    }

    /// 检测给的stories集合之后的story并放入集合中
    if (stories != null && stories.length > 0) {
      List result = await Query(DBManager.tableStory)
          .orderBy(["create_time desc"]).whereByColumFilters([
        WhereCondiction(
            "create_time", WhereCondictionType.MORE_THEN, stories[0].createTime)
      ]).all();
      if (result != null && result.length > 0) {
        result.reversed.forEach((item) {
          Story story = Story.fromJson(Map<String, dynamic>.from(item));
          stories.insertAll(0, separateStory(story));
        });
      }
    }
    return stories;
  }

  /// 获取当前位置的story
  Future<Story> getCurrentStory() async {
    Story currentStory;
    Mslocation mslocation = await LocationHelper().queryLastLocation();
    Story lastStory = await queryLastStory();
    if (mslocation != null) {
      if (lastStory == null) {
        currentStory = createStoryWithLocation(mslocation);
      } else {
        if (mslocation.time == lastStory.createTime) {
          currentStory = lastStory;
        } else {
          currentStory = createStoryWithLocation(mslocation);
        }
      }
    }
    if (currentStory != null) {
      currentStory.date = getShowTime(currentStory.createTime);
      currentStory.updateTime = DateTime.now().millisecondsSinceEpoch;
      currentStory.intervalTime =
          currentStory.updateTime - currentStory.createTime;
    }
    return currentStory;
  }

  /// 判断story是否在同一天，不在同一天就分割成多天
  List<Story> separateStory(Story story) {
    List<Story> list = [];
    DateTime dateTime1 =
        DateTime.fromMillisecondsSinceEpoch(story.createTime.toInt());
    DateTime dateTime2 =
        DateTime.fromMillisecondsSinceEpoch(story.updateTime.toInt());
    DateTime day1 = DateTime(dateTime1.year, dateTime1.month, dateTime1.day);
    DateTime day2 = DateTime(dateTime2.year, dateTime2.month, dateTime2.day);
    if (day1.isAtSameMomentAs(day2)) {
      story.date = getShowTime(story.createTime);
      list.add(story);
      return list;
    } else {
      Map<String, dynamic> map = story.toJson();
      Story story1;
      int intervalDay = day2.difference(day1).inDays;
      DateTime day;
      for (num i = 0; i <= intervalDay; i++) {
        story1 = Story.fromJson(map);
        day = DateTime.fromMillisecondsSinceEpoch(day1.millisecondsSinceEpoch);
        if (i == 0) {
          story1.updateTime = day.add(Duration(days: 1)).millisecondsSinceEpoch;
        } else if (i == intervalDay) {
          story1.createTime = day2.millisecondsSinceEpoch;
        } else {
          story1.createTime = day.add(Duration(days: i)).millisecondsSinceEpoch;
          story1.updateTime =
              day.add(Duration(days: i + 1)).millisecondsSinceEpoch;
        }
        story1.date = getShowTime(story1.createTime);
        story1.intervalTime = story1.updateTime - story1.createTime;
        list.add(story1);
      }
      return list.reversed.toList();
    }
  }

  ///获取展示的时间 2019.09.23
  String getShowTime(num timeStr) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStr.toInt());
    String newTime = DateFormat("yyyy.MM.dd").format(time);
    return newTime;
  }

  /// 查询最后一条story
  Future<Story> queryLastStory() async {
    Map result = await Query(DBManager.tableStory).orderBy([
      "create_time desc",
    ]).first();
    if (result != null && result.length > 0) {
      return Story.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  /// 查询记录的天数
  Future<int> getStoryDays() async {
    Map story1 =
        await Query(DBManager.tableStory).orderBy(["create_time desc"]).first();
    Map story2 =
        await Query(DBManager.tableStory).orderBy(["create_time asc"]).first();
    if (story1 != null && story2 != null) {
      num time1 = story1["create_time"] as num;
      num time2 = story2["update_time"] as num;
      DateTime dateTime1 = DateTime.fromMillisecondsSinceEpoch(time1.toInt());
      DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(time2.toInt());
      return DateTime(dateTime1.year, dateTime1.month, dateTime1.day)
              .difference(
                  DateTime(dateTime2.year, dateTime2.month, dateTime2.day))
              .inDays +
          1;
    }
    return 1;
  }

  /// 查询足迹，相同的story算一个点
  Future<int> getFootprint(List<Story> list) async {
    List list1 = await Query(DBManager.tableStory).needColums(
        ["default_address"]).groupBy(["default_address"]).whereByColumFilters([
      WhereCondiction("custom_address", WhereCondictionType.IS_NULL, true)
    ]).all();
    List list2 = await Query(DBManager.tableStory).needColums(
        ["custom_address"]).groupBy(["custom_address"]).whereByColumFilters([
      WhereCondiction("custom_address", WhereCondictionType.IS_NULL, false)
    ]).all();
    int current = 0;

    /// 判断当前还未生成的story的点是否是新的足迹
    if (list != null && list.length > 0 && list[0].id == null) {
      List result = await Query(DBManager.tableStory).whereByColumFilters([
        WhereCondiction(
            "custom_address", WhereCondictionType.IN, [list[0].defaultAddress])
      ]).all();
      if (result == null || result?.length == 0) {
        current = 1;
      }
    }
    return (list1?.length ?? 0) + (list2?.length ?? 0) + current;
  }

  /// 根据Location创建story
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
    story.updateTime = location.updatetime ?? location.time;
    story.intervalTime = location.updatetime - location.time;
    story.isDelete = false;
    story.defaultAddress = getDefaultAddress(story);
    story.pictures = location.pictures;
    //TODO:需要看相同的该地点是否有custom_address,有的话需要赋值
    return story;
  }

  /// 获取默认address
  String getDefaultAddress(Story story) {
    return StringUtil.isEmpty(story.aoiName)
        ? (StringUtil.isEmpty(story.poiName) ? story.address : story.poiName)
        : story.aoiName;
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
                debugPrint("======>create1");
                await createStory(createStoryWithLocation(location));
              } else {
                await updateStoryTime(location, story);
              }
            }
          } else {
            if (await getDistanceBetween(location, story) >
                LocationConfig.judgeDistanceNum) {
              debugPrint("======>create2");
              await createStory(createStoryWithLocation(location));
            } else {
              await updateStoryTime(location, story);
            }
          }
        } else {
          debugPrint("======>create3");
          await createStory(createStoryWithLocation(location));
        }
      } else {
        debugPrint("======>create4");
        await createStory(createStoryWithLocation(location));
      }
    }
  }
  ///坐标点转化成story(即创建或更新) isNoneUseBefore 是否是第一次使用之前app的图产生的定位
  Future<void>convertStoryWithEverLocation(Mslocation lastLocation,Mslocation location,{bool isNoneUseBefore}) async {
    Story story = await findTargetStoryWithLocation(lastLocation);
    if (story == null) {
      await createStory(createStoryWithLocation(location));
      print("story 创建 ${location.aoiname}");
    } else {
      location.pictures =
      await updateStoryTime(location, story,isNoneUserBefore: isNoneUseBefore);
      print("story 更新 ${story.aoiName}   ${story.id}");

    }
  }

  Future<bool> judgeSamePlace(Story story1, Story story2) async {
    if (story1 != null && story2 != null) {
      if (story1.aoiName == story2.aoiName) {
        if (story1.poiName == story2.poiName) {
          if (story1.address == story2.address) {
            return true;
          } else {
            if (await getDistanceBetweenStory(story1, story2) >
                LocationConfig.judgeDistanceNum) {
              return false;
            } else {
              return true;
            }
          }
        } else {
          if (await getDistanceBetweenStory(story1, story2) >
              LocationConfig.judgeDistanceNum) {
            return false;
          } else {
            return true;
          }
        }
      } else {
        return false;
      }
    }
    return false;
  }


  ///根据坐标点查找对应story
  Future<Story>findTargetStoryWithLocation(Mslocation location) async {
    if (location == null) {
      return null;
    }
    num updateTime = location.updatetime;
    Map result;
    result = await Query(DBManager.tableStory)
        .whereByColumFilters([
      WhereCondiction("create_time", WhereCondictionType.EQ_OR_LESS_THEN, location.time),
      WhereCondiction("update_time", WhereCondictionType.EQ_OR_MORE_THEN, updateTime),
    ]).first();

    if (result != null) {
       return Story.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  Future<void> deleteMisstory() async {
//    Story story = await queryLastStory();
//    await Query(DBManager.tableStory).primaryKey([story.id]).delete();
//    await Query(DBManager.tableStory).delete();
  }

  ///求值：两个坐标点的距离
  Future<double> getDistanceBetween(Mslocation location, Story story) async {
    LatLng latLng1 = LatLng(location.lat, location.lon);
    LatLng latLng2 = LatLng(story.lat, story.lon);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }

  ///求值：两个坐标点的距离
  Future<double> getDistanceBetweenStory(Story location, Story story) async {
    LatLng latLng1 = LatLng(location.lat, location.lon);
    LatLng latLng2 = LatLng(story.lat, story.lon);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }

  Future<double> getDistanceBetween1() async {
    LatLng latLng1 = LatLng(116.492896, 39.899667);
    LatLng latLng2 = LatLng(116.4929, 39.900061);
    return await CalculateTools().calcDistance(latLng1, latLng2);
//    return await CalculateUtil.calculateLineDistance(latLng1, latLng2);
  }

  /// 给库中数据默认上default_address
  Future updateAllDefaultAddress() async {
    List list = await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction("default_address", WhereCondictionType.IS_NULL, true)
    ]).all();
    if (list != null && list.length > 0) {
      Map<String, dynamic> map;
      num id;
      String aoiname, poiname, address;
      String defaultAddress;
      for (int i = 0; i < list.length; i++) {
        map = Map<String, dynamic>.from(list[i]);
        id = map["id"] as num;
        aoiname = map["aoi_name"] as String;
        poiname = map["poi_name"] as String;
        address = map["address"] as String;
        defaultAddress = StringUtil.isEmpty(aoiname)
            ? (StringUtil.isEmpty(poiname) ? address : poiname)
            : aoiname;
        await Query(DBManager.tableStory)
            .primaryKey([id]).update({"default_address": defaultAddress});
      }
    }
  }

  /// 删除无用的story
  Future deleteUnUsefulStory() async {
    await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction("interval_time", WhereCondictionType.LESS_THEN,
          LocationConfig.judgeUsefulLocation)
    ]).delete();
  }
}
