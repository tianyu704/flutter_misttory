import 'dart:convert';
import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/db_manager.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/models/picture.dart';
import 'package:amap_base/src/search/model/poi_item.dart';

enum LocationFromType { normal, before, after }

class LocationHelper {
  static final LocationHelper _instance = new LocationHelper._internal();

  factory LocationHelper() => _instance;

  LocationHelper._internal();

  static final AMapSearch _aMapSearch = AMapSearch();

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

  ///图片转化为地点,isNoneUseBefore没有使用以前的
  createLocationWithPicture(Picture p, bool isNoneUseBefore) async {
    ///TODO：此处过滤掉经纬度为 0的图片
    if (!(p != null && p.lat != 0 && p.lon != 0)) return 1;

    Mslocation location = Mslocation();

    ///latlon
    location.lat = p.lat;
    location.lon = p.lon;

    ReGeocodeResult result =
        await _aMapSearch.searchReGeocode(LatLng(p.lat, p.lon), 300, 1);
    print(result.toJson());

    ///aoi
    List<Aoi> aois = result.regeocodeAddress.aois;
    if (aois != null && aois.length > 0) {
      for (Aoi aoi in aois) {
        if (StringUtil.isNotEmpty(aoi.aoiName)) {
          location.aoiname = aoi.aoiName;
          break;
        }
      }
    }

    ///poi
    List<PoiItem> pois = result.regeocodeAddress.pois;
    if (pois != null && pois.length > 0) {
      for (PoiItem poi in pois) {
        if (StringUtil.isNotEmpty(poi.title)) {
          location.poiname = poi.title;
          location.poiid = poi.poiId;
          break;
        }
      }
    }

    ///road
    List<Road> roads = result.regeocodeAddress.roads;
    if (roads != null && roads.length > 0) {
      for (Road road in roads) {
        if (StringUtil.isNotEmpty(road.name)) {
          location.road = road.name;
          break;
        }
      }
    }

    ///address
    location.address = result.regeocodeAddress.formatAddress;
    location.country = result.regeocodeAddress.country;
    location.citycode = result.regeocodeAddress.cityCode;
    location.adcode = result.regeocodeAddress.adCode;
    location.province = result.regeocodeAddress.province;
    location.city = result.regeocodeAddress.city;
    location.district = result.regeocodeAddress.district;

    location.street = result.regeocodeAddress.streetNumber.street;
    location.number = result.regeocodeAddress.streetNumber.number;
    location.errorCode = 0;
    location.errorInfo = "success";
    location.time = p.creationDate;
    location.updatetime = p.creationDate;
    location.provider = "lbs";

    ///基于位置服务
    location.coordType = "WGS84"; //默认WGS84坐标系
    location.isFromPicture = 1;

    //location.altitude =
    //location.speed =
    //location.bearing =
    //location.locationType =
    //location.locationDetail =
    //location.floor =
    //location.description =
    //location.accuracy =
    //location.isOffset =
    //location.is_delete =
    return await createOrUpdateLocation(location,
        picture: p,
        itemType:
            isNoneUseBefore ? LocationFromType.before : LocationFromType.after);
  }

  /// 根据最新定位的Location创建或更新最后一条Location
  Future<int> createOrUpdateLocation(Mslocation location,
      {Picture picture, LocationFromType itemType}) async {
//    if (picture!= null && LocationFromType.after == itemType) {
//      print("after start to creat or update location");
//      Mslocation updateLocation = await findTargetLocationWithPicture(picture);
//      if (updateLocation == null) {
//        return await createLocation(location,picture: picture,itemType:LocationFromType.after);
//      } else {
//        print("location 更新");
//        return await updateLocationTime(updateLocation, location,picture: picture,itemType:LocationFromType.after);
//      }
//    }

    ///TODO:最大的一张图片比最大的location时间大的情况还没考虑

    if (location != null && location.errorCode == 0) {
      Mslocation lastLocation;
      if (LocationFromType.before == itemType) {
        lastLocation = await queryOldestLocation();
        if (lastLocation != null &&
            !DateUtil.isSameDay(lastLocation.time, location.time)) {
          return await createLocation(location,
              picture: picture, itemType: itemType);
        }
      } else if (LocationFromType.after == itemType) {
        lastLocation = await findTargetLocationWithPicture(location);
        if (lastLocation == null) {
          lastLocation = await queryLastLocation();
          if (lastLocation.updatetime > location.time) {
            lastLocation = null;
          }
        }
      } else {
        lastLocation = await queryLastLocation();
        if (lastLocation.isFromPicture == 1) {
          return await createLocation(location);
        }
      }
      if (lastLocation == null) {
        return await createLocation(location,
            picture: picture, itemType: itemType);
      } else if (lastLocation.lon == location.lon &&
          lastLocation.lat == location.lat) {
        return await updateLocationTime(lastLocation, location,
            picture: picture, itemType: itemType);
      } else {
        if (lastLocation.aoiname == location.aoiname) {
          if (location.aoiname == null &&
              lastLocation.poiname != location.poiname) {
            return await createLocation(location,
                picture: picture, itemType: itemType);
          } else {
            if (await getDistanceBetween(location, lastLocation) >
                LocationConfig.judgeDistanceNum) {
              return await createLocation(location,
                  picture: picture, itemType: itemType);
            } else {
              return await updateLocationTime(lastLocation, location,
                  picture: picture, itemType: itemType);
            }
          }
        } else if (lastLocation.poiname == location.poiname) {
          if (await getDistanceBetween(location, lastLocation) >
              LocationConfig.judgeDistanceNum) {
            return await createLocation(location,
                picture: picture, itemType: itemType);
          } else {
            return await updateLocationTime(lastLocation, location,
                picture: picture, itemType: itemType);
          }
        } else {
          return await createLocation(location,
              picture: picture, itemType: itemType);
        }
      }
    }
    return -1;
  }

  /// 创建Location一条记录
  Future<int> createLocation(Mslocation location,
      {Picture picture,
      LocationFromType itemType = LocationFromType.normal}) async {
    if (location != null && location.lat != 0 && location.lon != 0) {
      if (picture != null) {
        location.pictures = "${picture.id}";
        location.isFromPicture = 1;
      }
      print("===$location==");
      await FlutterOrmPlugin.saveOrm(
          DBManager.tableLocation, location.toJson());
      if (picture != null) {
        await StoryHelper().judgeLocation(location, itemType: itemType);
        await PictureHelper().updatePictureStatus(picture);
      }
      debugPrint("执行p 转 l中 创建l。。。$itemType。。");
      return 0;
    }
    return -1;
  }

  /// 更新Location时间
  Future<int> updateLocationTime(Mslocation lastLocation, Mslocation location,
      {Picture picture, LocationFromType itemType}) async {
    num id = lastLocation.id;
    if (location != null) {
      if (picture == null) {
        await Query(DBManager.tableLocation)
            .primaryKey([id]).update({"updatetime": location.updatetime});
      } else {
        String str;
        if (StringUtil.isEmpty(lastLocation.pictures)) {
          str = "${picture.id}";
        } else {
          str = "${lastLocation.pictures},${picture.id}";
        }
        lastLocation.pictures = str;
        location.pictures = str;

        ///为了更新story的pictures
        num startTime = (location.time < lastLocation.time)
            ? location.time
            : lastLocation.time;
        num updateTime = (location.updatetime > lastLocation.updatetime)
            ? location.updatetime
            : lastLocation.updatetime;
        lastLocation.time = startTime;
        lastLocation.updatetime = updateTime;
        await Query(DBManager.tableLocation).primaryKey([id]).update(
            {"time": startTime, "updatetime": updateTime, "pictures": str});
        await StoryHelper().judgeLocation(lastLocation, itemType: itemType);
        print("xxXX");
        await PictureHelper().updatePictureStatus(picture);
      }
      debugPrint("执行p 转 l中 更新l。。。。。$itemType");
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

  /// 查询最早一条Location
  Future<Mslocation> queryOldestLocation() async {
    Map result = await Query(DBManager.tableLocation).orderBy([
      "time asc",
    ]).whereByColumFilters([
      WhereCondiction("errorCode", WhereCondictionType.IN, [0])
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
      WhereCondiction("time", WhereCondictionType.EQ_OR_MORE_THEN, time),
      WhereCondiction("isFromPicture", WhereCondictionType.IS_NULL, true)
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
                LocationConfig.judgeUsefulLocation ||
            mslocation.isFromPicture == 1) {
          debugPrint("=================start judge location");
          await StoryHelper().judgeLocation(mslocation);
        }
      }
      debugPrint("=================Create Story By Location Finish");
    }
  }

  ///根据Picture查找对应Location
  Future<Mslocation> findTargetLocationWithPicture(
      Mslocation mslocation) async {
    if (mslocation == null) {
      return null;
    }
    Map result = await Query(DBManager.tableLocation).orderBy([
      "time",
    ]).whereByColumFilters([
      WhereCondiction(
          "time", WhereCondictionType.EQ_OR_LESS_THEN, mslocation.time),
      WhereCondiction(
          "updatetime", WhereCondictionType.EQ_OR_MORE_THEN, mslocation.time),
    ]).first();

    if (result != null && result.length > 0) {
      return Mslocation.fromJson(Map<String, dynamic>.from(result));
    } else {
      Map r = await Query(DBManager.tableLocation)
          .orderBy(["time desc"]).whereByColumFilters([
        WhereCondiction(
            "time", WhereCondictionType.EQ_OR_LESS_THEN, mslocation.time)
      ]).first();
      if (r != null) {
        return Mslocation.fromJson(Map<String, dynamic>.from(r));
      }
    }
    return null;
  }

  ///求值：两个坐标点的距离
  Future<double> getDistanceBetween(
      Mslocation location1, Mslocation location2) async {
    LatLng latLng1 = LatLng(location1.lat, location1.lon);
    LatLng latLng2 = LatLng(location2.lat, location2.lon);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }

  ///删除图片生成的位置信息
  Future deletePictureLocation() async {
//    await Query(DBManager.tableLocation)
//        .whereByColumFilters(
//        [WhereCondiction("isFromPicture", WhereCondictionType.IN, [1])])
//        .delete();
    await Query(DBManager.tableLocation)
        .whereBySql("isFromPicture = ?", [1]).delete();
    print("-------删除Picture生成的Location成功");
  }
}
