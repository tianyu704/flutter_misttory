import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/timeline_helper.dart';
import 'package:misstory/models/amap_poi.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/location.dart';
import 'package:misstory/models/poilocation.dart';
import 'package:misstory/utils/location_channel.dart';
import 'package:misstory/utils/print_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/net/http_manager.dart';
import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-20
///
class LocationDBHelper {
  static final LocationDBHelper _instance = new LocationDBHelper._internal();

  factory LocationDBHelper() => _instance;

  LocationDBHelper._internal();

  /// 创建Location一条记录
  Future<int> createLocation(Location location) async {
    if (location != null) {
      if (!await existLocation(location)) {
        await FlutterOrmPlugin.saveOrm(
            DBManager.tableLocation, location.toJson());
        return 0;
      }
    }
    return -1;
  }

  ///库中是否存在当前location时间的location
  Future<bool> existLocation(Location location) async {
    List list = await Query(DBManager.tableLocation).whereByColumFilters([
      WhereCondiction("time", WhereCondictionType.IN, [location.time])
    ]).all();
    return (list != null && list.length > 0);
  }

  /// 查询最后一条Location
  Future<Location> queryLastLocation() async {
    Map result = await Query(DBManager.tableLocation).orderBy([
      "time desc",
    ]).first();
    if (result != null && result.length > 0) {
      return Location.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///处理新的定位点
  Future saveNewLocation(Location location) async {
    ///每次获取到新定位时，Android先检查原生数据库中数据再处理本次的数据
    if (Platform.isAndroid) {
      String jsonString = await LocationChannel().queryLocationData();
      if (StringUtil.isNotEmpty(jsonString)) {
        List items = json.decode(jsonString);
        debugPrint("---->${items.length}个原生位置信息");
        for (Map item in items) {
          Location l = Location.fromJson(Map<String, dynamic>.from(item));
          await createLocation(l);
        }
      }
    }
    await createLocation(location);
    ///查出需要处理的location
    List<Location> locations = await queryUnCreateLocation();
    debugPrint("---->${locations?.length}个位置信息");
    if (locations != null && locations.length > 0) {
      for (Location l in locations) {
        await saveLocation(l);
      }
    }
    return 0;
  }

  ///根据location创建timeline，处理成功后更新location的timelineId
  Future saveLocation(Location location) async {
    if (location != null) {
//      int result = await createLocation(location);
//      if (result == 0) {
      String timelineId =
          await TimelineHelper().createOrUpdateTimeline(location);
      if (StringUtil.isNotEmpty(timelineId)) {
        location.timelineId = timelineId;
        await updateLocationTimelineId(location);
      }
//      }
    }
  }
  ///查找没有创建timeline的location
  Future<List<Location>> queryUnCreateLocation() async {
    List result = await Query(DBManager.tableLocation)
        .orderBy(["time"]).whereByColumFilters([
      WhereCondiction("timeline_id", WhereCondictionType.IS_NULL, true)
    ]).all();
    if (result != null && result.length > 0) {
      List<Location> list = [];
      for (Map map in result) {
        list.add(Location.fromJson(Map<String, dynamic>.from(map)));
      }
      return list;
    }
    return null;
  }

  ///更新timeline_id
  Future updateLocationTimelineId(Location location) async {
    await Query(DBManager.tableLocation)
        .primaryKey([location.id]).update({"timeline_id": location.timelineId});
  }

  ///更新timeline_id
  Future updateLocationsTimelineId(String oldId, String newId) async {
    await Query(DBManager.tableLocation).whereByColumFilters([
      WhereCondiction("timeline_id", WhereCondictionType.IN, [oldId])
    ]).update({"timeline_id": newId});
  }

  Future<List<Latlonpoint>> queryPoints(String timelineId) async {
    List result = await Query(DBManager.tableLocation).whereByColumFilters([
      WhereCondiction("timeline_id", WhereCondictionType.IN, [timelineId]),
    ]).all();
    if (result != null && result.length > 0) {
      List<Latlonpoint> list = [];
      num lat, lon;
      for (Map map in result) {
        lat = map["lat"] as num;
        lon = map["lon"] as num;
        list.add(Latlonpoint(lat, lon));
      }
      return list;
    }
    return [];
  }

  /// 查找parent id相同的Location
  Future<List<Location>> queryLocationsWithTimelineId(String timeLineId) async {
    List list = await Query(DBManager.tableLocation).whereByColumFilters([
      WhereCondiction("timeline_id", WhereCondictionType.IN, [timeLineId])
    ]).orderBy(["time desc"]).all();
    if (list != null && list.length > 0) {
      List<Location> locations = [];
      for (Map map in list) {
        locations.add(Location.fromJson(Map<String, dynamic>.from(map)));
      }
      return locations;
    }
    return null;
  }

  ///把location重新依次生成timeline
  Future convertAllLocationToTimeline(void progress(String s)) async {
    List list = await Query(DBManager.tableLocation).orderBy(["time"]).all();
    if (list != null && list.length > 0) {
      Location location;
      int i = 0;
      for (Map map in list) {
        location = Location.fromJson(Map<String, dynamic>.from(map));
        String timelineId =
            await TimelineHelper().createOrUpdateTimeline(location);
        if (StringUtil.isNotEmpty(timelineId)) {
          location.timelineId = timelineId;
          await updateLocationTimelineId(location);
        }
        i++;
        progress("$i/${list.length}");
      }
      location = Location.fromJson(Map<String, dynamic>.from(list[0]));
      await PictureHelper().checkUnSyncedPicture(time: location.time);
    }
  }

  Future<List<Location>> queryLocationsBetweenTime(
      num startTime, num endTime) async {
    List list = await Query(DBManager.tableLocation)
        .orderBy(["time desc"]).whereByColumFilters([
      WhereCondiction("time", WhereCondictionType.MORE_THEN, startTime),
      WhereCondiction("time", WhereCondictionType.LESS_THEN, endTime),
    ]).all();
    if (list != null && list.length > 0) {
      List<Location> locations = [];
      for (Map map in list) {
        locations.add(Location.fromJson(Map<String, dynamic>.from(map)));
      }
      return locations;
    }
    return null;
  }
}
