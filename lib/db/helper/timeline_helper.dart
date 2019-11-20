import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/amap_poi.dart';
import 'package:misstory/models/latlon_range.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/location.dart';
import 'package:misstory/models/timeline.dart';
import 'package:misstory/utils/calculate_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:uuid/uuid.dart';
import 'package:misstory/net/http_manager.dart';

import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-20
///
class TimelineHelper {
  static final TimelineHelper _instance = new TimelineHelper._internal();

  factory TimelineHelper() => _instance;

  TimelineHelper._internal();

  /// 根据Location创建或更新Timeline
  Future<int> createOrUpdateTimeline(Location location) async {
    if (location == null) {
      return -1;
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
        return await updateTimeline(lastTimeline);
      } else {
        return await createTimeline(await convertTimeline(location));
      }
    } else {
      return await createTimeline(await convertTimeline(location));
    }
  }

  Future<int> updateTimeline(Timeline timeline) async {
    if (timeline != null) {

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

  /// 创建Timeline
  Future createTimeline(Timeline timeline) async {
    if (timeline != null) {
      Timeline lastTimeline = await queryLastTimeline();
      if (lastTimeline != null) {
        if (lastTimeline.intervalTime < LocationConfig.judgeUsefulLocation) {
          await deleteTimeline(lastTimeline);
        }
      }
      await FlutterOrmPlugin.saveOrm(
          DBManager.tableTimeline, timeline.toJson());
      print("======创建Timeline！");
      return 0;
    }
    return -1;
  }

  /// location转成Timeline
  Future<Timeline> convertTimeline(Location location) async {
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
      timeline.isFromPicture = 0;
      timeline.poiName = "Unknow";
      timeline.sameId = Uuid().v1();
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
        Timeline timeline;
        for (Map map in list) {
          num d = CalculateUtil.calculateLatlngDistance(
              map["lat"] as num, map["lon"] as num, timeline.lat, timeline.lon);
          if (d < distance) {
            distance = d;
            timeline = Timeline.fromJson(Map<String, dynamic>.from(map));
          }
        }
        if (timeline != null) {
          if (distance <= timeline.radius) {
            return timeline;
          }
        }
      }
    }
    return null;
  }

  /// 网络请求下poi并赋值给Timeline
  Future<Timeline> requestPoiData(Timeline timeline) async {
    if (timeline != null) {
      List<AmapPoi> list = await requestAMapPois(
          lat: timeline.lat, lon: timeline.lon, limit: 1, radius: 300);
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
}
