import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/eventbus/event_bus_util.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/picture.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/calculate_util.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/net/http_manager.dart' as http;
import 'package:misstory/utils/string_util.dart';
import 'package:amap_base/src/search/model/poi_item.dart';
import '../../location_config.dart';
import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-18
///
class PictureHelper {
  static final PictureHelper _instance = PictureHelper._internal();

  factory PictureHelper() => _instance;

  PictureHelper._internal();

  bool isPictureConverting = false;
  final AMapSearch _aMapSearch = AMapSearch();
  ReGeocodeResult reGeocodeResult;
  Picture cachePicture;

  /// 检查系统相库有没有新增照片，有的话放入数据库中
  checkSystemPicture() async {
    num start = DateTime.now().millisecondsSinceEpoch;
    Map date = await queryLastPictureDate();
    num startTime = 0;
    if (date != null && date.length > 0) {
      startTime = date["creationDate"] as num;
    }
    await LocalImageProvider().initialize();
    List<LocalImage> list =
        await LocalImageProvider().findAfterTime(time: startTime);
    if (list != null && list.length > 0) {
      for (LocalImage image in list) {
        await createPicture(createPictureModelWithLocalImage(image));
      }
    }
    debugPrint(
        "存储完Picture表，${list?.length ?? 0}条用时${DateTime.now().millisecondsSinceEpoch - start}毫秒");
  }

  /// 检查没有转换成地点的Picture
  checkUnSyncedPicture() async {
    isPictureConverting = true;
    num start = DateTime.now().millisecondsSinceEpoch;
    List<Picture> pictures = await queryUnSyncedPictures();
    if (pictures != null && pictures.length > 0) {
      num total = pictures.length;
      num progress = 0;
      for (Picture picture in pictures) {
        await createStoryWithPicture(picture);
        await updatePictureStatus(picture);
        progress++;
        if (total > progress) {
          EventBusUtil.fireRefreshProgress(total, progress);
        }
      }
      EventBusUtil.fireRefreshProgress(total, total);
    } else {
      EventBusUtil.fireRefreshProgress(100, 100);
    }
    isPictureConverting = false;
    debugPrint(
        "Picture转Location完成，${pictures?.length ?? 0}条用时${DateTime.now().millisecondsSinceEpoch - start}毫秒");
  }

  ///图片转化为地点
  Future createStoryWithPicture(Picture p) async {
    ///TODO：此处过滤掉经纬度为 0的图片
    if (!(p != null && p.lat != 0 && p.lon != 0)) return 1;
    //找到Picture拍照时是否处于某个Story内
    Story targetStory =
        await StoryHelper().findTargetStory(p.creationDate, p.creationDate);
    if (targetStory != null) {
      //存在Story就把图片story_id赋值uuid
      await updatePictureStoryUuid(p.id, targetStory.uuid);
    } else {
      //找到拍照时间之后的一个Story
      Story afterStory = await StoryHelper().findAfterStory(p.creationDate);
      if (afterStory != null &&
          DateUtil.isSameDay(afterStory.createTime, p.creationDate) &&
          await CalculateUtil.calculatePictureDistance(afterStory, p) <
              afterStory.radius) {
        afterStory.createTime = p.creationDate;
        await updatePictureStoryUuid(p.id, afterStory.uuid);
        await StoryHelper().updateStoryTimes(afterStory);
      } else {
        //找到拍照时间之前的一个Story
        Story beforeStory = await StoryHelper().findBeforeStory(p.creationDate);
        if (beforeStory != null &&
            DateUtil.isSameDay(beforeStory.updateTime, p.creationDate) &&
            await CalculateUtil.calculatePictureDistance(beforeStory, p) <
                beforeStory.radius) {
          beforeStory.updateTime = p.creationDate;
          await updatePictureStoryUuid(p.id, beforeStory.uuid);
          await StoryHelper().updateStoryTimes(beforeStory);
        } else {
          try {
            if (!(cachePicture != null &&
                cachePicture.lat == p.lat &&
                cachePicture.lon == p.lon &&
                reGeocodeResult != null)) {
              reGeocodeResult = await _aMapSearch.searchReGeocode(
                  LatLng(p.lat, p.lon), 300, 1);
            }
            cachePicture = p;

            Mslocation mslocation = Mslocation();

            ///latlon
            mslocation.lat = p.lat;
            mslocation.lon = p.lon;
            mslocation.errorCode = 0;
            mslocation.errorInfo = "success";
            mslocation.time = p.creationDate;
            mslocation.updatetime = p.creationDate;
            mslocation.provider = "lbs";
            mslocation.accuracy = LocationConfig.pictureRadius;

            ///基于位置服务
            mslocation.coordType = "WGS84"; //默认WGS84坐标系
            mslocation.isFromPicture = 1;
            mslocation.pictures = p.id;

            if (!isInChina(reGeocodeResult)) {
              mslocation = await http.requestLocation(mslocation);
              if (mslocation == null) {
                print("p 转 l 获取地理位置失败！！！！");
                return 1;
              }
            } else {
              ///aoi
              List<Aoi> aois = reGeocodeResult.regeocodeAddress.aois;
              if (aois != null && aois.length > 0) {
                for (Aoi aoi in aois) {
                  if (StringUtil.isNotEmpty(aoi.aoiName)) {
                    mslocation.aoiname = aoi.aoiName;
                    break;
                  }
                }
              }

              ///poi
              List<PoiItem> pois = reGeocodeResult.regeocodeAddress.pois;
              if (pois != null && pois.length > 0) {
                for (PoiItem poi in pois) {
                  if (StringUtil.isNotEmpty(poi.title)) {
                    mslocation.poiname = poi.title;
                    mslocation.poiid = poi.poiId;
                    break;
                  }
                }
              }

              ///road
              List<Road> roads = reGeocodeResult.regeocodeAddress.roads;
              if (roads != null && roads.length > 0) {
                for (Road road in roads) {
                  if (StringUtil.isNotEmpty(road.name)) {
                    mslocation.road = road.name;
                    break;
                  }
                }
              }

              ///address
              mslocation.address =
                  reGeocodeResult.regeocodeAddress.formatAddress;
              mslocation.country = reGeocodeResult.regeocodeAddress.country;
              mslocation.citycode = reGeocodeResult.regeocodeAddress.cityCode;
              mslocation.adcode = reGeocodeResult.regeocodeAddress.adCode;
              mslocation.province = reGeocodeResult.regeocodeAddress.province;
              mslocation.city = reGeocodeResult.regeocodeAddress.city;
              mslocation.district = reGeocodeResult.regeocodeAddress.district;

              mslocation.street =
                  reGeocodeResult.regeocodeAddress.streetNumber.street;
              mslocation.number =
                  reGeocodeResult.regeocodeAddress.streetNumber.number;
            }

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
            if (afterStory != null &&
                afterStory.poiName == mslocation.poiname &&
                DateUtil.isSameDay(afterStory.createTime, mslocation.time) &&
                await CalculateUtil.calculateStoryDistance(
                        afterStory, mslocation) <
                    LocationConfig.judgeDistanceNum) {
              afterStory.createTime = p.creationDate;
              await updatePictureStoryUuid(p.id, afterStory.uuid);
              await StoryHelper().updateStoryTimes(afterStory);
            } else {
              if (beforeStory != null &&
                  beforeStory.poiName == mslocation.poiname &&
                  DateUtil.isSameDay(beforeStory.updateTime, mslocation.time) &&
                  await CalculateUtil.calculateStoryDistance(
                          beforeStory, mslocation) <
                      LocationConfig.judgeDistanceNum) {
                beforeStory.updateTime = p.creationDate;
                await updatePictureStoryUuid(p.id, beforeStory.uuid);
                await StoryHelper().updateStoryTimes(beforeStory);
              } else {
                Story story =
                    await StoryHelper().createStoryWithLocation(mslocation);
                await StoryHelper().createStory(story);
                await updatePictureStoryUuid(p.id, story.uuid);
              }
            }
            return 1;
          } catch (e) {
            print("p 转 l 获取地理位置失败！！！！$e");
            return 1;
          }
        }
      }
    }
    return 1;
  }

  bool isInChina(ReGeocodeResult reGeocodeResult) {
    return reGeocodeResult != null &&
        reGeocodeResult.regeocodeAddress != null &&
        (reGeocodeResult.regeocodeAddress.country == "中国" ||
            reGeocodeResult.regeocodeAddress.country == "China") &&
        ((reGeocodeResult.regeocodeAddress.pois?.length ?? 0) > 0 ||
            (reGeocodeResult.regeocodeAddress.aois?.length ?? 0) > 0);
  }

  /// 更新Picture的storyId
  Future updatePictureStoryUuid(String id, String uuid) async {
    await Query(DBManager.tablePicture)
        .primaryKey([id]).update({"story_uuid": uuid});
  }

  /// 更新Picture的storyId
  Future updatePictureUuid(String oldUuid, String uuid) async {
    await Query(DBManager.tablePicture).whereByColumFilters([
      WhereCondiction("story_uuid", WhereCondictionType.IN, [oldUuid])
    ]).update({"story_uuid": uuid});
  }

//  fetchAppSystemPicture() async {
//    List picList = await queryPictureConverted();
//
//    Picture beforeP =
//        picList != null && picList.length > 0 ? picList.last : null;
//    Picture afterP =
//        picList != null && picList.length > 0 ? picList.first : null;
//    num time = 0;
//    if (beforeP != null) {
//      time = beforeP.creationDate;
//    }
//    await LocalImageProvider().initialize();
//    num start = DateTime.now().millisecondsSinceEpoch;
//    List<LocalImage> list = [];
//    List<LocalImage> afterList = [];
//    if (time == 0) {
//      list = await LocalImageProvider().findAfterTime();
//    } else {
//      afterList =
//          await LocalImageProvider().findAfterTime(time: afterP.creationDate);
//      //list =   await LocalImageProvider().findBeforeTime(time: time);
//    }
//    //debugPrint("======查询到${list?.length}张照片，用时${DateTime.now().millisecondsSinceEpoch - start}毫秒");
//    if (afterList != null && afterList.length > 0) {
//      print("===${afterList.length}==${afterP.creationDate}===");
//      for (LocalImage image in afterList) {
//        if (!(await PictureHelper().isExistPictureWithId(image.id))) {
//          await createPicture(createPictureModelWithLocalImage(image));
//        }
//      }
//    }
//    if (list != null && list.length > 0) {
//      for (LocalImage image in list) {
//        if (!(await PictureHelper().isExistPictureWithId(image.id))) {
//          await createPicture(createPictureModelWithLocalImage(image));
//        }
//      }
//    }
//    debugPrint(
//        " 存储完Picture表，用时${DateTime.now().millisecondsSinceEpoch - start}毫秒");
//  }

  Picture createPictureModelWithLocalImage(LocalImage image) {
    Picture p = Picture();

    p.lat = image.lat;
    p.lon = image.lon;
    p.id = image.id;
    p.creationDate = image.creationDate;
    p.pixelHeight = image.pixelHeight;
    p.pixelWidth = image.pixelWidth;
    p.path = image.path;
    p.isSynced = 0;
    //debugPrint("json ：${p.toJson()}");
    return p;
  }

//  Future<Picture> queryPictureById(String id) async {
//    Map result =
//        await Query(DBManager.tablePicture).whereBySql("id = ?", [id]).first();
//    if (result != null) {
//      return Picture.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

  /// 创建Picture 并存库
  Future<bool> createPicture(Picture p) async {
    ///这里无条件存储Picture不做处理
    if (p != null) {
      await FlutterOrmPlugin.saveOrm(DBManager.tablePicture, p.toJson());
      return true;
    }
    return false;
  }

  /// 更新图片同步成location状态
  Future<bool> updatePictureStatus(Picture p) async {
    if (p != null) {
      await Query(DBManager.tablePicture)
          .primaryKey([p.id]).update({"isSynced": 1});
      return true;
    }
    return false;
  }

//  ///按主键查询数据库中是否存在该条数据
//  Future<bool> isExistPictureWithId(String id) async {
//    Map result =
//        await Query(DBManager.tablePicture).whereBySql("id = ?", [id]).first();
//    if (result != null) {
//      return true;
//    }
//    return false;
//  }

//  /// 查询存储在picture表中最早一条数据
//  Future<Picture> queryOldestPicture() async {
//    Map result = await Query(DBManager.tablePicture).orderBy([
//      "creationDate",
//    ]).first();
//    if (result != null && result.length > 0) {
//      return Picture.fromJson(Map<String, dynamic>.from(result));
//    }
//    return null;
//  }

//  ///📌查询并转化picture为location
//  Future<bool> convertPicturesToLocations() async {
//    isPictureConverting = true;
//    debugPrint("开始执行p 转 l");
//    List<Picture> list = await queryPictureConverted();
//    if (list == null || list.length == 0) {
//      Mslocation l = await LocationHelper().queryOldestLocation();
//      num time = (l == null) ? DateTime.now().millisecondsSinceEpoch : l.time;
//      if (l == null) {
//        await convertPicturesBeforeTime(time);
//      } else {
//        await convertPicturesAfterTime(time);
//        await convertPicturesBeforeTime(time);
//      }
//    } else {
//      Picture earliestP = list.last;
//      Picture newestP = list.first;
//      await convertPicturesAfterTime(newestP.creationDate);
//      await convertPicturesBeforeTime(earliestP.creationDate);
//    }
//    debugPrint("结束执行p 转 l！！！！！！！！完成啦！！！！！！！！");
//    isPictureConverting = false;
//    return true;
//  }
//
//  ///使用app后
//  convertPicturesAfterTime(num time) async {
//    List afterList = await findPicturesAfterTime(time);
//    if (afterList != null && afterList.length > 0) {
//      for (Picture p in afterList) {
//        await LocationHelper().createLocationWithPicture(p);
//      }
//    }
//    debugPrint("使用app后数据同步完成location");
//  }
//
//  ///使用app前
//  convertPicturesBeforeTime(num time) async {
//    List beforeList = await findPicturesBeforeTime(time);
//    if (beforeList != null && beforeList.length > 0) {
//      for (Picture p in beforeList) {
//        await LocationHelper().createLocationWithPicture(p);
//      }
//      debugPrint("使用app前数据同步完成location");
//    }
//  }

//  ///📌查询未转化为location的图片集合
//  ///从指定时间到当前的未同步的全部图片集合
//  Future<List> findPicturesAfterTime(num time) async {
//    List result;
//    if (time == 0) {
//      result = await Query(DBManager.tablePicture)
//          .orderBy(["creationDate"]).whereByColumFilters([
//        WhereCondiction("isSynced", WhereCondictionType.IN, [0]),
//      ]).all();
//    } else {
//      result = await Query(DBManager.tablePicture)
//          .orderBy(["creationDate"]).whereByColumFilters([
//        WhereCondiction(
//            "creationDate", WhereCondictionType.EQ_OR_MORE_THEN, time),
//        WhereCondiction("isSynced", WhereCondictionType.IN, [0]),
//      ]).all();
//    }
//    List<Picture> list = [];
//    if (result != null && result.length > 0) {
//      result.forEach((item) {
//        Picture p = Picture.fromJson(Map<String, dynamic>.from(item));
//        list.add(p);
//      });
//      return list;
//    }
//    return null;
//  }

//  ///从最早的到到指定时间的未同步的全部图片集合
//  Future<List> findPicturesBeforeTime(num time) async {
//    if (time == 0) {
//      time = DateTime.now().millisecondsSinceEpoch;
//    }
//    List result = await Query(DBManager.tablePicture)
//        .orderBy(["creationDate desc"]).whereByColumFilters([
//      WhereCondiction("creationDate", WhereCondictionType.LESS_THEN, time),
//      WhereCondiction("isSynced", WhereCondictionType.IN, [0]),
//    ]).all();
//
//    List<Picture> list = [];
//    if (result != null && result.length > 0) {
//      result.forEach((item) {
//        Picture p = Picture.fromJson(Map<String, dynamic>.from(item));
//        list.add(p);
//      });
//      return list;
//    }
//    return null;
//  }

//  ///查询已转化图片的集合：目的是拿到最大最小时间
//  Future<List> queryPictureConverted() async {
//    List result = await Query(DBManager.tablePicture)
//        .orderBy(["creationDate desc"]).whereByColumFilters([
//      WhereCondiction("isSynced", WhereCondictionType.IN, [1]),
//    ]).all();
//    List<Picture> list = [];
//    if (result != null && result.length > 0) {
//      result.forEach((item) {
//        Picture p = Picture.fromJson(Map<String, dynamic>.from(item));
//        list.add(p);
//      });
//      return list;
//    }
//    return null;
//  }

  Future<List> queryUnSyncedPictures() async {
    List result = await Query(DBManager.tablePicture)
        .orderBy(["creationDate desc"]).whereByColumFilters([
      WhereCondiction("isSynced", WhereCondictionType.NOT_IN, [1]),
    ]).all();
    if (result != null && result.length > 0) {
      List<Picture> list = [];
      result.forEach((item) =>
          list.add(Picture.fromJson(Map<String, dynamic>.from(item))));
      return list;
    }
    return null;
  }

  Future<Map> queryLastPictureDate() async {
    Map result = await Query(DBManager.tablePicture)
        .orderBy(["creationDate desc"]).needColums(["creationDate"]).first();
    return result;
  }

  ///更新图片路径
  Future<bool> updatePicturePath(String id, String path) async {
    await Query(DBManager.tablePicture).primaryKey([id]).update({"path": path});
    return true;
  }

//  Future<bool> hasCreatePicture() async {
//    Map result = await Query(DBManager.tablePicture).first();
//    return result != null;
//  }

  /// 把图片的path添加上
  Future addPath() async {
    await LocalImageProvider().initialize();
    List<LocalImage> localImages = await LocalImageProvider().findAfterTime();
    for (LocalImage image in localImages) {
      updatePicturePath(image.id, image.path);
    }
  }

  ///清空picture表
  Future clear() async {
    await Query(DBManager.tablePicture).delete();
    print("-------删除Picture表成功");
  }

  LocalImage switchLocalImage(Picture picture) {
    return LocalImage(
        picture.id,
        picture.creationDate,
        picture.pixelWidth.toInt(),
        picture.pixelHeight.toInt(),
        picture.lon,
        picture.lat,
        picture.path,
        null);
  }

  ///获取同步完成的Picture数量
  Future<int> getPictureSyc() async {
    List result = await Query(DBManager.tablePicture).whereByColumFilters([
      WhereCondiction("isSynced", WhereCondictionType.IN, [1]),
    ]).all();
    if (result != null) {
      return result.length;
    }
    return 0;
  }

  Future<List<Picture>> queryPicturesByUuid(String uuid) async {
    List result = await Query(DBManager.tablePicture).whereByColumFilters([
      WhereCondiction("story_uuid", WhereCondictionType.IN, [uuid])
    ]).all();
    if (result != null && result != 0) {
      List<Picture> pictures = [];
      Picture picture;
      await LocalImageProvider().initialize();
      bool isAndroid = Platform.isAndroid;
      for (Map map in result) {
        picture = Picture.fromJson(Map<String, dynamic>.from(map));
        if (await LocalImageProvider()
            .imageExists(isAndroid ? picture.path : picture.id)) {
          pictures.add(picture);
        }
      }
      return pictures;
    }
    return null;
  }

  ///检查图片是否还存在
  Future checkPicture() async {
    num millis = DateTime.now().millisecondsSinceEpoch;
    List result = await Query(DBManager.tablePicture).all();
    if (result != null && result.length > 0) {
      String key = Platform.isAndroid ? "path" : "id";
      for (Map map in result) {
        if (!(await LocalImageProvider().imageExists(map[key] as String))) {
          await Query(DBManager.tablePicture).primaryKey([map["id"]]).delete();
        }
      }
    }
    print(
        "=======检查图片是否被删除时长${DateTime.now().millisecondsSinceEpoch - millis}毫秒");
  }
}
