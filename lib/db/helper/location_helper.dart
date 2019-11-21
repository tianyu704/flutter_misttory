import 'dart:convert';
import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/db_manager.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/location.dart' as l;
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/utils/channel_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/models/picture.dart';
import 'package:uuid/uuid.dart';

enum LocationFromType { normal, before, after }

class LocationHelper {
  static final LocationHelper _instance = new LocationHelper._internal();

  factory LocationHelper() => _instance;

  LocationHelper._internal();

  ReGeocodeResult reGeocodeResult;
  Picture cachePicture;

  ///从Android Realm数据库中读出Location放到Mslocation表中
  Future saveLocation() async {
    if (Platform.isAndroid) {
      String jsonString = await ChannelUtil().queryLocation();
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

//  ///图片转化为地点
//  Future createLocationWithPicture(Picture p) async {
//    ///TODO：此处过滤掉经纬度为 0的图片
//    if (!(p != null && p.lat != 0 && p.lon != 0)) return 1;
//    //找到Picture拍照时是否处于某个Location内
//    Mslocation targetLocation =
//        await findTargetLocation(p.creationDate, p.creationDate);
//    if (targetLocation != null) {
//      //存在Location就把图片直接放入Location中
//      await updateLocationPictures(targetLocation, p);
//      await StoryHelper().createOrUpdateStory(targetLocation);
//    } else {
//      //找到拍照时间之后的一个Location
//      Mslocation afterLocation = await findAfterLocation(p.creationDate);
//      if (afterLocation != null &&
//          DateUtil.isSameDay(afterLocation.time, p.creationDate) &&
//          await CalculateUtil.calculatePictureDistance(afterLocation, p) <
//              LocationConfig.pictureRadius) {
//        afterLocation.time = p.creationDate;
//        await updateLocationPictures(afterLocation, p);
//        await StoryHelper().createOrUpdateStory(afterLocation);
//      } else {
//        //找到拍照时间之前的一个Location
//        Mslocation beforeLocation = await findBeforeLocation(p.creationDate);
//        if (beforeLocation != null &&
//            DateUtil.isSameDay(beforeLocation.updatetime, p.creationDate) &&
//            await CalculateUtil.calculatePictureDistance(beforeLocation, p) <
//                LocationConfig.pictureRadius) {
//          beforeLocation.updatetime = p.creationDate;
//          await updateLocationPictures(beforeLocation, p);
//          await StoryHelper().createOrUpdateStory(afterLocation);
//        } else {
//          try {
//            if (!(cachePicture != null &&
//                cachePicture.lat == p.lat &&
//                cachePicture.lon == p.lon &&
//                reGeocodeResult != null)) {
//              reGeocodeResult = await _aMapSearch.searchReGeocode(
//                  LatLng(p.lat, p.lon), 300, 1);
//            }
//            cachePicture = p;
//
//            Mslocation mslocation = Mslocation();
//
//            ///latlon
//            mslocation.lat = p.lat;
//            mslocation.lon = p.lon;
//            mslocation.errorCode = 0;
//            mslocation.errorInfo = "success";
//            mslocation.time = p.creationDate;
//            mslocation.updatetime = p.creationDate;
//            mslocation.provider = "lbs";
//
//            ///基于位置服务
//            mslocation.coordType = "WGS84"; //默认WGS84坐标系
//            mslocation.isFromPicture = 1;
//            mslocation.pictures = p.id;
//
//            if (reGeocodeResult == null ||
//                reGeocodeResult.regeocodeAddress == null ||
//                StringUtil.isEmpty(reGeocodeResult.regeocodeAddress.country)) {
//              mslocation = await http.requestLocation(mslocation);
//              if (mslocation == null) {
//                print("p 转 l 获取地理位置失败！！！！");
//                return 1;
//              }
//            } else {
//              ///aoi
//              List<Aoi> aois = reGeocodeResult.regeocodeAddress.aois;
//              if (aois != null && aois.length > 0) {
//                for (Aoi aoi in aois) {
//                  if (StringUtil.isNotEmpty(aoi.aoiName)) {
//                    mslocation.aoiname = aoi.aoiName;
//                    break;
//                  }
//                }
//              }
//
//              ///poi
//              List<PoiItem> pois = reGeocodeResult.regeocodeAddress.pois;
//              if (pois != null && pois.length > 0) {
//                for (PoiItem poi in pois) {
//                  if (StringUtil.isNotEmpty(poi.title)) {
//                    mslocation.poiname = poi.title;
//                    mslocation.poiid = poi.poiId;
//                    break;
//                  }
//                }
//              }
//
//              ///road
//              List<Road> roads = reGeocodeResult.regeocodeAddress.roads;
//              if (roads != null && roads.length > 0) {
//                for (Road road in roads) {
//                  if (StringUtil.isNotEmpty(road.name)) {
//                    mslocation.road = road.name;
//                    break;
//                  }
//                }
//              }
//
//              ///address
//              mslocation.address =
//                  reGeocodeResult.regeocodeAddress.formatAddress;
//              mslocation.country = reGeocodeResult.regeocodeAddress.country;
//              mslocation.citycode = reGeocodeResult.regeocodeAddress.cityCode;
//              mslocation.adcode = reGeocodeResult.regeocodeAddress.adCode;
//              mslocation.province = reGeocodeResult.regeocodeAddress.province;
//              mslocation.city = reGeocodeResult.regeocodeAddress.city;
//              mslocation.district = reGeocodeResult.regeocodeAddress.district;
//
//              mslocation.street =
//                  reGeocodeResult.regeocodeAddress.streetNumber.street;
//              mslocation.number =
//                  reGeocodeResult.regeocodeAddress.streetNumber.number;
//            }
//
//            //location.altitude =
//            //location.speed =
//            //location.bearing =
//            //location.locationType =
//            //location.locationDetail =
//            //location.floor =
//            //location.description =
//            //location.accuracy =
//            //location.isOffset =
//            //location.is_delete =
//            if (afterLocation != null &&
//                afterLocation.poiname == mslocation.poiname &&
//                DateUtil.isSameDay(afterLocation.time, mslocation.time) &&
//                await CalculateUtil.calculateLocationDistance(
//                        afterLocation, mslocation) <
//                    LocationConfig.judgeDistanceNum) {
//              await updateLocationPictures(afterLocation, p);
//            } else {
//              if (beforeLocation != null &&
//                  beforeLocation.poiname == mslocation.poiname &&
//                  DateUtil.isSameDay(beforeLocation.time, mslocation.time) &&
//                  await CalculateUtil.calculateLocationDistance(
//                          beforeLocation, mslocation) <
//                      LocationConfig.judgeDistanceNum) {
//                await updateLocationPictures(afterLocation, p);
//              } else {
////                await createLocation(mslocation);
//              }
//            }
//            await StoryHelper().createOrUpdateStory(mslocation);
//            return 1;
//          } catch (e) {
//            print("p 转 l 获取地理位置失败！！！！$e");
//            return 1;
//          }
//        }
//      }
//    }
//    return 1;
//  }

  /// 根据最新定位的Location创建或更新最后一条Location
  Future<int> createOrUpdateLocation(Mslocation mslocation) async {
    if (mslocation != null && mslocation.errorCode == 0) {
      l.Location location = switchLocation(mslocation);
      l.Location lastLocation = await queryLastLocation();
      if (lastLocation == null ||
          (lastLocation.lat != location.lat &&
              lastLocation.lon != location.lon)) {
        await createLocation(location);
      } else {
        lastLocation.count++;
        await updateLocation(lastLocation);
      }
      return await StoryHelper().createOrUpdateStory(mslocation);
    }
    return -1;
  }

  /// 创建Location一条记录
  Future<int> createLocation(l.Location location) async {
    if (location != null) {
      if (!await existLocation(location)) {
        await FlutterOrmPlugin.saveOrm(
            DBManager.tableLocation, location.toJson());
        return 0;
      }
    }
    return -1;
  }

  Future<bool> existLocation(l.Location location) async {
    List list = await Query(DBManager.tableLocation).whereByColumFilters([
      WhereCondiction("time", WhereCondictionType.IN, [location.time])
    ]).all();
    return (list != null && list.length > 0);
  }

  Future updateLocation(l.Location location) async {
    if (location != null) {
      await Query(DBManager.tableLocation)
          .primaryKey([location.id]).update({"count": location.count});
    }
  }

//  /// 更新Location时间
//  Future<int> updateLocationTime(Mslocation lastLocation, Mslocation location,
//      {Picture picture, LocationFromType itemType}) async {
//    num id = lastLocation.id;
//    if (location != null) {
//      if (picture == null) {
//        await Query(DBManager.tableMSLocation)
//            .primaryKey([id]).update({"updatetime": location.updatetime});
//      } else {
//        String str;
//        if (StringUtil.isEmpty(lastLocation.pictures)) {
//          str = "${picture.id}";
//        } else {
//          str = "${lastLocation.pictures},${picture.id}";
//        }
//        lastLocation.pictures = str;
//        location.pictures = str;
//
//        ///为了更新story的pictures
//        num startTime = (location.time < lastLocation.time)
//            ? location.time
//            : lastLocation.time;
//        num updateTime = (location.updatetime > lastLocation.updatetime)
//            ? location.updatetime
//            : lastLocation.updatetime;
//        lastLocation.time = startTime;
//        lastLocation.updatetime = updateTime;
//        await Query(DBManager.tableMSLocation).primaryKey([id]).update(
//            {"time": startTime, "updatetime": updateTime, "pictures": str});
//        await StoryHelper().judgeLocation(lastLocation, itemType: itemType);
//        print("xxXX");
//        await PictureHelper().updatePictureStatus(picture);
//      }
//      debugPrint("执行p 转 l中 更新l。。。。。$itemType");
//      return 0;
//    }
//    return -1;
//  }

//  /// 更新Location
//  Future<int> updateLocationPictures(
//      Mslocation location, Picture picture) async {
//    if (location != null && picture != null) {
//      if (StringUtil.isEmpty(location.pictures)) {
//        location.pictures = picture.id;
//      } else {
//        location.pictures = "${location.pictures},${picture.id}";
//      }
//      await Query(DBManager.tableMSLocation).primaryKey([location.id]).update({
//        "pictures": location.pictures,
//        "time": location.time,
//        "updatetime": location.updatetime
//      });
//      return 1;
//    }
//    return 0;
//  }

  /// 查询最后一条Location
  Future<l.Location> queryLastLocation() async {
    Map result = await Query(DBManager.tableLocation).orderBy([
      "time desc",
    ]).first();
    if (result != null && result.length > 0) {
      return l.Location.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

//  /// 查询最早一条Location
//  Future<Mslocation> queryOldestLocation() async {
//    Map result = await Query(DBManager.tableLocation).orderBy([
//      "time asc",
//    ]).whereByColumFilters([
//      WhereCondiction("errorCode", WhereCondictionType.IN, [0])
//    ]).first();
//    if (result != null && result.length > 0) {
//      return Mslocation.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

//  ///把库中的数据生成story，根据最后一条story的updateTime以后的数据生成
//  Future<void> createStoryByLocation() async {
//    num time = 0;
//    Story lastStory = await StoryHelper().queryLastStory();
//    if (lastStory != null) {
//      time = lastStory.createTime;
//    }
//    List result = await Query(DBManager.tableMSLocation)
//        .orderBy(["time"]).whereByColumFilters([
//      WhereCondiction("time", WhereCondictionType.EQ_OR_MORE_THEN, time),
//    ]).all();
//    if (result != null && result.length > 0) {
//      debugPrint("===========待更新条数${result.length}");
//      Mslocation mslocation;
//      for (num i = 0; i < result.length; i++) {
//        mslocation = Mslocation.fromJson(Map<String, dynamic>.from(result[i]));
//        if (mslocation?.updatetime == null) {
//          mslocation.updatetime = mslocation.time;
//        }
//        if (mslocation.updatetime - mslocation.time >=
//                LocationConfig.judgeUsefulLocation ||
//            mslocation.isFromPicture == 1) {
//          debugPrint("=================start judge location");
//          await StoryHelper().createOrUpdateStory(mslocation);
//        }
//      }
//      debugPrint("=================Create Story By Location Finish");
//    }
//  }

//  ///根据Picture查找对应Location
//  Future<Mslocation> findTargetLocationWithPicture(
//      Mslocation mslocation) async {
//    if (mslocation == null) {
//      return null;
//    }
//    Map result = await Query(DBManager.tableLocation).orderBy([
//      "time",
//    ]).whereByColumFilters([
//      WhereCondiction(
//          "time", WhereCondictionType.EQ_OR_LESS_THEN, mslocation.time),
//      WhereCondiction(
//          "updatetime", WhereCondictionType.EQ_OR_MORE_THEN, mslocation.time),
//      WhereCondiction("is_deleted", WhereCondictionType.NOT_IN, [1])
//    ]).first();
//
//    if (result != null && result.length > 0) {
//      return Mslocation.fromJson(Map<String, dynamic>.from(result));
//    } else {
//      Map r = await Query(DBManager.tableLocation)
//          .orderBy(["time desc"]).whereByColumFilters([
//        WhereCondiction(
//            "time", WhereCondictionType.EQ_OR_LESS_THEN, mslocation.time),
//        WhereCondiction("is_deleted", WhereCondictionType.NOT_IN, [1])
//      ]).first();
//      if (r != null) {
//        return Mslocation.fromJson(Map<String, dynamic>.from(r));
//      }
//    }
//    return null;
//  }

//  ///根据Picture查找对应Location
//  Future<Mslocation> findTargetLocation(num startTime, num endTime) async {
//    Map result = await Query(DBManager.tableMSLocation).orderBy([
//      "time",
//    ]).whereByColumFilters([
//      WhereCondiction("time", WhereCondictionType.EQ_OR_LESS_THEN, startTime),
//      WhereCondiction(
//          "updatetime", WhereCondictionType.EQ_OR_MORE_THEN, endTime),
//    ]).first();
//
//    if (result != null && result.length > 0) {
//      return Mslocation.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

//  ///根据time查找对应Location
//  Future<Mslocation> findAfterLocation(num time) async {
//    Map result = await Query(DBManager.tableMSLocation).orderBy([
//      "time",
//    ]).whereByColumFilters([
//      WhereCondiction("time", WhereCondictionType.EQ_OR_MORE_THEN, time)
//    ]).first();
//
//    if (result != null && result.length > 0) {
//      return Mslocation.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

//  ///根据time查找对应Location
//  Future<Mslocation> findBeforeLocation(num time) async {
//    Map result = await Query(DBManager.tableMSLocation).orderBy([
//      "updatetime desc",
//    ]).whereByColumFilters([
//      WhereCondiction("updatetime", WhereCondictionType.EQ_OR_LESS_THEN, time)
//    ]).first();
//
//    if (result != null && result.length > 0) {
//      return Mslocation.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

//  ///求值：两个坐标点的距离
//  Future<double> getDistanceBetween(
//      Mslocation location1, Mslocation location2) async {
//    LatLng latLng1 = LatLng(location1.lat, location1.lon);
//    LatLng latLng2 = LatLng(location2.lat, location2.lon);
//    return await CalculateTools().calcDistance(latLng1, latLng2);
//  }

//  ///删除指定的Location 状态删除
//  Future deleteTargetLocationWithTime(num startTime, num endTime) async {
//    await Query(DBManager.tableLocation).whereByColumFilters([
//      WhereCondiction("time", WhereCondictionType.EQ_OR_MORE_THEN, startTime),
//      WhereCondiction(
//          "updatetime", WhereCondictionType.EQ_OR_LESS_THEN, endTime)
//    ]).update({"is_deleted": 1});
//  }

  ///删除图片生成的位置信息
  Future deletePictureLocation() async {
//    await Query(DBManager.tableLocation)
//        .whereByColumFilters(
//        [WhereCondiction("isFromPicture", WhereCondictionType.IN, [1])])
//        .delete();
    await Query(DBManager.tableMSLocation)
        .whereBySql("isFromPicture = ?", [1]).delete();
    await Query(DBManager.tableMSLocation).update({"pictures": ""});
    print("-------删除Picture生成的Location成功");
  }

  Future separateOldLocation() async {
    List result = await Query(DBManager.tableMSLocation)
        .orderBy(["time"]).whereByColumFilters([
      WhereCondiction("isFromPicture", WhereCondictionType.IS_NULL, true)
    ]).all();
    if (result != null && result.length > 0) {
      Mslocation mslocation;
      for (Map map in result) {
        mslocation = Mslocation.fromJson(Map<String, dynamic>.from(map));
        if (mslocation.time == mslocation.updatetime) {
          await createLocation(switchLocation(mslocation));
        } else {
          await createLocation(switchLocation(mslocation));
          await createLocation(
              switchLocation(mslocation, time: mslocation.updatetime));
        }
      }
    }
  }

  ///清除Location表
  Future clearLocation() async {
    await Query(DBManager.tableLocation).delete();
  }

  /// 转换Mslocation
  l.Location switchLocation(Mslocation mslocation, {num time}) {
    if (mslocation != null) {
      return l.Location()
        ..id = Uuid().v1()
        ..time = time ?? mslocation.time
        ..lat = mslocation.lat
        ..lon = mslocation.lon
        ..altitude = mslocation.altitude ?? 0
        ..accuracy = mslocation.accuracy ?? 0
        ..verticalAccuracy = 0
        ..speed = mslocation.speed ?? 0
        ..bearing = mslocation.bearing ?? 0
        ..count = 1
        ..coordType = mslocation.coordType;
    }
    return null;
  }

  Future createStoryByOldLocation() async {
    List result =
        await Query(DBManager.tableMSLocation).orderBy(["time"]).all();
    if (result != null && result.length > 0) {
      Mslocation mslocation;
      result.forEach((map) {
        mslocation = Mslocation.fromJson(Map<String, dynamic>.from(map));
        StoryHelper().createOrUpdateStory(mslocation);
      });
    }
  }

  Future updateCount() async {
    List result = await Query(DBManager.tableLocation).needColums(["id"]).all();
    if (result != null && result.length > 0) {
      for (Map map in result) {
        await Query(DBManager.tableStory)
            .primaryKey([map["id"]]).update({"count": 1});
      }
    }
  }

  Future<List<Latlonpoint>> queryPoints(num startTime, num endTime) async {
    List result = await Query(DBManager.tableLocation).whereByColumFilters([
      WhereCondiction("time", WhereCondictionType.EQ_OR_MORE_THEN, startTime),
      WhereCondiction("time", WhereCondictionType.EQ_OR_LESS_THEN, endTime),
    ]).all();
    if (result != null && result.length > 0) {
      List<Latlonpoint> list = [];
      int count;
      num lat, lon;
      for (Map map in result) {
//        count = (map["count"] as num).toInt();
        lat = map["lat"] as num;
        lon = map["lon"] as num;
//        for (int i = 0; i < count; i++) {
          list.add(Latlonpoint(lat, lon));
//        }
      }
      return list;
    }
    return null;
  }
}
