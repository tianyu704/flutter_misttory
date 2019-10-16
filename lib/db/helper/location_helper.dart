import 'dart:convert';
import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/db_manager.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/string_util.dart';

class LocationHelper {
  static final LocationHelper _instance = new LocationHelper._internal();

  factory LocationHelper() => _instance;

  LocationHelper._internal();

  MethodChannel _methodChannel = MethodChannel("com.admqr.misstory");

  ///从Android Realm数据库中读出Location放到Mslocation表中
  Future saveLocation() async {
    if (Platform.isAndroid) {
      String jsonString = await _methodChannel.invokeMethod("query_location");
      if (StringUtil.isNotEmpty(jsonString)) {
        List items = json.decode(jsonString);
        debugPrint("---->${items.length}个位置信息");
        for (Map item in items) {
          Mslocation mslocation =
              Mslocation.fromJson(Map<String, dynamic>.from(item));
          await createOrUpdateLocation(mslocation);
        }
      }
    }
  }

  /// 根据最新定位的Location创建或更新最后一条Location
  Future<int> createOrUpdateLocation(Mslocation location) async {
    if (location != null && location.errorCode == 0) {
      Mslocation lastLocation = await queryLastLocation();
      if (lastLocation == null) {
        return await createLocation(location);
      } else if (lastLocation.lon == location.lon &&
          lastLocation.lat == location.lat) {
        return await updateLocationTime(lastLocation.id, location);
      } else {
        if (lastLocation.aoiname == location.aoiname) {
          if (location.aoiname == null &&
              lastLocation.poiname != location.poiname) {
            return await createLocation(location);
          } else {
            if (await getDistanceBetween(location, lastLocation) >
                LocationConfig.judgeDistanceNum) {
              return await createLocation(location);
            } else {
              return await updateLocationTime(lastLocation.id, location);
            }
          }
        } else if (lastLocation.poiname == location.poiname) {
          if (await getDistanceBetween(location, lastLocation) >
              LocationConfig.judgeDistanceNum) {
            return await createLocation(location);
          } else {
            return await updateLocationTime(lastLocation.id, location);
          }
        } else {
          return await createLocation(location);
        }
      }
    }
    return -1;
  }

  /// 创建Location一条记录
  Future<int> createLocation(Mslocation location) async {
    if (location != null && location.lat != 0 && location.lon != 0) {
      await FlutterOrmPlugin.saveOrm(
          DBManager.tableLocation, location.toJson());
      return 0;
    }
    return -1;
  }

  /// 更新Location时间
  Future<int> updateLocationTime(num id, Mslocation location) async {
    if (location != null) {
      await Query(DBManager.tableLocation)
          .primaryKey([id]).update({"updatetime": location.updatetime});
      return 0;
    }
    return -1;
  }

  /// 读取库中的全部数据
  Future<List> findAllLocations() async {
    List result = await Query(DBManager.tableLocation).all();
    if (result != null && result.length > 0) {
      List<Mslocation> list = [];
      result.reversed.forEach((item) =>
          list.add(Mslocation.fromJson(Map<String, dynamic>.from(item))));
      return list;
    }
    return null;
  }

  /// 查询最后一条Location
  Future<Mslocation> queryLastLocation() async {
    Map result = await Query(DBManager.tableLocation).orderBy([
      "time desc",
    ]).first();
    if (result != null && result.length > 0) {
      return Mslocation.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  ///把库中的数据生成story，根据最后一条story的updateTime以后的数据生成
  Future<void> createStoryByLocation() async {
    num time = 0;
    Story lastStory = await StoryHelper().queryLastStory();
    if (lastStory != null) {
      time = lastStory.createTime;
    }
    List result = await Query(DBManager.tableLocation)
        .orderBy(["time"]).whereByColumFilters([
      WhereCondiction("time", WhereCondictionType.EQ_OR_MORE_THEN, time)
    ]).all();
    if (result != null && result.length > 0) {
      debugPrint("===========待更新条数${result.length}");
      Mslocation mslocation;
      for (num i = 0; i < result.length; i++) {
        mslocation = Mslocation.fromJson(Map<String, dynamic>.from(result[i]));
        if (mslocation?.updatetime == null) {
          mslocation.updatetime = mslocation.time;
        }
        if (mslocation.updatetime - mslocation.time >=
            LocationConfig.judgeUsefulLocation) {
          debugPrint("=================start judge location");
          await StoryHelper().judgeLocation(mslocation);
        }
      }
      debugPrint("=================Create Story By Location Finish");
    }
  }

  ///求值：两个坐标点的距离
  Future<double> getDistanceBetween(
      Mslocation location1, Mslocation location2) async {
    LatLng latLng1 = LatLng(location1.lat, location1.lon);
    LatLng latLng2 = LatLng(location2.lat, location2.lon);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }
}
