import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:misstory/db/helper/timeline_helper.dart';
import 'package:misstory/eventbus/event_bus_util.dart';
import 'package:misstory/models/amap_poi.dart';
import 'package:misstory/models/location.dart' as prefix0;
import 'package:misstory/models/picture.dart';
import 'package:misstory/models/timeline.dart';
import 'package:misstory/utils/calculate_util.dart';
import 'package:misstory/utils/date_util.dart';
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
  AmapPoi amapPoi;
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
  checkUnSyncedPicture({num time}) async {
    isPictureConverting = true;
    num start = DateTime.now().millisecondsSinceEpoch;
    List<Picture> pictures;
    if (time == null) {
      pictures = await queryUnSyncedPictures();
    } else {
      pictures = await queryPicturesAfterTime(time);
    }
    if (pictures != null && pictures.length > 0) {
      num total = pictures.length;
      num progress = 0;
      for (Picture picture in pictures) {
        int i = await createStoryWithPicture(picture);
        if (i == 1) {
          await updatePictureStatus(picture);
        }
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
  Future<int> createStoryWithPicture(Picture p) async {
    ///TODO：此处过滤掉经纬度为 0的图片
    if (!(p != null &&
        p.lat != 0 &&
        p.lon != 0 &&
        p.lat != null &&
        p.lon != null)) return 1;
    //找到Picture拍照时是否处于某个Story内
    Timeline targetTimeline = await TimelineHelper()
        .findTargetTimeline(p.creationDate, p.creationDate);
    if (targetTimeline != null) {
      //存在Story就把图片story_id赋值uuid
      await updatePictureStoryUuid(p.id, targetTimeline.uuid);
    } else {
      //找到拍照时间之后的一个Story
      Timeline afterTimeline =
          await TimelineHelper().findAfterTimeline(p.creationDate);
      if (afterTimeline != null &&
          DateUtil.isSameDay(afterTimeline.startTime, p.creationDate) &&
          CalculateUtil.calculateLatlngDistance(
                  afterTimeline.lat, afterTimeline.lon, p.lat, p.lon) <
              afterTimeline.radius) {
        afterTimeline.startTime = p.creationDate;
        await updatePictureStoryUuid(p.id, afterTimeline.uuid);
        await TimelineHelper().updateTimeline(afterTimeline);
      } else {
        //找到拍照时间之前的一个Story
        Timeline beforeTimeline =
            await TimelineHelper().findBeforeTimeline(p.creationDate);
        if (beforeTimeline != null &&
            DateUtil.isSameDay(beforeTimeline.endTime, p.creationDate) &&
            await CalculateUtil.calculateLatlngDistance(
                    beforeTimeline.lat, beforeTimeline.lon, p.lat, p.lon) <
                beforeTimeline.radius) {
          beforeTimeline.endTime = p.creationDate;
          await updatePictureStoryUuid(p.id, beforeTimeline.uuid);
          await TimelineHelper().updateTimeline(beforeTimeline);
        } else {
          prefix0.Location location = new prefix0.Location();
          location.time = p.creationDate;
          location.lat = p.lat;
          location.lon = p.lon;
          location.accuracy = 100;
          location.altitude = 0;
          location.verticalAccuracy = 0;
          location.speed = 0;
          location.bearing = 0;
          location.coordType = "WGS84";
          String uuid =
              await TimelineHelper().createOrUpdateTimelineByPicture(location);
          await updatePictureStoryUuid(p.id, uuid);
          return 1;
        }
      }
    }
    return 1;
  }

//  bool isInChina(AmapPoi amapPoi) {
//    return amapPoi != null &&
//        amapPoi != null &&
//        (amapPoi.country == "中国" ||
//            amapPoi.regeocodeAddress.country == "China") &&
//        ((amapPoi.regeocodeAddress.pois?.length ?? 0) > 0 ||
//            (amapPoi.regeocodeAddress.aois?.length ?? 0) > 0);
//  }

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

  Future<List> queryPicturesAfterTime(num time) async {
    List result = await Query(DBManager.tablePicture)
        .orderBy(["creationDate desc"]).whereByColumFilters([
      WhereCondiction("creationDate", WhereCondictionType.MORE_THEN, time),
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
