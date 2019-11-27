import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/helper/location_db_helper.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/amap_poi.dart';
import 'package:misstory/models/coord_type.dart';
import 'package:misstory/models/latlon_range.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/location.dart';
import 'package:misstory/models/timeline.dart';
import 'package:misstory/utils/calculate_util.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/utils/print_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:uuid/uuid.dart';
import 'package:misstory/net/http_manager.dart';

import '../db_manager.dart';
import 'picture_helper.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-20
///
class TimelineHelper {
  static final TimelineHelper _instance = new TimelineHelper._internal();

  factory TimelineHelper() => _instance;

  TimelineHelper._internal();

  /// 根据Location创建或更新Timeline
  Future<String> createOrUpdateTimeline(Location location) async {
    if (location == null) {
      return "";
    }
    Timeline lastTimeline = await queryLastTimeline();
    if (lastTimeline != null) {
      /// 经纬度相等/在一个半径内认为是同一个地点
      if ((location.lat == lastTimeline.lat &&
              location.lon == lastTimeline.lon) ||
          (CalculateUtil.calculateLatlngDistance(lastTimeline.lat,
                  lastTimeline.lon, location.lat, location.lon) <
              lastTimeline.radius)) {
        lastTimeline.endTime = location.time;
        await updateTimeline(lastTimeline);
        return lastTimeline.uuid;
      } else {
        return await createTimeline(await convertTimeline(location));
      }
    } else {
      return await createTimeline(await convertTimeline(location));
    }
  }

  /// 根据Location创建或更新Timeline
  Future<String> createOrUpdateTimelineByPicture(Location location) async {
    if (location == null) {
      return "";
    }
    Timeline firstTimeline = await queryFistTimeline();
    if (firstTimeline != null) {
      /// 经纬度相等/在一个半径内认为是同一个地点
      if ((DateUtil.isSameDay(firstTimeline.startTime, location.time)) &&
          ((location.lat == firstTimeline.lat &&
                  location.lon == firstTimeline.lon) ||
              (CalculateUtil.calculateLatlngDistance(firstTimeline.lat,
                      firstTimeline.lon, location.lat, location.lon) <
                  firstTimeline.radius))) {
        firstTimeline.startTime = location.time;
        await updateTimeline(firstTimeline);
        return firstTimeline.uuid;
      } else {
        Timeline timeline = await convertTimeline(location, isFromPicture: 1);
        String uuid = await FlutterOrmPlugin.saveOrm(
            DBManager.tableTimeline, timeline.toJson());
        return uuid;
      }
    } else {
      Timeline timeline = await convertTimeline(location, isFromPicture: 1);
      String uuid = await FlutterOrmPlugin.saveOrm(
          DBManager.tableTimeline, timeline.toJson());
      return uuid;
    }
  }

  /// 编辑页面更新timeLine
  Future<bool> updateEditTimeItemAndSame(Timeline timeline) async {
    if (timeline != null) {
      List<Timeline> timelines = await querySameTimeline(timeline.sameId);
      for (Timeline t in timelines) {
        await Query(DBManager.tableTimeline).primaryKey([t.uuid]).update({
          "poi_id": timeline.poiId,
          "poi_name": timeline.poiName,
          "poi_type": timeline.poiType,
          "poi_type_code": timeline.poiTypeCode,
          "poi_location": timeline.poiLocation,
          "poi_address": timeline.poiAddress,
          "custom_address": timeline.customAddress,
          "is_confirm": timeline.isConfirm,
        });
      }
      await mergeTimeline(timeline.sameId);
      return true;
    }
    return false;
  }

  Future mergeTimeline(String timelineId) async {
//    Query(DBManager.tableTimeline).whereByColumFilters([
//      WhereCondiction("same_id",WhereCondictionType.IN,[timelineId])
//    ]).orderBy([""]).first();
  }

  ///更新Timeline
  Future<int> updateTimeline(Timeline timeline) async {
    if (timeline != null) {
      List<Timeline> timelines = await querySameTimeline(timeline.sameId);
      List<Latlonpoint> points = [];
      for (Timeline t in timelines) {
        points.addAll(await LocationDBHelper().queryPoints(t.uuid));
      }
      Latlonpoint latlonpoint =
          await CalculateUtil.calculateCenterLatLon(points);
      if (latlonpoint != null) {
        PrintUtil.debugPrint(
            "======计算平均半径，radius->${latlonpoint.radius},中心点${latlonpoint.latitude},${latlonpoint.longitude}");
        if (latlonpoint.radius > LocationConfig.locationMaxRadius) {
          latlonpoint.radius = LocationConfig.locationMaxRadius;
        }
        if (latlonpoint.radius < LocationConfig.locationRadius) {
          latlonpoint.radius = LocationConfig.locationRadius;
        }

        ///把新的中心点赋值给timeline
        timeline.lat = latlonpoint.latitude;
        timeline.lon = latlonpoint.longitude;
        timeline.radius = latlonpoint.radius;

        /// 新timeline的中心点可能会在上一个timeline的半径范围内，如果在就删除新timeline，
        /// 并把点合并到上一个上面去
        Timeline lastTimeline =
            await findBeforeTimeline(timeline.startTime, equal: false);
        if (lastTimeline != null &&
            CalculateUtil.calculateLatlngDistance(timeline.lat, timeline.lon,
                    lastTimeline.lat, lastTimeline.lon) <=
                lastTimeline.radius) {
          await deleteTimeline(timeline);
          LocationDBHelper()
              .updateLocationsTimelineId(timeline.uuid, lastTimeline.uuid);
          lastTimeline.endTime = timeline.endTime;
          return await updateTimeline(lastTimeline);
        }

        ///判断是否需要更新poi
        if (timeline.isConfirm != 1) {
          if (timeline.needUpdatePoi == 1) {
            timeline = await requestPoiData(timeline);
            PrintUtil.debugPrint("======1更新poi，poi->${timeline.poiName}");
          } else if (StringUtil.isNotEmpty(timeline.poiLocation)) {
            List latlonList = timeline.poiLocation.split(",");
            if (latlonList.length == 3) {
              String coordType = latlonList[2];
              double lat1, lon1, lat2, lon2;
              if (CoordType.aMap == coordType) {
                //原始坐标转高德
                var latLng = CalculateUtil.wgsToGcj(timeline.lat, timeline.lon);
                lat1 = latLng["lat"];
                lon1 = latLng["lon"];

                lat2 = double.tryParse(latlonList[1]);
                lon2 = double.tryParse(latlonList[0]);
                PrintUtil.debugPrint(
                  "======原始坐标转换成高德$lat1,$lon1 poi坐标$lat2,$lon2",
                );
              } else {
                lat1 = timeline.lat;
                lon1 = timeline.lon;
                lat2 = double.tryParse(latlonList[1]);
                lon2 = double.tryParse(latlonList[0]);
              }
              num distance = num.tryParse(timeline.distance);
              if (distance == null || distance == 0) {
                distance = 10;
              }
              num dis =
                  CalculateUtil.calculateLatlngDistance(lat1, lon1, lat2, lon2);
              PrintUtil.debugPrint("======新中心点到poi的距离$dis,原始距离$distance+5");
              if (dis > distance + 5) {
                timeline = await requestPoiData(timeline);
                PrintUtil.debugPrint("======2更新poi，poi->${timeline.poiName}");
              }
            }
          }
        }
      }
      timeline.intervalTime = timeline.endTime - timeline.startTime;
      Query(DBManager.tableTimeline)
          .primaryKey([timeline.uuid]).update(timeline.toJson());
      PrintUtil.debugPrint("======更新Timeline，radius->${timeline.radius}");
      return 0;
    }
    return -1;
  }

  /// 查询最后一条Timeline
  Future<Timeline> queryLastTimeline() async {
    Map result = await Query(DBManager.tableTimeline)
        .orderBy(["start_time desc"]).whereByColumFilters([
      WhereCondiction("is_delete", WhereCondictionType.IN, [0])
    ]).first();
    if (result != null && result.length > 0) {
      return Timeline.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  /// 查询最第一条Timeline
  Future<Timeline> queryFistTimeline() async {
    Map result = await Query(DBManager.tableTimeline)
        .orderBy(["start_time"]).whereByColumFilters([
      WhereCondiction("is_delete", WhereCondictionType.IN, [0])
    ]).first();
    if (result != null && result.length > 0) {
      return Timeline.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  /// 创建Timeline
  Future<String> createTimeline(Timeline timeline) async {
    if (timeline != null) {
      Timeline lastTimeline = await queryLastTimeline();
      if (lastTimeline != null) {
        if (lastTimeline.intervalTime < LocationConfig.judgeUsefulLocation) {
          await deleteTimeline(lastTimeline);
          lastTimeline = await queryLastTimeline();
        }
      }
      String uuid;
      if (lastTimeline != null &&
          ((timeline.lat == lastTimeline.lat &&
                  timeline.lon == lastTimeline.lon) ||
              (CalculateUtil.calculateLatlngDistance(lastTimeline.lat,
                      lastTimeline.lon, timeline.lat, timeline.lon) <
                  lastTimeline.radius)) &&
          (timeline.startTime - lastTimeline.endTime) <
              LocationConfig.intervalGap) {
        lastTimeline.endTime = timeline.endTime;
        await updateTimeline(lastTimeline);
        uuid = lastTimeline.uuid;
      } else {
        uuid = await FlutterOrmPlugin.saveOrm(
            DBManager.tableTimeline, timeline.toJson());
      }
      PrintUtil.debugPrint("======创建Timeline！,radius->${timeline.radius}");
      return uuid;
    }
    return "";
  }

  /// location转成Timeline
  Future<Timeline> convertTimeline(Location location,
      {num isFromPicture = 0}) async {
    if (location != null) {
      Timeline timeline = new Timeline();
      timeline.uuid = Uuid().v1();
      timeline.lat = location.lat;
      timeline.lon = location.lon;
      timeline.altitude = location.altitude;
      timeline.radius = LocationConfig.locationRadius;
      timeline.radiusSd = 0;
      timeline.startTime = location.time;
      timeline.endTime = location.time;
      timeline.intervalTime = 0;
      timeline.isDelete = 0;
      timeline.isFromPicture = isFromPicture;
      timeline.poiName = "Unknow";
      timeline.sameId = Uuid().v1();
      timeline.isConfirm = 0;
      return await updatePoiData(timeline);
    }
    return null;
  }

  /// 给Timeline更新poi信息
  Future<Timeline> updatePoiData(Timeline timeline) async {
    if (timeline != null) {
      ///先找是否有过该Timeline位置的信息
      Timeline same = await findSamePoiData(timeline);
      if (same != null) {
        timeline.sameId = same.sameId;
        timeline.poiId = same.poiId;
        timeline.poiName = same.poiName;
        timeline.poiAddress = same.poiAddress;
        timeline.poiType = same.poiType;
        timeline.poiTypeCode = same.poiTypeCode;
        timeline.poiLocation = same.poiLocation;
        timeline.distance = same.distance;
        timeline.country = same.country;
        timeline.province = same.province;
        timeline.city = same.city;
        timeline.district = same.district;
        timeline.needUpdatePoi = same.needUpdatePoi;
        timeline.customAddress = same.customAddress;
        timeline.isConfirm = same.isConfirm;
      } else {
        timeline = await requestPoiData(timeline);
      }
    }
    return timeline;
  }

  /// 找到跟当前Timeline相近的Timeline
  Future<Timeline> findSamePoiData(Timeline timeline) async {
    if (timeline != null) {
      Latlonpoint latlonpoint = Latlonpoint(timeline.lat, timeline.lon)
        ..radius = 400;
      LatlonRange latlonRange = CalculateUtil.getRange(latlonpoint);
      List list = await Query(DBManager.tableTimeline).whereByColumFilters([
        WhereCondiction("interval_time", WhereCondictionType.EQ_OR_MORE_THEN,
            LocationConfig.judgeUsefulLocation),
        WhereCondiction(
            "lat", WhereCondictionType.EQ_OR_MORE_THEN, latlonRange.minLat),
        WhereCondiction(
            "lat", WhereCondictionType.EQ_OR_LESS_THEN, latlonRange.maxLat),
        WhereCondiction(
            "lon", WhereCondictionType.EQ_OR_MORE_THEN, latlonRange.minLon),
        WhereCondiction(
            "lon", WhereCondictionType.EQ_OR_LESS_THEN, latlonRange.maxLon),
        WhereCondiction("is_delete", WhereCondictionType.IN, [0]),
      ]).all();
      if (list != null) {
        num distance = 1000;
        Timeline t;
        for (Map map in list) {
          num d = CalculateUtil.calculateLatlngDistance(
              map["lat"] as num, map["lon"] as num, timeline.lat, timeline.lon);
          if (d < distance) {
            distance = d;
            t = Timeline.fromJson(Map<String, dynamic>.from(map));
          }
        }
        if (t != null) {
          if (distance <= t.radius) {
            return t;
          }
        }
      }
    }
    return null;
  }

  /// 网络请求下poi并赋值给Timeline
  Future<Timeline> requestPoiData(Timeline timeline) async {
    if (timeline != null) {
      var latLng = CalculateUtil.wgsToGcj(timeline.lat, timeline.lon);
      List<AmapPoi> list = await requestPois(
          lat: latLng['lat'], lon: latLng['lon'], limit: 1, radius: 300);
      if (list != null && list.length > 0) {
        AmapPoi amapPoi = list[0];
        if (amapPoi != null) {
          timeline.poiId = amapPoi.id;
          timeline.poiName = amapPoi.name;
          timeline.poiAddress = amapPoi.address;
          timeline.poiType = amapPoi.type;
          timeline.poiTypeCode = amapPoi.typecode;
          if (StringUtil.isNotEmpty(amapPoi.location)) {
            timeline.poiLocation = "${amapPoi.location},GCJ02";
          }
          timeline.distance = amapPoi.distance;
          timeline.country = "中国";
          timeline.province = amapPoi.pname;
          timeline.city = amapPoi.cityname;
          timeline.district = amapPoi.adname;
          timeline.needUpdatePoi = 0;
        }
      } else if (list == null) {
        timeline.needUpdatePoi = 1;
      }
    }
    return timeline;
  }

  Future deleteTimeline(Timeline timeline) async {
    await Query(DBManager.tableTimeline)
        .primaryKey([timeline.uuid]).update({"is_delete": 1});
  }

  /// 查找same_id相同的TimeLine
  Future<List<Timeline>> querySameTimeline(String sameId) async {
    List list = await Query(DBManager.tableTimeline)
        .orderBy(["start_time desc"]).whereByColumFilters([
      WhereCondiction("same_id", WhereCondictionType.IN, [sameId])
    ]).all();
    if (list != null && list.length > 0) {
      List<Timeline> timelines = [];
      for (Map map in list) {
        timelines.add(Timeline.fromJson(Map<String, dynamic>.from(map)));
      }
      return timelines;
    }
    return null;
  }

  /// 更新事件描述
  Future<bool> updateTimelineDesc(Timeline timeline) async {
    if (timeline != null) {
      await Query(DBManager.tableTimeline)
          .primaryKey([timeline.uuid]).update({"desc": timeline.desc});
      return true;
    }
    return false;
  }

  /**
   *
   * 以上为生成timeline的逻辑
   *
   *
   *
   *
   *
   *
   *
   *
   *
   *
   *
   *
   * 以下为首页显示用到的相关操作
   *
   *
   */

  ///查找某个时间之后的stories
  Future<List<Timeline>> findAfterStories(num time) async {
    if (time == null) {
      time = 0;
    }
    List result = await Query(DBManager.tableTimeline).orderBy([
      "start_time desc"
    ]).whereBySql(
        "start_time >= ? and (is_from_picture = ? or interval_time >= ?) and is_delete = 0",
        [time, 1, LocationConfig.judgeUsefulLocation]).all();
    List<Timeline> list = [];
    if (result != null && result.length > 0) {
      int count = result.length;
      Timeline timeline;
      for (int i = 0; i < count; i++) {
        timeline = Timeline.fromJson(Map<String, dynamic>.from(result[i]));
        timeline.date = DateUtil.getShowTime(timeline.startTime);
//        list.addAll(await separateStory(story));
        list.add(await checkStoryPictures(timeline));
      }
    }
    return list;
  }

  /// 根据给定time查询time-day到time之间的story
  Future<List<Timeline>> queryMoreHistories({num time}) async {
    if (time == null) {
      time = DateTime.now().millisecondsSinceEpoch;
    }
    List result = await Query(DBManager.tableTimeline)
        .orderBy(["start_time desc"])
        .whereBySql(
            "end_time < ? and (is_from_picture = ? or interval_time >= ?) and is_delete = 0",
            [time, 1, LocationConfig.judgeUsefulLocation])
        .limit(20)
        .all();
    List<Timeline> list = [];
    if (result != null && result.length > 0) {
      int count = result.length;
      Timeline timeline;
      for (int i = 0; i < count; i++) {
        timeline = Timeline.fromJson(Map<String, dynamic>.from(result[i]));
        timeline.date = DateUtil.getShowTime(timeline.startTime);
//        list.addAll(await separateStory(story));
        list.add(await checkStoryPictures(timeline));
      }
    }
    return list;
  }

  ///查询需要显示的全部timeline
  Future<List<Timeline>> queryAll() async {
    List result = await Query(DBManager.tableTimeline)
        .orderBy(["start_time desc"]).whereBySql(
            "(is_from_picture = ? or interval_time >= ?) and is_delete = 0",
            [1, 0]).all();
    List<Timeline> list = [];
    if (result != null && result.length > 0) {
      int count = result.length;
      Timeline timeline;
      for (int i = 0; i < count; i++) {
        timeline = Timeline.fromJson(Map<String, dynamic>.from(result[i]));
//        timeline.date = DateUtil.getShowTime(timeline.startTime);
//        list.add(await checkStoryPictures(timeline));
        list.add(timeline);
      }
    }
    return list;
  }

  Future<Timeline> checkStoryPictures(Timeline timeline) async {
    timeline.pictures =
        await PictureHelper().queryPicturesByUuid(timeline.uuid);
    return timeline;
  }

  /// 检查当前Timeline位置之后最新的Timeline，并放入Timeline中
  Future<List<Timeline>> checkLatestStory(List<Timeline> timelines) async {
    num millis = DateTime.now().millisecondsSinceEpoch;
    if (timelines == null) {
      timelines = List<Timeline>();
    }
    List<Timeline> checkedTimelines = [];
    for (Timeline timeline in timelines) {
      checkedTimelines.add(await checkStoryPictures(timeline));
    }
    print("检查图片是否被删除耗时${DateTime.now().millisecondsSinceEpoch - millis}");

    /// 检测给的stories集合之后的story并放入集合中
    if (checkedTimelines != null && checkedTimelines.length > 0) {
      List result = await Query(DBManager.tableTimeline)
          .orderBy(["start_time"]).whereByColumFilters([
        WhereCondiction("start_time", WhereCondictionType.MORE_THEN,
            checkedTimelines[0].startTime),
        WhereCondiction("is_delete", WhereCondictionType.IN, [0]),
        WhereCondiction("interval_time", WhereCondictionType.EQ_OR_MORE_THEN,
            LocationConfig.judgeUsefulLocation)
      ]).all();
      if (result != null && result.length > 0) {
        for (Map item in result) {
          Timeline timeline =
              Timeline.fromJson(Map<String, dynamic>.from(item));
//          checkedStories.insertAll(0, await separateStory(story));
          timeline.date = DateUtil.getShowTime(timeline.startTime);
          checkedTimelines.insert(0, timeline);
        }
      }
    }
    return checkedTimelines;
  }

  /// 获取当前位置的story
  Future<Timeline> getCurrentStory() async {
    Timeline current = await queryLastTimeline();
    if (current != null) {
      current.date = DateUtil.getShowTime(current.startTime);
    } else {
      return null;
    }
    return await checkStoryPictures(current);
  }

  /// 查询足迹，相同的story算一个点
  Future<int> getFootprint() async {
    List list1 = await Query(DBManager.tableTimeline).whereByColumFilters([
      WhereCondiction("is_delete", WhereCondictionType.IN, [0])
    ]).needColums(["same_id"]).groupBy(["same_id"]).all();
    return (list1?.length ?? 0);
  }

  /// 查询记录的天数
  Future<int> getStoryDays() async {
    List stories = await Query(DBManager.tableTimeline).orderBy(
        ["start_time desc"]).needColums(["start_time"]).whereByColumFilters([
      WhereCondiction("is_delete", WhereCondictionType.IN, [0])
    ]).all();
    if (stories != null && stories.length > 0) {
      List dateList = [];
      DateTime dateTime;
      String date;
      for (Map map in stories) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(
            (map["start_time"] as num).toInt());
        date = "${dateTime.year}${dateTime.month}${dateTime.day}";
        if (!dateList.contains(date)) {
          dateList.add(date);
        }
      }
      return dateList.length;
    }
    return 1;
  }

  /**
   *
   * 以上为首页展示用的方法
   *
   *
   *
   *
   *
   *
   *
   * 以下为生成图片Timeline用的方法
   *
   */

  ///根据坐标点查找对应story
  Future<Timeline> findTargetTimeline(num startTime, num endTime) async {
    Map result = await Query(DBManager.tableTimeline).whereByColumFilters([
      WhereCondiction(
          "start_time", WhereCondictionType.EQ_OR_LESS_THEN, startTime),
      WhereCondiction("end_time", WhereCondictionType.EQ_OR_MORE_THEN, endTime),
      WhereCondiction("is_delete", WhereCondictionType.IN, [0]),
    ]).first();
    if (result != null && result.length > 0) {
      return Timeline.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///根据时间查找对应story
  Future<Timeline> findAfterTimeline(num time, {bool equal = true}) async {
    Map result = await Query(DBManager.tableTimeline)
        .orderBy(["start_time"]).whereByColumFilters([
      WhereCondiction(
          "start_time",
          equal
              ? WhereCondictionType.EQ_OR_MORE_THEN
              : WhereCondictionType.MORE_THEN,
          time),
      WhereCondiction("is_delete", WhereCondictionType.IN, [0]),
    ]).first();
    if (result != null && result.length > 0) {
      return Timeline.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///根据时间查找对应story
  Future<Timeline> findBeforeTimeline(num time, {bool equal = true}) async {
    Map result = await Query(DBManager.tableTimeline)
        .orderBy(["end_time desc"]).whereByColumFilters([
      WhereCondiction(
          "end_time",
          equal
              ? WhereCondictionType.EQ_OR_LESS_THEN
              : WhereCondictionType.LESS_THEN,
          time),
      WhereCondiction("is_delete", WhereCondictionType.IN, [0]),
    ]).first();
    if (result != null && result.length > 0) {
      return Timeline.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///清除Location生成的Timeline
  Future deleteLocationTimeline() async {
    await Query(DBManager.tableTimeline).whereByColumFilters([
      WhereCondiction("is_from_picture", WhereCondictionType.IN, [0]),
    ]).delete();
  }
}
