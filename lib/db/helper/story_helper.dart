import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:intl/intl.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/coord_type.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/calculate_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:uuid/uuid.dart';
import '../db_manager.dart';
import 'package:misstory/models/mslocation.dart';

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
      print("======创建story！");
      return 0;
    }
    return -1;
  }

//  /// 更新story时间
//  Future updateStoryTime(Mslocation location, Story story) async {
//    if (location != null && story != null) {
//      if (location.time < story.createTime) {
//        story.createTime = location.time;
//      }
//      if (location.updatetime > story.updateTime) {
//        story.updateTime = location.updatetime;
//      }
//      num interval = story.updateTime - story.createTime;
//      await Query(DBManager.tableStory).primaryKey([story.id]).update({
//        "update_time": story.updateTime,
//        "interval_time": interval,
//        "create_time": story.createTime
//      });
//      debugPrint("=================update story time");
//    }
//  }

  Future<int> updateStoryTimes(Story story) async {
    if (story != null) {
      story = await calculateRadius(story);
//      story = await calculateStoryLatLon(story);
      await Query(DBManager.tableStory).primaryKey([story.id]).update({
        "update_time": story.updateTime,
        "interval_time": story.updateTime - story.createTime,
        "create_time": story.createTime,
        "lat": story.lat,
        "lon": story.lon,
        "radius": story.radius,
      });
      debugPrint("=================update story");
      return 0;
    }
    return -1;
  }

  Future<Story> calculateStoryLatLon(Story story) async {
    if (story != null && story.isFromPicture != 1) {
      List list = await LocationHelper()
          .queryPoints(story.createTime, story.updateTime);
      if (list != null) {
        Latlonpoint point = await CalculateUtil.calculateCenterLatLon(list);
        if (point != null) {
          if (StringUtil.isEmpty(story.customAddress)) {
            story.lat = point.lat;
            story.lon = point.lon;
          }
          story.radius = point.radius;
        }
      }
    }
    return story;
  }

//  Future updateStory(Mslocation location, Story story) async {
//    if (location != null && story != null) {
//      if (location.time < story.createTime) {
//        story.createTime = location.time;
//      }
//      if (location.updatetime > story.updateTime) {
//        story.updateTime = location.updatetime;
//      }
//      num interval = story.updateTime - story.createTime;
//
//      story.pictures = mergePictures(story.pictures, location.pictures);
//      await Query(DBManager.tableStory).primaryKey([story.id]).update({
//        "update_time": story.updateTime,
//        "interval_time": interval,
//        "pictures": story.pictures,
//        "create_time": story.createTime
//      });
//      debugPrint("=================update story time");
//    }
//  }

  /// 更新story地点 customAddress writeAddress
  Future updateCustomWriteAddress(Story story,
      {bool updateCustom = false}) async {
    if (story != null) {
//      await Query(DBManager.tableStory).primaryKey([story.id]).update(
//          {"custom_address": story.customAddress});
      if (updateCustom) {
        List result = await Query(DBManager.tableStory).whereByColumFilters([
          WhereCondiction(
              "custom_address", WhereCondictionType.IN, [story.customAddress]),
          WhereCondiction("write_address", WhereCondictionType.IS_NULL, false),
        ]).all();
        if (result != null && result.length > 0) {
          for (Map item in result) {
            num distance = CalculateUtil.calculateLatlngDistance(
                story.lat, story.lon, item["lat"], item["lon"]);
            if (distance < LocationConfig.poiSearchInterval) {
              story.writeAddress = item["write_address"] as String;
              break;
            }
          }
        }
      }

      List list = await Query(DBManager.tableStory).whereByColumFilters([
        WhereCondiction(
            "default_address", WhereCondictionType.IN, [story.defaultAddress]),
      ]).all();

      if (list != null && list.length > 0) {
//        story = await calculateRadius(story);
        for (Map item in list) {
          num distance = CalculateUtil.calculateLatlngDistance(
              story.lat, story.lon, item["lat"], item["lon"]);
          if (distance < LocationConfig.poiSearchInterval) {
            item["custom_address"] = story.customAddress;
            item["write_address"] = story.writeAddress;
            item["radius"] = story.radius;
            await Query(DBManager.tableStory).primaryKey([item["id"]]).update({
              "custom_address": story.customAddress,
              "lon": story.lon,
              "lat": story.lat,
              "write_address": story.writeAddress,
              "radius": story.radius,
            });
            await mergeStory(item["id"] as num);
          }
        }
      }
    }
  }

  Future mergeStory(num storyId) async {
    List<Story> stories = [];
    Story story = await queryById(storyId);
    if (story != null && story.isDeleted == 0 && story.isMerged != 1) {
      stories.add(story);
      Story afterStory = await findAfterStory(story.updateTime, equal: false);
      while (afterStory != null) {
        if ((afterStory.lat == story.lat && afterStory.lon == story.lon) ||
            ((afterStory.writeAddress == story.writeAddress ||
                    afterStory.customAddress == story.customAddress) &&
                CalculateUtil.calculateLatlngDistance(
                        story.lat, story.lon, afterStory.lat, afterStory.lon) <
                    LocationConfig.poiSearchInterval)) {
          story.updateTime = afterStory.updateTime;
          story.customAddress = afterStory.customAddress ?? story.customAddress;
          story.writeAddress = afterStory.writeAddress ?? story.writeAddress;
          story.desc = afterStory.desc ?? story.desc;
          stories.add(afterStory);
          afterStory = await findAfterStory(story.updateTime, equal: false);
        } else {
          afterStory = null;
        }
      }
      Story beforeStory = await findBeforeStory(story.createTime, equal: false);
      while (beforeStory != null) {
        if ((beforeStory.lat == story.lat && beforeStory.lon == story.lon) ||
            ((beforeStory.writeAddress == story.writeAddress ||
                    beforeStory.customAddress == story.customAddress) &&
                await CalculateUtil.calculateLatlngDistance(story.lat,
                        story.lon, beforeStory.lat, beforeStory.lon) <
                    LocationConfig.poiSearchInterval)) {
          story.createTime = beforeStory.createTime;
          story.customAddress =
              beforeStory.customAddress ?? story.customAddress;
          story.writeAddress = beforeStory.writeAddress ?? story.writeAddress;
          story.desc = beforeStory.desc ?? story.desc;
          stories.add(beforeStory);
          beforeStory =
              await findBeforeStory(beforeStory.createTime, equal: false);
        } else {
          beforeStory = null;
        }
      }
      if (stories != null && stories.length > 1) {
        Story newStory = Story.fromJson(story.toJson());
        newStory.id = null;
        newStory.intervalTime = story.updateTime - story.createTime;
        newStory.isMerged = 1;
        newStory.uuid = Uuid().v1();
        for (Story s in stories) {
          await updateStoryDelete(s.id, 2);
          await PictureHelper().updatePictureUuid(s.uuid, newStory.uuid);
        }
        newStory = await calculateRadius(newStory);
        await createStory(newStory);
      }
    }
  }

  Future<Story> queryById(num storyId) async {
    if (storyId != null) {
      Map map = await Query(DBManager.tableStory).primaryKey([storyId]).first();
      if (map != null && map.length > 0) {
        return Story.fromJson(Map<String, dynamic>.from(map));
      }
    }
    return null;
  }

  Future updateStoryDelete(num id, num delete) async {
    await Query(DBManager.tableStory)
        .primaryKey([id]).update({"is_deleted": delete});
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

//  /// 读取库中的全部数据
//  Future<List<Story>> findAllStories() async {
//    List result = await Query(DBManager.tableStory).whereByColumFilters([
//      WhereCondiction("interval_time", WhereCondictionType.EQ_OR_MORE_THEN,
//          LocationConfig.judgeUsefulLocation),
//      WhereCondiction("is_deleted", WhereCondictionType.NOT_IN, [1])
//    ]).all();
//    List<Story> list = [];
//
//    if (result != null && result.length > 0) {
//      result = result.reversed.toList();
//      for (Map item in result) {
//        Story story = Story.fromJson(Map<String, dynamic>.from(item));
//        list.addAll(await separateStory(story));
//      }
//    }
//    return list;
//  }

  ///查找某个时间之后的stories
  Future<List<Story>> findAfterStories(num time) async {
    if (time == null) {
      time = 0;
    }
    List result = await Query(DBManager.tableStory).orderBy([
      "create_time desc"
    ]).whereBySql(
        "create_time >= ? and (isFromPicture = ? or interval_time >= ?) and is_deleted = 0",
        [time, 1, LocationConfig.interval]).all();
    List<Story> list = [];
    if (result != null && result.length > 0) {
      int count = result.length;
      Story story;
      Story story2;
      for (int i = 0; i < count; i++) {
        story = Story.fromJson(Map<String, dynamic>.from(result[i]));
        if (story.isFromPicture != 1) {
          if (i == count - 1) {
            story2 = await findBeforeShowStory(story.createTime);
          } else {
            story2 = Story.fromJson(Map<String, dynamic>.from(result[i + 1]));
          }
          story.others = await findBetweenStories(
              story.createTime, story2?.createTime ?? 0);
        }
        story.date = getShowTime(story.createTime);
//        list.addAll(await separateStory(story));
        list.add(await checkStoryPictures(story));
      }
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
        .whereBySql(
            "update_time < ? and (isFromPicture = ? or interval_time >= ?) and is_deleted = 0",
            [time, 1, LocationConfig.interval])
        .limit(20)
        .all();
    List<Story> list = [];
    if (result != null && result.length > 0) {
      int count = result.length;
      Story story;
      Story story2;
      for (int i = 0; i < count; i++) {
        story = Story.fromJson(Map<String, dynamic>.from(result[i]));
        if (story.isFromPicture != 1) {
          if (i == count - 1) {
            story2 = await findBeforeShowStory(story.createTime);
          } else {
            story2 = Story.fromJson(Map<String, dynamic>.from(result[i + 1]));
          }
          story.others = await findBetweenStories(
              story.createTime, story2?.createTime ?? 0);
        }
        story.date = getShowTime(story.createTime);
//        list.addAll(await separateStory(story));
        list.add(await checkStoryPictures(story));
      }
    }
    return list;
  }

  /// 检查当前story位置之后最新的story和Location，并放入story中
  Future<List<Story>> checkLatestStory(List<Story> stories) async {
    num millis = DateTime.now().millisecondsSinceEpoch;
    if (stories == null) {
      stories = List<Story>();
    }
    List<Story> checkedStories = [];
    for (Story story in stories) {
      checkedStories.add(await checkStoryPictures(story));
    }
    print("检查图片是否被删除耗时${DateTime.now().millisecondsSinceEpoch - millis}");

    /// 检测给的stories集合之后的story并放入集合中
    if (checkedStories != null && checkedStories.length > 0) {
      List result = await Query(DBManager.tableStory)
          .orderBy(["create_time"]).whereByColumFilters([
        WhereCondiction("create_time", WhereCondictionType.MORE_THEN,
            checkedStories[0].createTime),
        WhereCondiction("is_deleted", WhereCondictionType.IN, [0]),
        WhereCondiction("interval_time", WhereCondictionType.EQ_OR_MORE_THEN,
            LocationConfig.interval)
      ]).all();
      if (result != null && result.length > 0) {
        for (Map item in result) {
          Story story = Story.fromJson(Map<String, dynamic>.from(item));
//          checkedStories.insertAll(0, await separateStory(story));
          story.date = getShowTime(story.createTime);
          checkedStories.insert(0, story);
        }
      }
    }
    return checkedStories;
  }

  /// 获取当前位置的story
  Future<Story> getCurrentStory() async {
    Story currentStory = await queryLastStory();
    if (currentStory != null) {
      currentStory.date = getShowTime(currentStory.createTime);
      if (currentStory.isFromPicture != 1) {
        Story before = await findBeforeShowStory(currentStory.createTime);
        currentStory.others = await findBetweenStories(
            currentStory.createTime, before?.createTime ?? 0);
      }
//      currentStory.updateTime = DateTime.now().millisecondsSinceEpoch;
//      currentStory.intervalTime =
//          currentStory.updateTime - currentStory.createTime;

    } else {
      return null;
    }
    return await checkStoryPictures(currentStory);
  }

  Future<Story> checkStoryPictures(Story story) async {
    story.localImages = await PictureHelper().queryPicturesByUuid(story.uuid);
    return story;
  }

//  /// 判断story是否在同一天，不在同一天就分割成多天
//  Future<List<Story>> separateStory(Story story) async {
//    ///找到Picture
//    List<Picture> pictures =
//        await PictureHelper().queryPicturesByUuid(story.uuid);
//
//    List<Story> list = [];
//    DateTime dateTime1 =
//        DateTime.fromMillisecondsSinceEpoch(story.createTime.toInt());
//    DateTime dateTime2 =
//        DateTime.fromMillisecondsSinceEpoch(story.updateTime.toInt());
//    DateTime day1 = DateTime(dateTime1.year, dateTime1.month, dateTime1.day);
//    DateTime day2 = DateTime(dateTime2.year, dateTime2.month, dateTime2.day);
//    if (day1.isAtSameMomentAs(day2) || story.isFromPicture == 1) {
//      story.date = getShowTime(story.createTime);
//      story.localImages = [];
//      if (pictures != null && pictures.length > 0) {
//        for (Picture picture in pictures) {
//          if (DateUtil.isSameDay(picture.creationDate, story.createTime)) {
//            story.localImages.add(picture);
//          }
//        }
//      }
//      list.add(story);
//      return list;
//    } else {
//      Map<String, dynamic> map = story.toJson();
//      Story story1;
//      int intervalDay = day2.difference(day1).inDays;
//      DateTime day;
//      for (num i = 0; i <= intervalDay; i++) {
//        story1 = Story.fromJson(map);
//        day = DateTime.fromMillisecondsSinceEpoch(day1.millisecondsSinceEpoch);
//        if (i == 0) {
//          story1.updateTime = day.add(Duration(days: 1)).millisecondsSinceEpoch;
//        } else if (i == intervalDay) {
//          story1.createTime = day2.millisecondsSinceEpoch;
//        } else {
//          story1.createTime = day.add(Duration(days: i)).millisecondsSinceEpoch;
//          story1.updateTime =
//              day.add(Duration(days: i + 1)).millisecondsSinceEpoch;
//        }
//        story1.date = getShowTime(story1.createTime);
//        story1.intervalTime = story1.updateTime - story1.createTime;
//        if (pictures != null && pictures.length > 0) {
//          story1.localImages = [];
//          for (Picture p in pictures) {
//            if (DateUtil.isSameDay(p.creationDate, story1.createTime)) {
//              story1.localImages.add(p);
//            }
//          }
//        }
//        list.add(story1);
//      }
//      return list.reversed.toList();
//    }
//  }

  ///获取展示的时间 2019.09.23
  String getShowTime(num timeStr) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStr.toInt());
    String newTime = DateFormat("yyyy.MM.dd").format(time);
    return newTime;
  }

  /// 查询最后一条story
  Future<Story> queryLastStory() async {
    List result = await Query(DBManager.tableStory)
        .orderBy(["create_time desc"]).whereByColumFilters([
      WhereCondiction("is_deleted", WhereCondictionType.IN, [0])
    ]).all();
    if (result != null && result.length > 0) {
      return Story.fromJson(Map<String, dynamic>.from(result[0]));
    }
    return null;
  }

//  /// 查询最早一条story
//  Future<Story> queryOldestStory() async {
//    Map result = await Query(DBManager.tableStory).whereByColumFilters([
//      WhereCondiction("is_deleted", WhereCondictionType.IN, [0])
//    ]).orderBy([
//      "create_time asc",
//    ]).first();
//    if (result != null && result.length > 0) {
//      return Story.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

  /// 查询记录的天数
  Future<int> getStoryDays() async {
    List stories = await Query(DBManager.tableStory)
        .orderBy(["create_time desc"]).needColums(["create_time"]).all();
    if (stories != null && stories.length > 0) {
      List dateList = [];
      DateTime dateTime;
      String date;
      for (Map map in stories) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(
            (map["create_time"] as num).toInt());
        date = "${dateTime.year}${dateTime.month}${dateTime.day}";
        if (!dateList.contains(date)) {
          dateList.add(date);
        }
      }
      return dateList.length;
    }
    return 1;
  }

  /// 查询足迹，相同的story算一个点
  Future<int> getFootprint(List<Story> list) async {
    List list1 = await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction("is_deleted", WhereCondictionType.IN, [0])
    ]).needColums(["default_address"]).groupBy(
        ["default_address"]).whereByColumFilters([
      WhereCondiction("custom_address", WhereCondictionType.IS_NULL, true)
    ]).all();
    List list2 = await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction("is_deleted", WhereCondictionType.IN, [0])
    ]).needColums(["custom_address"]).groupBy(
        ["custom_address"]).whereByColumFilters([
      WhereCondiction("custom_address", WhereCondictionType.IS_NULL, false)
    ]).all();
    int current = 0;

    /// 判断当前还未生成的story的点是否是新的足迹
    if (list != null && list.length > 0 && list[0].id == null) {
      List result = await Query(DBManager.tableStory).whereByColumFilters([
        WhereCondiction(
            "custom_address", WhereCondictionType.IN, [list[0].defaultAddress]),
        WhereCondiction("is_deleted", WhereCondictionType.IN, [0])
      ]).all();
      if (result == null || result?.length == 0) {
        current = 1;
      }
    }
    return (list1?.length ?? 0) + (list2?.length ?? 0) + current;
  }

  /// 根据Location创建story
  Future<Story> createStoryWithLocation(Mslocation location) async {
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
    story.isDeleted = 0;
    story.coordType = location.coordType;
    story.defaultAddress = getDefaultAddress(story);
    story.isFromPicture = location.isFromPicture ?? 0;
    story.uuid = Uuid().v1();
    story.isMerged = 0;
    story.radius = location.accuracy > LocationConfig.locationRadius
        ? LocationConfig.locationRadius
        : location.accuracy;
    //TODO:需要看相同的该地点是否有custom_address,write_address,有的话需要赋值
    Story targetStory = await findSamePointStory(story);
    if (targetStory != null) {
      story.writeAddress = targetStory.writeAddress;
      if (StringUtil.isNotEmpty(targetStory.customAddress)) {
        ///此处认为用户选择过的点是准确的，所以更新经纬度
        story.customAddress = targetStory.customAddress;
        story.lat = targetStory.lat;
        story.lon = targetStory.lon;
      }
    }
    return story;
  }

  Future<Story> calculateRadius(Story story) async {
    List<Story> stories = await findSamePointStories(story);
    if (stories != null && stories.length > 0) {
      List<Latlonpoint> points = [];
      List<Latlonpoint> temp = [];
      for (Story s in stories) {
        temp = await LocationHelper().queryPoints(s.createTime, s.updateTime);
        if (temp != null) {
          points.addAll(temp);
        }
      }
      Latlonpoint point = await CalculateUtil.calculateCenterLatLon(points);
      if (point != null) {
        story.radius = point.radius;
        if (StringUtil.isEmpty(story.customAddress)) {
          story.lat = point.lat;
          story.lon = point.lon;
        }
      }
    }
    return story;
  }

  ///根据当前story查库中相同地点的一个targetStory对象
  Future<Story> findSamePointStory(Story story) async {
    if (story == null || StringUtil.isEmpty(story.defaultAddress)) {
      return null;
    }
    List list = await Query(DBManager.tableStory).whereBySql(
        "default_address = ? and (custom_address IS NOT NULL or write_address IS NOT NULL)",
        [story.defaultAddress]).all();
    if (list != null && list.length > 0) {
      for (Map item in list) {
        num distance = CalculateUtil.calculateLatlngDistance(
            story.lat, story.lon, item["lat"], item["lon"]);
        if (distance < LocationConfig.poiSearchInterval) {
          Story targetStory =
              Story.fromJson(Map<String, dynamic>.from(list.first));
          return targetStory;
        }
      }
    }
    return null;
  }

  ///根据当前story查库中相同地点的story集合
  Future<List<Story>> findSamePointStories(Story story) async {
    if (StringUtil.isEmpty(story.defaultAddress)) {
      return null;
    }
    String sql = "default_address = ? and isFromPicture != 1";
    List args = [story.defaultAddress];
    if (!StringUtil.isEmpty(story.customAddress)) {
      sql =
          "(default_address = ? or custom_address = ?) and isFromPicture != 1";
      args = [story.defaultAddress, story.customAddress];
    }
    List list = await Query(DBManager.tableStory).whereBySql(sql, args).all();
    if (list != null && list.length > 0) {
      List<Story> stories = [];
      for (Map item in list) {
        num distance = CalculateUtil.calculateLatlngDistance(
            story.lat, story.lon, item["lat"], item["lon"]);
        if (distance < LocationConfig.poiSearchInterval) {
          stories.add(Story.fromJson(Map<String, dynamic>.from(list.first)));
        }
      }
      return stories;
    }
    return null;
  }

  /// 获取默认address
  String getDefaultAddress(Story story) {
    return StringUtil.isEmpty(story.poiName)
        ? (StringUtil.isEmpty(story.address) ? story.aoiName : story.address)
        : story.poiName;
  }

  /// 获取默认address
  String getLocationDefaultAddress(Mslocation mslocation) {
    return StringUtil.isEmpty(mslocation.poiname)
        ? (StringUtil.isEmpty(mslocation.address)
            ? mslocation.aoiname
            : mslocation.address)
        : mslocation.poiname;
  }

  /// 根据Location创建或更新Story
  Future<int> createOrUpdateStory(Mslocation location) async {
    if (location == null) {
      return -1;
    }
    String address = getLocationDefaultAddress(location);
    if (StringUtil.isEmpty(address)) {
      return -1;
    }
    Story currentStory = await createStoryWithLocation(location);
    Story lastStory = await queryLastStory();
    Story sameStory = await findSamePointStory(currentStory);
    if (lastStory != null) {
      /// 经纬度相等/地址相等认为是同一个地点
      if ((location.lat == lastStory.lat && location.lon == lastStory.lon) ||
          (CalculateUtil.calculateLatlngDistance(
                  lastStory.lat, lastStory.lon, location.lat, location.lon) <
              lastStory.radius) ||
          (lastStory.defaultAddress == address &&
              CalculateUtil.calculateLatlngDistance(lastStory.lat,
                      lastStory.lon, location.lat, location.lon) <
                  LocationConfig.judgeDistanceNum) ||
          (sameStory != null &&
              (sameStory.customAddress == lastStory.customAddress ||
                  sameStory.writeAddress == lastStory.writeAddress) &&
              CalculateUtil.calculateLatlngDistance(lastStory.lat,
                      lastStory.lon, location.lat, location.lon) <
                  LocationConfig.poiSearchInterval)) {
        lastStory.updateTime = location.updatetime;
        return await updateStoryTimes(lastStory);
      } else {
        return await createStory(currentStory);
      }
    } else {
      return await createStory(currentStory);
    }
  }

//  ///坐标点更新故事或创建故事
//  Future<void> judgeLocation(Mslocation location,
//      {LocationFromType itemType = LocationFromType.normal}) async {
//    if (location != null &&
//        location.errorCode == 0 &&
//        StringUtil.isNotEmpty(location.address)) {
//      Story story;
//      if (LocationFromType.before == itemType) {
//        story = await queryOldestStory();
//        if (story != null &&
//            !DateUtil.isSameDay(story.createTime, location.time)) {
//          return await createStory(await createStoryWithLocation(location));
//        }
//      } else if (LocationFromType.after == itemType) {
//        story = await findTargetStoryWithLocation(location);
//      } else {
//        story = await queryLastStory();
//        if (story.isFromPicture == 1) {
//          return await createStory(await createStoryWithLocation(location));
//        }
//      }
//      if (story != null) {
//        if (location.aoiname == story.aoiName) {
//          if (location.poiname == story.poiName) {
//            if (location.address == story.address) {
//              await updateStoryTime(location, story);
//            } else {
//              if (await getDistanceBetween(location, story) >
//                  LocationConfig.judgeDistanceNum) {
//                debugPrint("======>create1");
//                await createStory(await createStoryWithLocation(location));
//              } else {
//                await updateStoryTime(location, story);
//              }
//            }
//          } else {
//            if (await getDistanceBetween(location, story) >
//                LocationConfig.judgeDistanceNum) {
//              debugPrint("======>create2");
//              await createStory(await createStoryWithLocation(location));
//            } else {
//              await updateStoryTime(location, story);
//            }
//          }
//        } else {
//          debugPrint("======>create3");
//          await createStory(await createStoryWithLocation(location));
//        }
//      } else {
//        debugPrint("======>create4");
//        await createStory(await createStoryWithLocation(location));
//      }
//    }
//  }

  ///坐标点转化成story(即创建或更新)

//  Future<void> convertStoryWithEverLocation(
//      Mslocation lastLocation, Mslocation location) async {
//    Story story = await findTargetStoryWithLocation(lastLocation);
//    if (story == null) {
//      await createStory(await createStoryWithLocation(location));
//      print("story 创建 ${location.aoiname}");
//    } else {
//      await updateStoryTime(location, story);
//      print("story 更新 ${story.aoiName}   ${story.id}");
//    }
//  }

//  Future<bool> judgeSamePlace(Story story1, Story story2) async {
//    if ((story1.lat == story2.lat && story1.lon == story2.lon) ||
//        await CalculateUtil.calculateStoriesDistance(story1, story2) <
//            LocationConfig.locationRadius ||
//        (story1.address == story2.address &&
//            await CalculateUtil.calculateStoriesDistance(story1, story2) <
//                LocationConfig.judgeDistanceNum)) {
//      return true;
//    }
//    return false;
//  }

//  ///根据坐标点查找对应story
//  Future<Story> findTargetStoryWithLocation(Mslocation location) async {
//    if (location == null) {
//      return null;
//    }
//    Map result;
//    result = await Query(DBManager.tableStory).whereByColumFilters([
//      WhereCondiction(
//          "create_time", WhereCondictionType.EQ_OR_LESS_THEN, location.time),
//      WhereCondiction("update_time", WhereCondictionType.EQ_OR_MORE_THEN,
//          location.updatetime),
//      WhereCondiction("is_deleted", WhereCondictionType.NOT_IN, [1])
//    ]).first();
//    if (result == null) {
//      result = await Query(DBManager.tableStory)
//          .orderBy(["create_time desc"]).whereByColumFilters([
//        WhereCondiction(
//            "create_time", WhereCondictionType.EQ_OR_LESS_THEN, location.time),
//        WhereCondiction("is_deleted", WhereCondictionType.NOT_IN, [1])
//      ]).first();
//      if (result != null) {
//        Story lastStory = Story.fromJson(Map<String, dynamic>.from(result));
//        if (lastStory.updateTime >= location.time) {
//          return lastStory;
//        }
//      }
//    }
//    if (result != null) {
//      return Story.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

  ///根据坐标点查找对应story
  Future<Story> findTargetStory(num startTime, num endTime) async {
    Map result = await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction(
          "create_time", WhereCondictionType.EQ_OR_LESS_THEN, startTime),
      WhereCondiction(
          "update_time", WhereCondictionType.EQ_OR_MORE_THEN, endTime),
    ]).first();
    if (result != null && result.length > 0) {
      return Story.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///根据坐标点查找对应story
  Future<List<Story>> findBetweenStories(num bigTime, num smallTime) async {
    List result = await Query(DBManager.tableStory)
        .orderBy(["create_time desc"]).whereByColumFilters([
      WhereCondiction("create_time", WhereCondictionType.MORE_THEN, smallTime),
      WhereCondiction("create_time", WhereCondictionType.LESS_THEN, bigTime),
      WhereCondiction("isFromPicture", WhereCondictionType.NOT_IN, [1]),
      WhereCondiction("is_deleted", WhereCondictionType.IN, [0]),
    ]).all();
    if (result != null && result.length > 0) {
      List<Story> list = [];
      for (Map map in result) {
        list.add(Story.fromJson(Map<String, dynamic>.from(map)));
      }
      return list;
    }
    return null;
  }

  ///根据时间查找对应story
  Future<Story> findAfterStory(num time, {bool equal = true}) async {
    Map result = await Query(DBManager.tableStory)
        .orderBy(["create_time"]).whereByColumFilters([
      WhereCondiction(
          "create_time",
          equal
              ? WhereCondictionType.EQ_OR_MORE_THEN
              : WhereCondictionType.MORE_THEN,
          time),
      WhereCondiction("is_deleted", WhereCondictionType.IN, [0]),
    ]).first();
    if (result != null && result.length > 0) {
      return Story.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///根据时间查找对应story
  Future<Story> findBeforeStory(num time, {bool equal = true}) async {
    Map result = await Query(DBManager.tableStory)
        .orderBy(["update_time desc"]).whereByColumFilters([
      WhereCondiction(
          "update_time",
          equal
              ? WhereCondictionType.EQ_OR_LESS_THEN
              : WhereCondictionType.LESS_THEN,
          time),
      WhereCondiction("is_deleted", WhereCondictionType.IN, [0]),
    ]).first();
    if (result != null && result.length > 0) {
      return Story.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///根据时间查找对应story
  Future<Story> findBeforeShowStory(num time) async {
    Map result = await Query(DBManager.tableStory)
        .orderBy(["create_time desc"]).whereByColumFilters([
      WhereCondiction("create_time", WhereCondictionType.LESS_THEN, time),
      WhereCondiction("is_deleted", WhereCondictionType.IN, [0]),
      WhereCondiction("interval_time", WhereCondictionType.EQ_OR_MORE_THEN,
          LocationConfig.interval),
      WhereCondiction("isFromPicture", WhereCondictionType.NOT_IN, [1]),
    ]).first();
    if (result != null && result.length > 0) {
      return Story.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

//  Future<void> deleteMisstory() async {
//    Story story = await queryLastStory();
//    await Query(DBManager.tableStory).primaryKey([story.id]).delete();
//    await Query(DBManager.tableStory).delete();
//  }

//  ///求值：两个坐标点的距离
//  Future<double> getDistanceBetween(Mslocation location, Story story) async {
//    LatLng latLng1 = LatLng(location.lat, location.lon);
//    LatLng latLng2 = LatLng(story.lat, story.lon);
//    return await CalculateTools().calcDistance(latLng1, latLng2);
//  }

//  ///求值：两个坐标点的距离
//  Future<double> getDistanceBetweenStory(Story location, Story story) async {
//    LatLng latLng1 = LatLng(location.lat, location.lon);
//    LatLng latLng2 = LatLng(story.lat, story.lon);
//    return await CalculateTools().calcDistance(latLng1, latLng2);
//  }

//  Future<double> getDistanceBetween1() async {
//    LatLng latLng1 = LatLng(30.94507622612847, 120.89830213758681);
//    LatLng latLng2 = LatLng(30.94544731987847, 120.89528781467014);
//    return await CalculateTools().calcDistance(latLng1, latLng2);
////    return await CalculateUtil.calculateLineDistance(latLng1, latLng2);
//  }

  /// 给库中数据默认上default_address
  Future updateAllDefaultAddress() async {
    List list = await Query(DBManager.tableStory).all();
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
        defaultAddress = StringUtil.isEmpty(poiname)
            ? (StringUtil.isEmpty(address) ? aoiname : address)
            : poiname;
        await Query(DBManager.tableStory)
            .primaryKey([id]).update({"default_address": defaultAddress});
      }
    }
  }

//  ///更新图片
//  Future updateStoryPictures(num id, String pictures) async {
//    await Query(DBManager.tableStory)
//        .primaryKey([id]).update({"pictures": pictures});
//    return true;
//  }

  ///删除指定的story 状态删除
  Future deleteTargetStoryWithStoryId(num id) async {
    await Query(DBManager.tableStory)
        .primaryKey([id]).update({"is_deleted": 1});
  }

//

  /// 删除无用的story
  Future deleteUnUsefulStory() async {
    await Query(DBManager.tableStory).whereByColumFilters([
      WhereCondiction("interval_time", WhereCondictionType.LESS_THEN,
          LocationConfig.judgeUsefulLocation)
    ]).delete();
  }

  ///删除图片生成的位置信息
  Future deletePictureStory() async {
//    await Query(DBManager.tableStory).whereByColumFilters([
//      WhereCondiction("isFromPicture", WhereCondictionType.IN, [1])
//    ]).delete();
    await Query(DBManager.tableStory)
        .whereBySql("isFromPicture = ?", [1]).delete();
    await Query(DBManager.tableStory).update({"pictures": ""});
    print("-------删除Picture生成的Story成功");
  }

  Future clear() async {
    await Query(DBManager.tableStory).delete();
  }

  Future updateCoordType() async {
    await Query(DBManager.tableStory).update({"coord_type": CoordType.aMap});
  }

  Future updateUUID() async {
    List result = await Query(DBManager.tableStory).needColums(["id"]).all();
    if (result != null && result.length > 0) {
      Uuid uuid = Uuid();
      for (Map map in result) {
        await Query(DBManager.tableStory).primaryKey([map["id"]]).update(
            {"uuid": uuid.v1(), "is_deleted": 0});
      }
    }
  }

  Future updateRadius() async {
    List result = await Query(DBManager.tableStory).needColums(["id"]).all();
    if (result != null && result.length > 0) {
      for (Map map in result) {
        await Query(DBManager.tableStory).primaryKey([map["id"]]).update(
            {"radius": LocationConfig.locationRadius});
      }
    }
  }

  Future updateMerged() async {
    List result = await Query(DBManager.tableStory).needColums(["id"]).all();
    if (result != null && result.length > 0) {
      for (Map map in result) {
        await Query(DBManager.tableStory)
            .primaryKey([map["id"]]).update({"is_merged": 0});
      }
    }
  }
}
